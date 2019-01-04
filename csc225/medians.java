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
    
    public static void main(String[] args) throws Exception{
        /* Enter your code here. Read input from STDIN. Print output to STDOUT. Your class should be named Solution. */
        // get int n and int k
        FastReader reader = new FastReader();
        int n = reader.nextInt();
        // get integer array of n integers
        int[] A = new int[n];
        int i = 0;
        int n_copy = n;
        while (n_copy-- > 0)
        {
            A[i] = reader.nextInt();
            i++;
        }
        // Done; n is an int and A is array of ints of length n. Begin logic.
        //System.out.println(n);
        //System.out.println(Arrays.toString(A));
        // Setup
        long result = 1;
        int prevmedian = A[0];
        TreeSet<Integer> TA = new TreeSet<>();
        TreeSet<Integer> TB = new TreeSet<>();
        TA.add(A[0]);
        result = (result*prevmedian)%(1000000007);
        // start iterating over the array
        for (int k = 1; k<n;k++){
            // insert A[k]
            if (A[k] <prevmedian){
                // insert in tree A
                TA.add(A[k]);
            }
            else {
                TB.add(A[k]);
            }
            // Make sure sizeTA == sizeTB or sizeTA == sizeTB+1
            if (TA.size() < TB.size()){
                // move min(TB) to TA
                TA.add(TB.first());
                TB.remove(TB.first());
            }
            else if (TA.size() > (TB.size()+1)){
                // move max(TA) to TB
                TB.add(TA.last());
                TA.remove(TA.last());
            }
            // get median and update result
            prevmedian = TA.last();
            result = (result*prevmedian)%(1000000007);
        }
        System.out.println(result);
        
    }
}
