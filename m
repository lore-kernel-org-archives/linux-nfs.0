Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:54221 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755188AbZGXXNF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2009 19:13:05 -0400
Received: from sim by peace.netnation.com with local (Exim 4.63)
	(envelope-from <sim@netnation.com>)
	id 1MUTwi-0000cT-Um
	for linux-nfs@vger.kernel.org; Fri, 24 Jul 2009 16:13:00 -0700
Date: Fri, 24 Jul 2009 16:13:00 -0700
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: Slower performance with lookupcache (2.6.30.2)
Message-ID: <20090724231300.GA572@hostway.ca>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello :)

I just noticed something interesting while benchmarking NFSv3 versus
GlusterFS.  With lookupcache enabled (all or positive), it seems that
successive executions of "du" are slower the second and further times. 
With lookupcache disabled, second and further executions are slightly
faster than the first but still slower than with lookupcache enabled:

# umount /nfs ; mount -t nfs 10.10.52.30:/home/nfs /nfs -o lookupcache=positive && repeat 3 /bin/sh -c 'time du -s /nfs/test ; sleep 3'
494616  /nfs/test

real    0m1.670s
user    0m0.028s
sys     0m0.344s
494616  /nfs/test

real    0m4.030s
user    0m0.052s
sys     0m0.536s
494616  /nfs/test

real    0m4.025s
user    0m0.060s
sys     0m0.608s

With lookupcache=none:

# umount /nfs ; mount -t nfs 10.10.52.30:/home/nfs /nfs -o lookupcache=none && repeat 3 /bin/sh -c 'time du -s /nfs/test ; sleep 3'
494616  /nfs/test

real    0m5.362s
user    0m0.044s
sys     0m0.924s
494616  /nfs/test

real    0m4.496s
user    0m0.060s
sys     0m0.828s
494616  /nfs/test

real    0m4.497s
user    0m0.052s
sys     0m0.780s

In this case, /nfs/test is just a copy of /usr made on the server.  The
only difference is "lookupcache".  When set to "all" or "positive", the
first sweep is much faster than "none", but the following sweeps are
slower.

nfsstat shows that "getattr" is called many more times on the second and
third sweeps:

# umount /nfs ; mount -t nfs 10.10.52.30:/home/nfs /nfs -o lookupcache=all && repeat 3 /bin/sh -c 'cat /proc/net/rpc/nfs > /tmp/x ; time du -s /nfs/test ; nfsstat -c3 -S /tmp/x ; sleep 3'
494616  /nfs/test

real    0m1.684s
user    0m0.036s
sys     0m0.316s
Client rpc stats:
calls      retrans    authrefrsh
8622       0          0       

Client nfs v3:
null         getattr      setattr      lookup       access       readlink     
0         0% 3649     42% 0         0% 820       9% 1826     21% 0         0% 
read         write        create       mkdir        symlink      mknod        
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
0         0% 0         0% 0         0% 0         0% 8         0% 2319     26% 
fsstat       fsinfo       pathconf     commit       
0         0% 0         0% 0         0% 0         0% 

494616  /nfs/test

real    0m3.975s
user    0m0.052s
sys     0m0.672s
Client rpc stats:
calls      retrans    authrefrsh
25076      0          0       

Client nfs v3:
null         getattr      setattr      lookup       access       readlink     
0         0% 25076   100% 0         0% 0         0% 0         0% 0         0% 
read         write        create       mkdir        symlink      mknod        
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
fsstat       fsinfo       pathconf     commit       
0         0% 0         0% 0         0% 0         0% 

494616  /nfs/test

real    0m4.010s
user    0m0.056s
sys     0m0.616s
Client rpc stats:
calls      retrans    authrefrsh
25076      0          0       

Client nfs v3:
null         getattr      setattr      lookup       access       readlink     
0         0% 25076   100% 0         0% 0         0% 0         0% 0         0% 
read         write        create       mkdir        symlink      mknod        
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
0         0% 0         0% 0         0% 0         0% 0         0% 0         0% 
fsstat       fsinfo       pathconf     commit       
0         0% 0         0% 0         0% 0         0% 

Adding "echo 1 > /proc/sys/vm/drop_caches" to the repeat loop makes the
readdirplus calls happen each time, but still with increased getattrs. 
With "echo 2 > /proc/sys/vm/drop_caches" instead, behaviour is always
fast (~1.6 seconds).

The lookupcache here seems to be increasing initial performance but then
seems to slow down cached performance by causing more getattrs than with
no lookupcache, perhaps for revalidation tests.

This is stock 2.6.30.2 on the server and client, NFSv3, EXT3 on the
server.

Simon-
