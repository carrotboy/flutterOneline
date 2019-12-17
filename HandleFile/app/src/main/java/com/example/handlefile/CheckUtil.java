package com.example.handlefile;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class CheckUtil {
    private static final CheckUtil ourInstance = new CheckUtil();

    public static CheckUtil getInstance() {
        return ourInstance;
    }

    private CheckUtil() {
    }

    public List<Integer> getPointList(int[] nums) {
        Set<Integer> set = new HashSet<>();
        for (int i = 0; i < nums.length; i++) {
            set.add(nums[i]);
        }
        List<Integer> list = new ArrayList(set);
        Collections.sort(list, new Comparator<Integer>() {
            @Override
            public int compare(Integer o1, Integer o2) {
                return o1-o2;
            }
        });
        return list;
    }

    public boolean isAllStepOne(List<Integer> list) {
        for (int i = 1; i < list.size(); i++) {
            if (list.get(i) - list.get(i-1) != 1) {
                return false;
            }
        }
        return true;
    }
}
