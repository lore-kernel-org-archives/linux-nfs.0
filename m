Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mails1n1-route0.email.arizona.edu ([128.196.130.51]:38212 "EHLO
        mails1n1-route0.email.arizona.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1733234AbeGLWzy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jul 2018 18:55:54 -0400
Subject: Re: RDMA connection closed and not re-opened
From: admin@genome.arizona.edu
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
 <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
 <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
 <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
 <57cf42c5-d12d-fff3-fd77-0d191d32111e@genome.arizona.edu>
Message-ID: <9b0802b9-ad7c-0969-6087-9f2aef703143@genome.arizona.edu>
Date: Thu, 12 Jul 2018 15:44:13 -0700
MIME-Version: 1.0
In-Reply-To: <57cf42c5-d12d-fff3-fd77-0d191d32111e@genome.arizona.edu>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Thanks we will see how it goes with the latest kernel and if there are 
> still problems I'll look into filing bug report with CentOS or something.

So, the latest CentOS kernel, 2.6.32-696.30.1, has not helped yet.  In 
the mean time we have reverted to using NFS/TCP over the gigabit 
ethernet link, which creates a bottleneck for the full processing of our 
cluster, but at least hasn't crashed yet.

I did notice that the hangups have all been after 8pm in each 
occurrence.  Each night at 8PM, the NFS server acts as a NFS client and 
runs a couple rsnapshot jobs which backup to a different NFS server. 
Even with NFS/TCP the NFS server became unresponsive after 8pm when the 
rsnapshot jobs were running.  I can see in the system messages the same 
sort of errors with Ganglia we were seeing, as well as rsyslog dropping 
messages related to the ganglia process, as well as nfsd peername failed 
(err 107).  For example,

Jul 11 20:07:31 pac /usr/sbin/gmetad[3582]: poll() timeout from source 0 
for [Pac] data source after 0 bytes read
<repeated 13 times>
Jul 11 20:21:31 pac /usr/sbin/gmetad[3582]: RRD_update 
(/var/lib/ganglia/rrds/Pac/n003.genome.arizona.edu/load_one.rrd): 
/var/lib/ganglia/rrds/Pac/n003.genome.arizona.edu/load_one.rrd: illegal 
attempt to update using time 1531365691 when last update time is 
1531365691 (minimum one second step)
<many messages like this from all the nodes n001-n009
Jul 11 20:21:31 pac rsyslogd-2177: imuxsock begins to drop messages from 
pid 3582 due to rate-limiting
Jul 11 20:22:25 pac rsyslogd-2177: imuxsock lost 116 messages from pid 
3582 due to rate-limiting
Jul 11 20:22:25 pac /usr/sbin/gmetad[3582]: poll() timeout from source 0 
for [Pac] data source after 0 bytes read
<bunch more of these and RRD_update errors>
Jul 11 20:41:54 pac rsyslogd-2177: imuxsock begins to drop messages from 
pid 3582 due to rate-limiting
Jul 11 20:42:34 pac rsyslogd-2177: imuxsock lost 116 messages from pid 
3582 due to rate-limiting
Jul 11 21:09:56 pac kernel: nfsd: peername failed (err 107)!
<repeated 9 more times>
Jul 11 21:09:59 pac /usr/sbin/gmetad[3582]: poll() timeout from source 0 
for [Pac] data source after 0 bytes read
<repeated ~50 more times>
Jul 11 21:48:30 pac /usr/sbin/gmetad[3582]: poll() timeout from source 0 
for [Pac] data source after 0 bytes read
Jul 11 21:48:43 pac kernel: nfsd: peername failed (err 107)!
<repeated 3 more times>
Jul 11 21:53:59 pac /usr/sbin/gmetad[3582]: poll() timeout from source 0 
for [Pac] data source after 0 bytes read
Jul 11 22:39:05 pac rsnapshot[24727]: /usr/bin/rsnapshot -V -c 
/etc/rsnapshotData.conf daily: completed successfully
Jul 11 23:16:24 pac /usr/sbin/gmetad[3582]: poll() timeout from source 0 
for [Pac] data source after 0 bytes read
<EOF>


The difference is it was able to recover once the rsnapshot jobs had 
completed and our other cluster jobs (daligner) are still running and 
servers are responsive.

We are going to let this large job finish with the NFS/TCP before I file 
a bug report with CentOS..   but i thought this extra info might be 
helpful in troubleshooting.  I found the CentOS bug report page and 
there are several options for the "Category"  including "rdma" or 
"kernel" ... which do you think I should file it under?

Thanks,

-- 
Chandler
Arizona Genomics Institute
