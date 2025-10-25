<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%
    String dbURL = "jdbc:oracle:thin:@localhost:1521:xe"; 
    String dbUser = "system"; 
    String dbPass = "manager"; 

    String message = "";
    String securityQuestion = "";
    boolean showAnswerForm = false;

    if (request.getParameter("get_question") != null) {
        String email = request.getParameter("email");

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection(dbURL, dbUser, dbPass);

            PreparedStatement ps = con.prepareStatement(
                "SELECT security_question FROM UserDetails WHERE email=?"
            );
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                securityQuestion = rs.getString("security_question");
                session.setAttribute("email", email);
                showAnswerForm = true;
            } else {
                message = "Email not found.";
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
        }
    }

    if (request.getParameter("verify") != null) {
        String email = (String) session.getAttribute("email");
        String answer = request.getParameter("answer");

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection(dbURL, dbUser, dbPass);

            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM UserDetails WHERE email=? AND answer=?"
            );
            ps.setString(1, email);
            ps.setString(2, answer);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("verified", "true");
            } else {
                message = "Incorrect answer. Please try again.";
                showAnswerForm = true;
                securityQuestion = rs.getString("security_question");
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
        }
    }

    if (request.getParameter("reset") != null) {
        String newPass = request.getParameter("new_password");
        String confirmPass = request.getParameter("confirm_password");
        String email = (String) session.getAttribute("email");

        if (newPass.equals(confirmPass)) {
            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                Connection con = DriverManager.getConnection(dbURL, dbUser, dbPass);

                PreparedStatement ps = con.prepareStatement(
                    "UPDATE UserDetails SET password=? WHERE email=?"
                );
                ps.setString(1, newPass);
                ps.setString(2, email);

                int updated = ps.executeUpdate();
                if (updated > 0) {
                    message = "Password successfully updated. You can now login.";
                    session.invalidate();
                    response.sendRedirect("Login.html");
                    return;
                } else {
                    message = "Failed to update password.";
                }

                con.close();
            } catch (Exception e) {
                e.printStackTrace();
                message = "Error: " + e.getMessage();
            }
        } else {
            message = "Passwords do not match.";
        }
    }
%>

<html>
<head>
    <title>Forgot Password</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(to right, #74ebd5, #ACB6E5);
            margin: 0;
            padding: 0;
        }

        .login-container {
            background-color: #fff;
            max-width: 400px;
            margin: 80px auto;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0 8px 16px rgba(0,0,0,0.2);
        }

        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 25px;
        }

        form {
            display: flex;
            flex-direction: column;
        }

        input[type="text"],
        input[type="password"],
        select {
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 14px;
        }

        input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            padding: 10px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        input[type="submit"]:hover {
            background-color: #45a049;
        }

        p {
            text-align: center;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Forgot Password</h2>
        <form method="post">
            <% if (session.getAttribute("verified") == null && !showAnswerForm) { %>
                <!-- Step 1: Enter Email -->
                <input type="text" name="email" placeholder="Enter your Email" required>
                <input type="submit" name="get_question" value="Next">
            <% } else if (showAnswerForm) { %>
                <!-- Step 2: Show Security Question -->
                <p><strong>Security Question:</strong> <%= securityQuestion %></p>
                <input type="text" name="answer" placeholder="Your Answer" required>
                <input type="submit" name="verify" value="Verify Answer">
            <% } else { %>
                <!-- Step 3: Reset Password -->
                <input type="password" name="new_password" placeholder="New Password" required>
                <input type="password" name="confirm_password" placeholder="Confirm Password" required>
                <input type="submit" name="reset" value="Reset Password">
            <% } %>
        </form>
        <p style="color:red;"><%= message %></p>
    </div>
</body>
</html>