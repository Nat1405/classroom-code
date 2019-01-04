import java.io.*;
import java.util.*;
import java.lang.*;

/*This class is taken from geeksforgeeks.org*/
class FastReader {

    BufferedReader br;
    StringTokenizer st;

    public FastReader() {
        br = new BufferedReader(new InputStreamReader(System.in));
    }

    String next() {
        while (st == null || !st.hasMoreElements()) {
            try {
                st = new StringTokenizer(br.readLine());
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return st.nextToken();
    }

    int nextInt() {
        return Integer.parseInt(next());
    }

    long nextLong() {
        return Long.parseLong(next());
    }

    double nextDouble() {
        return Double.parseDouble(next());
    }

    String nextLine() {
        String str = "";
        try {
            str = br.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return str;
    }
}

public class Solution {

    public static boolean weirdEquals(int[] A, int[] B, int n){
        //System.out.println(Arrays.toString(A));
        //System.out.println(Arrays.toString(B));

        // Condition 1: are the two arrays equal?
        // return true if they are, and return false if not and they're not divisible by two.
        boolean areEqual = Arrays.equals(A, B);
        if (areEqual == true){
            return areEqual;
        }
        else{
            //System.out.println("HERE2");
            if (n%2!=0){
                return areEqual;
            }
            //check conditions 2
            //condition 3
            //condition 4
            //System.out.println("Here");
            int i = 0;
            int[] A1 = new int[n/2];
            for(i=0; i < n/2; i++){
                A1[i] = A[i];
            }
            int[] A2 = new int[n/2];
            for(i=0; i < n/2; i++){
                A2[i] = A[n/2+i];
            }
            int[] B1 = new int[n/2];
            for(i=0; i < n/2; i++){
                B1[i] = B[i];
            }
            int[] B2 = new int[n/2];
            for(i=0; i < n/2; i++){
                B2[i] = B[n/2+i];
            }
            /*System.out.println(Arrays.toString(A1));
            System.out.println(Arrays.toString(A2));
            System.out.println(Arrays.toString(B1));
            System.out.println(Arrays.toString(B2));*/

            return ((weirdEquals(A1,B1, n/2) && weirdEquals(A2,B2, n/2))
                    || (weirdEquals(A1,B1, n/2) && weirdEquals(A1,B2,n/2))
                    || (weirdEquals(A2,B2,n/2) && weirdEquals(A2,B1,n/2)));
        }

    }


    public static void main(String[] args) {
        /* Enter your code here. Read input from STDIN. Print output to STDOUT. Your class should be named Solution. */
        // SETUP CODE
        // get int n
        FastReader reader = new FastReader();
        int n = reader.nextInt();
        // get arrays of n ints A and B
        int[] A = new int[n];
        int[] B = new int[n];
        int i = 0;
        int n_copy = n;
        while (n_copy-- > 0)
        {
            A[i] = reader.nextInt();
            i++;
        }
        n_copy = n;
        i = 0;
        while (n_copy-- > 0)
        {
            B[i] = reader.nextInt();
            i++;
        }
        // END SETUP CODE; we have A and B, two arrays of len(n). Let the coding begin!
        boolean areEqual = weirdEquals(A,B,n);
        if (areEqual){
            System.out.println("YES");
        }
        else{
            System.out.println("NO");
        }


    }
}
