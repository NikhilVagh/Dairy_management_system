import java.sql.*;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import java.math.BigDecimal;

import java.util.Scanner;

public class JavaExercise 
{
	public static void main(String args[]) 
	{
		Connection c=null;
		try
		{
			// Load Postgresql Driver class
			Class.forName("org.postgresql.Driver");
			// Using Driver class connect to databased on localhost, port=5432, database=postgres, user=postgres, password=postgres. If cannot connect then exception will be generated (try-catch block)
			c = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres","postgres", "1234");
			System.out.println("Opened database successfully");
			
			// Create instance of this class to call other methods
			JavaExercise p = new JavaExercise();
			p.setSearchPath(c);

			//select query
			//p.select_query(c);

			//insert query
			//p.insert_query(c);

			//update query
			//p.update_query(c);

			//delete query
			//p.delete_query(c);

			//calling store procedure
			p.call_store_procedure(c);

			
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.err.println(e.getClass().getName()+": "+e.getMessage());
			System.exit(0);
		}
	}

	void setSearchPath(Connection c)
	{
		Statement stmt = null;
		try
		{
			stmt = c.createStatement();
			String sql = "SET search_path TO dairy_management_system;";
			stmt.executeUpdate(sql);
			stmt.close();
			System.out.println("Changed Search Path successfully");
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.err.println(e.getClass().getName()+": "+e.getMessage());
			System.exit(0);
		}
	}

	void select_query(Connection c)
	{
		Statement stmt=null;
		try
		{
			stmt=c.createStatement();
			ResultSet rs=stmt.executeQuery("SELECT C_FIRST_NAME || ' ' || C_LAST_NAME AS NAME,C_LOCALITY || ' ' || C_CITY || ' PINCODE - ' || C_PINCODE AS ADDRESS,C_MOBILE_NO AS MOBILE_NO, P_NAME AS PRODUCT_NAME,P_COMPANY_NAME AS PRODUCT_COMPANY,F_TITLE AS FEEDBACK_TITLE,F_RATING AS RATING,F_COMMENT AS COMMENT FROM CUSTOMER JOIN (SELECT *FROM FEEDBACK JOIN PRODUCT ON F_TITLE=PRODUCT_ID) AS R1 ON C_MOBILE_NO=CUSTOMER_MO_NO;");
			while(rs.next())
			{
				String name,address,product_name,product_company,feedback_title,f_comment;
				BigDecimal customer_mobile_number;
				float rating;
				name=rs.getString("NAME");
				address=rs.getString("ADDRESS");
				customer_mobile_number=rs.getBigDecimal("MOBILE_NO");
				product_name=rs.getString("PRODUCT_NAME");
				product_company=rs.getString("PRODUCT_COMPANY");
				feedback_title=rs.getString("FEEDBACK_TITLE");
				f_comment=rs.getString("COMMENT");
				rating=rs.getFloat("RATING");

				System.out.println("Customer Name :- " + name + "\nAddress :- " + address + ", C" + "\nCustomer Mobile Number :- " + customer_mobile_number + "\nProduct Name :- " + product_name + "\nProduct Company :- " + product_company + "\nFeedback Title :- " + feedback_title + "\nFeedback Comment :- " + f_comment + "\nRating :- " + rating + "\n");
			}
			stmt.close();
			System.out.println("Select query run successfully");
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.err.println(e.getClass().getName()+": "+e.getMessage());
			System.exit(0);
		}
	}

	void insert_query(Connection c)
	{
		PreparedStatement stmt = null;
		String sql = "INSERT INTO dairy_management_system.FEEDBACK VALUES (?, ?, ?, ?)";
		
		try
		{
			Scanner in = new Scanner(System.in);

			stmt = c.prepareStatement(sql);

			System.out.println("\nEnter feedback title :- ");
			String n2=in.nextLine();

			System.out.println("\nEnter feedback comment :- ");
			String n4=in.nextLine();

			System.out.println("\nEnter customer mobile number :- ");
			BigDecimal n1=in.nextBigDecimal();

			System.out.println("\nEnter feedback rating :- ");
			float n3=in.nextFloat();

			stmt.setString(1, n2);
			stmt.setBigDecimal(2, n1);
			stmt.setFloat(3, n3);
			stmt.setString(4, n4);
			
			int affectedRows = stmt.executeUpdate();
			stmt.close();
			System.out.println("Table Inserted successfully: Rows Affected: " + affectedRows);
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.err.println(e.getClass().getName()+": "+e.getMessage());
			System.exit(0);
		}
	}

	void update_query(Connection c)
	{
		PreparedStatement stmt = null;
		String sql = "UPDATE dairy_management_system.FEEDBACK SET F_RATING = ? WHERE CUSTOMER_MO_NO = ?";
		try
		{
			Scanner in = new Scanner(System.in);
			
			stmt = c.prepareStatement(sql);

			System.out.println("\nEnter new rating :- ");
			float n1=in.nextFloat();
			stmt.setFloat(1, n1);

			System.out.println("\nEnter customer mobile number for update rating :- ");
			BigDecimal n2=in.nextBigDecimal();
			stmt.setBigDecimal(2, n2);
			
			int affectedRows = stmt.executeUpdate();
			stmt.close();
			System.out.println("Table Updated successfully: Rows Updated: " + affectedRows);

		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.err.println(e.getClass().getName()+": "+e.getMessage());
			System.exit(0);
		}
	}

	void delete_query(Connection c)
	{
		PreparedStatement stmt = null;
		String sql = "DELETE FROM dairy_management_system.FEEDBACK WHERE CUSTOMER_MO_NO = ?";
		try
		{
			Scanner in = new Scanner(System.in);
			
			stmt = c.prepareStatement(sql);

			System.out.println("\nEnter customer mobile number for delete feedback record :- ");
			BigDecimal n1=in.nextBigDecimal();
			stmt.setBigDecimal(1, n1);
			
			int affectedRows = stmt.executeUpdate();
			stmt.close();
			System.out.println("Table deleted successfully: Rows Updated: " + affectedRows);

		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.err.println(e.getClass().getName()+": "+e.getMessage());
			System.exit(0);
		}
	}

	void call_store_procedure(Connection c)
	{
		CallableStatement stmt = null;
		try
		{
			Scanner in = new Scanner(System.in);

			String sql = "call dairy_management_system.pro1(?,?,?)";
			stmt = c.prepareCall(sql);

			System.out.print("\nEnter outlet code :- ");
			String n1=in.nextLine();

			System.out.print("\nEnter time-interval(for job) :- ");
			int n2=in.nextInt();

			stmt.setString(1, n1);
			stmt.setInt(2, n2);
			stmt.setInt(3, 0);
			stmt.registerOutParameter(3, Types.INTEGER);

			stmt.execute();

			int n3=stmt.getInt(3);
			stmt.close();
			System.out.println("Procedure Called successfully");
			System.out.println("\nNumber of worker which work more than " + n2 + " years in " + n1 + " outlet :- " + n3);
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.err.println(e.getClass().getName()+": "+e.getMessage());
			System.exit(0);
		}
	}
}