Return-Path: linux-nfs-owner@vger.kernel.org
Received: from team-mail.eftel.com.au ([203.24.100.66]:47712 "EHLO
	team-mail.eftel.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756449Ab2CAAwK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Feb 2012 19:52:10 -0500
Received: from exchange.corporate.eftel.com (exchange.corporate.eftel.com [10.16.0.85])
	by team-mail.eftel.com.au (Postfix) with ESMTPS id 22F2B20C0A
	for <linux-nfs@vger.kernel.org>; Thu,  1 Mar 2012 08:52:06 +0800 (WST)
From: Steven Wilton <steven.wilton@team.eftel.com.au>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 1 Mar 2012 08:52:05 +0800
Subject: NFS client (3.0.0-3.2.8) high system CPU
Message-ID: <33F3252F24B63C42BA48F5636E0C821001FA434BBCA3@exchange.corporate.eftel.com>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I've been trying to track down an issue we've started seeing on a bunch of NFS clients where the percentage of CPU time spent by the system has increased for the past month (it was previously using roughly equal system/user time, while now the system time is around 3x the user time).  The information that I have is as follows:

- After rebooting the server, the user/system CPU times look good (roughly equal)
- After 24 hours of heavy activity the system CPU time increases to around 3-4x the user CPU time
- If I run "echo 2 > /proc/sys/vm/drop_caches" the system CPU time drops back down to roughly the same as user

The main difference that I can see in slabtop between a system running at high load and "normal" load is the number of nfs_inode_cache objects (as shown below).  I tried to increase the ihash_entries and dhash_entries kernel parameters, but this did not fix the problem.  I have not found any other suggestions on how to resolve issues caused by large nfs inode caches.

I have tried various kernels between 3.0.0 and 3.2.4, and the machines are currently running a 3.0.22 kernel.  The machines have 8GB RAM, and have 3 NFSv4 mounts and one NFSv3 mount (with the majority of the files that they access being on one of the NFSv4 mount points, being a maildir style mail spool).

I have increased /proc/sys/vm/vfs_cache_pressure to 10000, which has resolved the problem for now, however I believe that the reason we started seeing the issue is that we added a lot of extra users onto the system, resulting in access to a larger number of files for each of the clients.  I am not confident that future growth will stay below whatever threshold we had exceeded to cause the excessive system CPU load, since the problem seemed to appear at around 1,000,000 nfs_inode_cache entries in slabtop, and the NFS clients are floating between 500,000 and 900,000 inode_cache entries.

Help please :), and please let me know if I can provide any more information to assist in debugging.

Regards

Steven

Running slabtop on a system with high load looks like this:
  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
2266249 1645904  72%    0.06K  38411       59    153644K size-64
1236390 1218245  98%    1.02K 412130        3   1648520K nfs_inode_cache
569180 569180 100%    0.19K  28459       20    113836K dentry
190512 184467  96%    0.03K   1701      112      6804K size-32
159026  83040  52%    0.10K   4298       37     17192K buffer_head
95520  76484  80%    0.12K   3184       30     12736K size-128
78001  63551  81%    0.55K  11143        7     44572K radix_tree_node
76956  62898  81%    0.17K   3498       22     13992K vm_area_struct
74690  58327  78%    0.05K    970       77      3880K anon_vma_chain
45680  36644  80%    0.19K   2284       20      9136K size-192
33571  27043  80%    0.06K    569       59      2276K anon_vma
15980  11500  71%    0.19K    799       20      3196K filp
12048  12046  99%    0.08K    251       48      1004K sysfs_dir_cache
12024   7628  63%    0.64K   2004        6      8016K proc_inode_cache
11856   6964  58%    0.30K    912       13      3648K nf_conntrack_ffffffff817fdd80
  5745   5293  92%    0.79K   1149        5      4596K ext3_inode_cache
  5385   3334  61%    0.25K    359       15      1436K tw_sock_TCP
  5250   4540  86%    0.25K    350       15      1400K ip_dst_cache
  4956   2259  45%    0.06K     84       59       336K tcp_bind_bucket
  4180   3637  87%    0.19K    209       20       836K inet_peer_cache
  3975   3909  98%    0.07K     75       53       300K Acpi-Operand
  2852   2808  98%    0.04K     31       92       124K Acpi-Namespace
  2600   1969  75%    0.19K    130       20       520K cred_jar
  2385   1844  77%    0.07K     45       53       180K eventpoll_pwq
  2370   1847  77%    0.12K     79       30       316K eventpoll_epi
  1980   1562  78%    1.00K    495        4      1980K size-1024

Running slabtop on a system after dropping the caches looks like this:
  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
298953  80291  26%    0.06K   5067       59     20268K size-64
134976 101836  75%    0.10K   3648       37     14592K buffer_head
77418  61207  79%    0.17K   3519       22     14076K vm_area_struct
74382  57858  77%    0.05K    966       77      3864K anon_vma_chain
69690  24347  34%    0.12K   2323       30      9292K size-128
50624  14700  29%    0.03K    452      112      1808K size-32
47800  47800 100%    0.19K   2390       20      9560K dentry
36834  36834 100%    1.02K  12278        3     49112K nfs_inode_cache
33394  26657  79%    0.06K    566       59      2264K anon_vma
21665   7895  36%    0.55K   3095        7     12380K radix_tree_node
19820  11786  59%    0.19K    991       20      3964K size-192
15040  10977  72%    0.19K    752       20      3008K filp
12883   7901  61%    0.30K    991       13      3964K nf_conntrack_ffffffff817fdd80
12096  12052  99%    0.08K    252       48      1008K sysfs_dir_cache
  5250   4043  77%    0.25K    350       15      1400K ip_dst_cache
  5115   3150  61%    0.25K    341       15      1364K tw_sock_TCP
  4130   2219  53%    0.06K     70       59       280K tcp_bind_bucket
  4120   3481  84%    0.19K    206       20       824K inet_peer_cache
  3990   3987  99%    0.79K    798        5      3192K ext3_inode_cache
  3975   3909  98%    0.07K     75       53       300K Acpi-Operand
  2852   2808  98%    0.04K     31       92       124K Acpi-Namespace
  2740   1849  67%    0.19K    137       20       548K cred_jar
  2332   1784  76%    0.07K     44       53       176K eventpoll_pwq
  2310   1765  76%    0.12K     77       30       308K eventpoll_epi
  2055   1181  57%    0.25K    137       15       548K skbuff_head_cache
  1986   1899  95%    0.64K    331        6      1324K proc_inode_cache



