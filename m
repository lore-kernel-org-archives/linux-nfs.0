Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:33722 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759807Ab2EVQWK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 12:22:10 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by acsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q4MGM7Bt005472
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 16:22:08 GMT
Received: from acsmt358.oracle.com (acsmt358.oracle.com [141.146.40.158])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q4MGLxJh001442
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 16:21:59 GMT
Received: from abhmt102.oracle.com (abhmt102.oracle.com [141.146.116.54])
	by acsmt358.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q4MGLxUo026811
	for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 11:21:59 -0500
Message-ID: <4FBBBD26.2090203@oracle.com>
Date: Tue, 22 May 2012 10:21:58 -0600
From: Jeff Wright <jeff.wright@oracle.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: Jeff Wright <jeff.wright@oracle.com>,
        Craig Flaskerud <Craig.flaskerud@oracle.com>,
        Donna Harland <donna.harland@oracle.com>
Subject: Help with NFS over 10GbE performance - possible NFS client to TCP
 bottleneck
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Team,

I am working on a team implementing a configuration with an OEL kernel 
(2.6.32-300.3.1.el6uek.x86_64) and kernel NFS accessing an NFS server 
over 10GbE a Solaris 10.  We are trying to resolve what appears to be a 
bottleneck between the Linux kernel NFS client and the TCP stack.  
Specifically, the TCP send queue on the Linux client is empty (save a 
couple of bursts) when we are running write I/O from the file system, 
the TCP receive queue on the Solaris 10 NFS server is empty, and the RPC 
pending request queue on the Solaris 10 NFS server is zero.   If we dial 
the network to 1GbE we get a nice deep TCP send queue on the client, 
which is the bottleneck I was hoping to get to with 10GbE.  At this 
point, we am pretty sure the S10 NFS server can run to at least 1000 MBPS.

So far, we have implemented the following Linux kernel tunes:

sunrpc.tcp_slot_table_entries = 128
net.core.rmem_default = 4194304
net.core.wmem_default = 4194304
net.core.rmem_max = 4194304
net.core.wmem_max = 4194304
net.ipv4.tcp_rmem = 4096 1048576 4194304
net.ipv4.tcp_wmem = 4096 1048576 4194304
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_syncookies = 1
net.core.netdev_max_backlog = 300000

In addition, we am running jumbo frames on the 10GbE NIC and we have 
cpuspeed and irqbalance disabled (no noticeable changes when we did 
this).  The mount options on the client side are as follows:

192.168.44.51:/export/share on /export/share type nfs 
(rw,nointr,bg,hard,rsize=1048576,wsize=1048576,proto=tcp,vers=3,addr=192.168.44.51)

In this configuration we get about 330 MBPS of write throughput with 16 
pending stable (open with O_DIRECT) synchronous (no kernel aio in the 
I/O application) writes.  If we scale beyond 16 pending I/O response 
time increases but throughput remains fixed.  It feels like there is a 
problem with getting more than 16 pending I/O out to TCP, but we can't 
tell for sure based on our observations so far.  We did notice that 
tuning the wsize down to 32kB increased throughput to 400 MBPS, but we 
could not identify the root cause of this change.

Please let us know if you have any suggestions for either diagnosing the 
bottleneck more accurately or relieving the bottleneck.  Thank you in 
advance.

Sincerely,

Jeff
