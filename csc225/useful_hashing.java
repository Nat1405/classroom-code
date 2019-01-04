import java.io.*;
import java.util.*;
import java.util.Map.Entry;

public class Solution {

    public static void main(String[] args) {
        /* Enter your code here. Read input from STDIN. Print output to STDOUT. Your class should be named Solution. */
        Scanner scan = new Scanner(System.in);
        int n = scan.nextInt();  
        HashMap<String, Integer> table = new HashMap<>(n * 2);
        scan.nextLine();
        for (int i=0; i<n; i++){
            String toHash = scan.next();
            //if key isn't there put it in
            if (table.get(toHash)==null){
                table.put(toHash, 1);
            }
            else{
                // get the original value
                int prev = table.get(toHash);
                // Add 1 and write to table
                table.put(toHash, prev+1);
            }
        }
        // print key of largest value in table
        int max = 0;
        String biggestKey = "";
        for (Entry<String, Integer> pair : table.entrySet()) {
            int value = pair.getValue();
            String key = pair.getKey();
            //System.out.println(key + ":" + value);
            // if value == max lexographically compare
            if (value == max){
                if (biggestKey.compareTo(key) > 0){
                    max = value;
                    biggestKey=key;
                }
            } else if (value > max){
                max = value;
                biggestKey=key;
            }
        }
        System.out.println(biggestKey + " " + max);
    }
}
