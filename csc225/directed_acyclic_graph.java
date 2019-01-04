import java.io.*;
import java.util.*;

// Code built from the template provided in lab09

public class directed_acyclic_graph {
	/*This class is taken from geeksforgeeks.org*/
    static class FastReader {
        
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

    // Global variables
    private static boolean[] visited;


    public static boolean DFS(List<Integer>[] adj, int n){
    	boolean result = true;
    	for (int i=0;i<n;i++){
    		if (!visited[i]){
    			result = DFSVisit(adj, i);
    			if (!result){
    				return false;
    			}
    		}
    	}
    	return result;
    }

    public static boolean DFSVisit(List<Integer>[] adj, int i){
    	visited[i] = true;
    	boolean result = true;
    	for(int j=0;j<adj[i].size();j++){
    		if (visited[adj[i].get(j)]){
    			return false;
    		} else {
    			result = DFSVisit(adj, adj[i].get(j));
    			if (!result){
    				return false;
    			}
    		}
    	}
    	return true;
    }

	public static void main(String[] args){
		FastReader in = new FastReader();
        int n = in.nextInt();

        visited = new boolean[n];

        List<Integer>[] adj = new List[n];
        int nextInt;
        for(int i=0; i<n;i++){
        	adj[i] = new ArrayList<>();
        	nextInt = in.nextInt();
        	for(int j=0;j<nextInt;j++){
        		adj[i].add(in.nextInt());
        	}
        	visited[i] = false;
        }
        for(int i =0;i<n;i++){
        	System.out.println(Arrays.toString(adj[i].toArray()));
        }
        boolean result = DFS(adj, n);
        if (result){
        	System.out.println("AUTHENTIC");
        } else {
        	System.out.println("FAKE");
        }
	}
}




















