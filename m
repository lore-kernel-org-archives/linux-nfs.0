From: Mark Seger <Mark.Seger@hp.com>
Subject: Am I the only one who finds nfsstat pretty useless?
Date: Sat, 15 Dec 2007 14:54:14 -0500
Message-ID: <476430E6.2040900@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:43148 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425AbXLOTyc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Dec 2007 14:54:32 -0500
Received: from seeaxp.zko.hp.com (seeaxp.zko.hp.com [16.116.23.219])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by palrel10.hp.com (Postfix) with ESMTP id 6789234BA0
	for <linux-nfs@vger.kernel.org>; Sat, 15 Dec 2007 11:51:30 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When I want to monitor what's happening with nfs, I want a 
second-by-second view of what's happening and while that usually 
involved many of the counters in nfsstat, they're not particularly 
useful in their present form.  When I wrote collectl (see 
http://collectl.sourceforge.net/), which shows just about any 
performance counter you can think of all nicely formatted, I couldn't 
help but add nfs counters as well.  Now you can see them all on a single 
line (I'm currently talking V2 and V3 but am planning on adding V4 some 
time soon).  I have used the output to show fluctuations in the commit 
rates from a few a second to over 1K per second!  This was particularly 
helpful in finding problems trying to write over 1M files to the same 
directory in an xfs file system.

I don't know how well these examples will show up if they're reformatted 
by mail, but here are just a few different formats for displaying nfs 
data, in some cases mixed with other types as controlled by -s which 
lets you specify the type of data you want to see including cpu, disk, 
network, lustre, infiniband, nfs, sockets, inodes, slabs, processes and 
perhaps one or two more I forgot to list:

[root@cag-dl380-01 collectl]# collectl -oT -scmf
#         <--------CPU--------><-----------Memory----------><--NFS Svr 
Summary-->
#Time     cpu sys inter  ctxsw free buff cach inac slab  map   read  
write  calls
14:49:58    0   0   136     31  13M 495M   2G 562M    0    0      0      
0      0
14:49:59    1   1   144     45  13M 495M   2G 562M    0    0      0      
0      0
14:50:00    0   0   156     63  13M 495M   2G 562M    0    0      0      
0      0

[root@cag-dl380-01 collectl]# collectl -oT -scFnd
#         
<--------CPU--------><-----------Disks-----------><-----------Network----------><----NFS 
MetaOps---->
#Time     cpu sys inter  ctxsw KBRead  Reads  KBWrit Writes netKBi 
pkt-in  netKBo pkt-out   meta commit retran
14:50:38    0   0   133     27      0      0     236      7      0      
6       0       2      0      0      0
14:50:39    8   8   147     36      0      0       0      0      0      
2       0       0      0      0      0

[root@cag-dl380-01 collectl]# collectl -oT -sf --verbose
# NFS SERVER (/sec)
#         <----------Network-------><----------RPC---------><---NFS V3--->
#         PKTS   UDP   TCP  TCPCONN  CALLS  BADAUTH  BADCLNT   READ  WRITE
14:51:37     0     0     0        0      0        0        0      0      0
14:51:38     0     0     0        0      0        0        0      0      0
14:51:39     0     0     0        0      0        0        0      0      0

[root@cag-dl380-01 collectl]# collectl -oT -sF --verbose
# NFS V3 SERVER (/sec)
#         NULL GETA SETA LOOK ACCS RLNK READ WRIT CRE8 MKDR SYML MKND 
RMOV RMDR RENM LINK RDIR RDR+ FSTA FINF PATH COMM
14:52:18     0    0    0    0    0    0    0    0    0    0    0    0    
0    0    0    0    0    0    0    0    0    0
14:52:19     0    0    0    0    0    0    0    0    0    0    0    0    
0    0    0    0    0    0    0    0    0    0
14:52:20     0    0    0    0    0    0    0    0    0    0    0    0    
0    0    0    0    0    0    0    0    0    0

naturally this would look a lot more meaningful with real nfs traffic 
and all this data can be reported interactively or written to rolling 
log files for later playback and can also be recorded in space-separated 
format making it easy to display with gnuplot.  But don't just take my 
word for it, download a copy and try it out yourselves.

-mark


