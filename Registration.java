


import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class Registration extends HttpServlet {

    

    // Database connection settings
    private String jdbcURL = "jdbc:oracle:thin:@localhost:1521:xe"; // Oracle XE default
    private String jdbcUsername = "system";   // <-- replace with your Oracle username
    private String jdbcPassword = "manager";   // <-- replace with your Oracle password

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // Collect form data
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contact = request.getParameter("contact");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirm");
        String security = request.getParameter("security");
        String answer = request.getParameter("answer");
        

        // Basic password match check
        if (!password.equals(confirm)) {
            out.println("<h2>Passwords do not match!</h2>");
            out.println("<a href='Registration.html'>Try Again</a>");
            return;
        }

        try {
            // Load Oracle JDBC Driver
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Connect to DB
            Connection con = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

            // SQL Insert
            String sql = "INSERT INTO UserDetails (name, email,contact, password, "
                    + "security_question, answer) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, contact);
            ps.setString(4, password);
            ps.setString(5, security);
            ps.setString(6, answer);
            

            int rows = ps.executeUpdate();

            if (rows > 0) {
                
                  response.sendRedirect("Login.html");
            } else {
                out.println("<h2>Registration Failed. Please try again.</h2>");
                out.println("<a href='Registration.html'>Back</a>");
                 
            }

            ps.close();
            con.close();

        } catch (Exception e) {
            out.println("<h2>Error: " + e.getMessage() + "</h2>");
            e.printStackTrace(out);
        }
    }
}