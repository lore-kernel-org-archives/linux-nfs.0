Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from april.london.02.net ([87.194.255.143]:44440 "EHLO
	april.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759304Ab0GWMKZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jul 2010 08:10:25 -0400
Received: from [192.168.1.64] (87.194.12.203) by april.london.02.net (8.5.124.03)
        id 4C1F983E00F04F04 for linux-nfs@vger.kernel.org; Fri, 23 Jul 2010 13:10:23 +0100
Message-ID: <4C4986A8.9090704@limepepper.co.uk>
Date: Fri, 23 Jul 2010 13:10:16 +0100
From: Tom H <tom@limepepper.co.uk>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: CentOS5.4 x86_64 server with intermittent mount and read/write problems
 (BUG: soft lockup, debugging)
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi All,

I have a nfs server that is under quite a bit of heavy usage from time 
to time, and today I have had lots of problems with some clients not 
being able to mount the export, and other servers reporting not 
responding: kernel: nfs: server someserver not responding, timed out, 
when reading/writing.

There are no error logs being produced on the server, and only these 
messages below on the client.

I presume this is a load issue, and I would be keen to identify which 
component is responsible so I can either upgrade or move some files 
elsewhere.

There appears to be a kernel upgrade available in the repos, and some 
have suggested setting the kernel option noapic and apic=off for the 
next boot, which I am going to try tomorrow)

Any suggestions on how to determine the choking point on this server?

Many Thanks
Tom


# uptime
 04:59:17 up 97 days, 19:29,  2 users,  load average: 3.73, 3.47, 3.37

# free -m
             total       used       free     shared    buffers     cached
Mem:         12007      11944         63          0       1308       9645
-/+ buffers/cache:        990      11017
Swap:        12095          0      12095


On the clients I am seeing
# mount -vv -t nfs -o soft servername:/mount/processed34 /mount/processed34
mount: trying 198.nn.nn.nn prog 100003 vers 3 prot tcp port 2049
mount: mount to NFS server servername failed: timed out (retrying).
mount: trying 198.nn.nn.nn prog 100003 vers 3 prot tcp port 2049
mount: mount to NFS server 'servername' failed: timed out (giving up).

and for the clients that have mounted the fs;
kernel: nfs: server someserver not responding, timed out


I am seeing errors like this in the /var/log/messages;
# grep BUG messages
Jul 23 03:18:21 servername kernel: BUG: soft lockup - CPU#5 stuck for 
11s! [nfsd:20540]
Jul 23 03:22:09 servername kernel: BUG: soft lockup - CPU#1 stuck for 
15s! [nfsd:20545]
(repeated many times)


retrans from a client that was having problems;
# nfsstat -c -3
Client rpc stats:
calls      retrans    authrefrsh
25536750   209        0      

Client nfs v3:
null         getattr      setattr      lookup       access       
readlink    
0         0% 1467584   6% 2702      0% 16868358 69% 746134    3% 
0         0%
read         write        create       mkdir        symlink      
mknod       
337417    1% 683048    2% 24049     0% 91        0% 0         0% 
0         0%
remove       rmdir        rename       link         readdir      
readdirplus 
10923     0% 86        0% 4844      0% 0         0% 158020    0% 
3805702  15%
fsstat       fsinfo       pathconf     commit      
156       0% 24        0% 0         0% 25625     0%

server nfs stats;
# nfsstat -s -3
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
342989209   1397       1397       0          0      

Server nfs v3:
null         getattr      setattr      lookup       access       
readlink    
4169      0% 1951757   0% 1241244   0% 68875972 20% 2180568   0% 
0         0%
read         write        create       mkdir        symlink      
mknod       
18863     0% 144562881 42% 61482189 17% 456758    0% 0         0% 
0         0%
remove       rmdir        rename       link         readdir      
readdirplus 
8119668   2% 35533     0% 1         0% 0         0% 46596     0% 
1805329   0%
fsstat       fsinfo       pathconf     commit      
545       0% 3379      0% 2         0% 51641657 15%







