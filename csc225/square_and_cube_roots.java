import java.io.*;
import java.util.*;
import java.lang.*;
import java.math.BigInteger;

public class Solution {

    public static BigInteger squareRoot(BigInteger n){
        //System.out.println("Inside Square Root");
        // Use binary search to find the square root
        BigInteger R = n.add(BigInteger.ZERO); // Upper bound initialized to n
        BigInteger P = new BigInteger("1"); // Lower bound
        BigInteger Q = n.divide(BigInteger.valueOf(2)); // Halfway value
        BigInteger SQUARE = Q.pow(2);
        //System.out.println(R.toString());
        //System.out.println(P.toString());
        //System.out.println(Q.toString());
        //System.out.println(SQUARE.toString());
        while (SQUARE.compareTo(n) !=0){
            if (SQUARE.compareTo(n) > 0){
                R = Q.add(BigInteger.ZERO); //r=q
                Q = R.subtract(P);
                Q = R.add(BigInteger.valueOf(1));
                Q = Q.divide(BigInteger.valueOf(2));
            }
            else{
                P = Q.add(BigInteger.ZERO);
                BigInteger TEMP; 
                TEMP = R.subtract(P);
                TEMP = TEMP.divide(BigInteger.valueOf(2));
                Q = Q.add(TEMP);
            }
            SQUARE = Q.pow(2);
        }
        return Q;
    }
    
    public static BigInteger cubeRoot(BigInteger n){
        //System.out.println("Inside Cube Root");
        // Use binary search to find the cube root
        BigInteger R = n.add(BigInteger.ZERO); // Upper bound initialized to n
        BigInteger P = new BigInteger("1"); // Lower bound
        BigInteger Q = n.divide(BigInteger.valueOf(2)); // Halfway value
        BigInteger CUBE = Q.pow(3);
        //System.out.println(R.toString());
        //System.out.println(P.toString());
        //System.out.println(Q.toString());
        //System.out.println(CUBE.toString());
        while (CUBE.compareTo(n) !=0){
            if (CUBE.compareTo(n) > 0){
                R = Q.add(BigInteger.ZERO); //r=q
                Q = R.subtract(P);
                Q = R.add(BigInteger.valueOf(1));
                Q = Q.divide(BigInteger.valueOf(2));
            }
            else{
                P = Q.add(BigInteger.ZERO);
                BigInteger TEMP; 
                TEMP = R.subtract(P);
                TEMP = TEMP.divide(BigInteger.valueOf(2));
                Q = Q.add(TEMP);
            }
            CUBE = Q.pow(3);
        }
        return Q;
    }
    
    public static void main(String[] args) throws Exception{
        /* Enter your code here. Read input from STDIN. Print output to STDOUT. Your class should be named Solution. */
        // get type of operation and n
        Scanner scanner = new Scanner( System.in );
        String input = scanner.nextLine();
        String delims = "[\\^=]+";
        String[] tokens = input.split(delims);
        //System.out.println(tokens[1]);
        //System.out.println(tokens[2]);
        // Convert n to big int
        BigInteger n  = new BigInteger(tokens[2]);
        if(tokens[1].equals("2")){
            BigInteger SQUAREROOT;
            SQUAREROOT = squareRoot(n);
            System.out.println(SQUAREROOT);
        }
        else if (tokens[1].equals("3")){
            BigInteger CUBEROOT;
            CUBEROOT = cubeRoot(n);
            System.out.println(CUBEROOT);
        }
        

    }
}
