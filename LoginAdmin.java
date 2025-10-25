import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class LoginAdmin extends HttpServlet {

    private static final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    private static final String DB_USER = "system"; 
    private static final String DB_PASS = "manager"; 

    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // ✅ Change column names according to your table
            ps = con.prepareStatement("SELECT name,email,contact FROM AdminDetails WHERE email=? AND password=?");
            ps.setString(1, email);
            ps.setString(2, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                String name = rs.getString("name");  // adjust if your column is different

                // ✅ Create session
                HttpSession session = request.getSession();
                session.setAttribute("email", rs.getString("email"));
                session.setAttribute("name", name);
                session.setAttribute("contact", rs.getString("contact"));
//                session.setAttribute("address", rs.getString("address"));
                // ✅ Redirect to homepage JSP
              response.sendRedirect("HomepageAfterLogin2.jsp");
//                 out.println("Success");
            } else {
                out.println("<h3 style='color:red;'>Invalid Mobile or Password</h3>");
                RequestDispatcher rd = request.getRequestDispatcher("LoginAdmin.html");
                rd.include(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace(out);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}