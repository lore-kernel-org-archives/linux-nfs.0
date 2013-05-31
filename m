Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:38816 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab3EaOPt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 May 2013 10:15:49 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r4VEFlVG023986
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 31 May 2013 14:15:48 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r4VEFlPF010482
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 31 May 2013 14:15:47 GMT
Received: from abhmt116.oracle.com (abhmt116.oracle.com [141.146.116.68])
	by userz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r4VEFk3P015448
	for <linux-nfs@vger.kernel.org>; Fri, 31 May 2013 14:15:46 GMT
Message-ID: <51A8B08C.3090309@oracle.com>
Date: Fri, 31 May 2013 16:15:40 +0200
From: jens kusch <jens.kusch@oracle.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: strange nfsd scheduling in 2.6.32
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

we have a problem with nfsd performance in 2.6.32. They don't seem to 
able to cope with the load. This is different in 2.6.18. Anybody seen 
this before?

On Linux 2.6.32:

- IOs are often processed by nfsd processes in a delayed fashion, as if 
they have been queued before (seen from application traces).
- NFS pool statistics show only a smaller fraction processed immediately 
(10..20%). The rest is queued or delayed.
- On the other hand there are lots of nfsd processes that sit idle at 
the same time!
- CPU usage is very unevenly distributed among the nfsd servers, many 
are never used

I'd just like to emphasize one detail: note the output from 
/proc/fs/nfsd/pool_stats below:

# pool packets-arrived sockets-enqueued threads-woken overloads-avoided 
threads-timedout
0 7740103 1837083 885771 1837081 480

The stat overloads-avoided always gets incremented in our runs. Here is 
a brief description:

Counts how many times the sunrpc server layer chose not to wake an nfsd 
thread, despite the presence of idle nfsd threads, because too many nfsd 
threads had been recently woken but could not get enough CPU time to 
actually run. In our runs, CPU utilization never gets close to 100%, so 
I wonder why NFS decided not to wake up one of the idle threads we see.

In our runs, CPU utilization never gets close to 100%, so I wonder why 
NFS decided not to wake up one of the idle threads we see.


On Linux 2.6.18

- Performance via NFS is better
- CPU usage is more evenly distributed among the nfsd processes, all 
nfsd processes are really used

We would appreciate any hint about what could be wrong in 2.6.32.

Best regards,
Jens
