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

    public static void main(String[] args) {
        /* Enter your code here. Read input from STDIN. Print output to STDOUT. Your class should be named Solution. */
        // get int n
        FastReader reader = new FastReader();
        int n = reader.nextInt();
        // get array of ints numbers
        int[] A = new int[n];
        int i = 0;
        int n_copy = n;
        while (n_copy-- > 0)
        {
            A[i] = reader.nextInt();
            i++;
        }
        // Done; n is an int and A is array of ints of length n. Begin logic.
        // Declare variables
        int diff = Integer.MAX_VALUE;
        int best_i = 0;
        int best_i_1 = 0;
        // Sort the array
        Arrays.sort(A);
        //System.out.println(Arrays.toString(A));
        for(i=n-1; i>0; i--){
            if ((A[i] - A[i-1]) < diff){
                diff = A[i] - A[i-1];
                best_i = i;
                best_i_1 = i-1;
                if (diff == 0){
                    break;
                }
            }
        }

        if (A[best_i] <= A[best_i_1]){
            System.out.printf("%d %d\n", A[best_i], A[best_i_1]);
        }
        else{
            System.out.printf("%d %d\n", A[best_i_1], A[best_i]);
        }

    }
}
