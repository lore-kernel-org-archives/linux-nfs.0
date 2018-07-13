Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:35538 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729670AbeGMOv0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jul 2018 10:51:26 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: RDMA connection closed and not re-opened
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <9b0802b9-ad7c-0969-6087-9f2aef703143@genome.arizona.edu>
Date: Fri, 13 Jul 2018 10:36:27 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0423D037-63F9-4BA6-882A-CBD9EBC630F2@oracle.com>
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
 <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
 <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
 <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
 <57cf42c5-d12d-fff3-fd77-0d191d32111e@genome.arizona.edu>
 <9b0802b9-ad7c-0969-6087-9f2aef703143@genome.arizona.edu>
To: admin@genome.arizona.edu
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jul 12, 2018, at 6:44 PM, admin@genome.arizona.edu wrote:
>=20
>> Thanks we will see how it goes with the latest kernel and if there =
are still problems I'll look into filing bug report with CentOS or =
something.
>=20
> So, the latest CentOS kernel, 2.6.32-696.30.1, has not helped yet.  In =
the mean time we have reverted to using NFS/TCP over the gigabit =
ethernet link, which creates a bottleneck for the full processing of our =
cluster, but at least hasn't crashed yet.

You should be able to mount using "proto=3Dtcp" with your mlx4 cards.
That avoids the use of NFS/RDMA but would enable the use of the
higher bandwidth network fabric.


> I did notice that the hangups have all been after 8pm in each =
occurrence.  Each night at 8PM, the NFS server acts as a NFS client and =
runs a couple rsnapshot jobs which backup to a different NFS server.

Can you diagram your full configuration during the backup? Does the
NFS client mount the NFS server on this same host? Does it use
NFS/RDMA or can it use ssh instead of NFS?


> Even with NFS/TCP the NFS server became unresponsive after 8pm when =
the rsnapshot jobs were running.  I can see in the system messages the =
same sort of errors with Ganglia we were seeing, as well as rsyslog =
dropping messages related to the ganglia process, as well as nfsd =
peername failed (err 107).  For example,
>=20
> Jul 11 20:07:31 pac /usr/sbin/gmetad[3582]: poll() timeout from source =
0 for [Pac] data source after 0 bytes read
> <repeated 13 times>
> Jul 11 20:21:31 pac /usr/sbin/gmetad[3582]: RRD_update =
(/var/lib/ganglia/rrds/Pac/n003.genome.arizona.edu/load_one.rrd): =
/var/lib/ganglia/rrds/Pac/n003.genome.arizona.edu/load_one.rrd: illegal =
attempt to update using time 1531365691 when last update time is =
1531365691 (minimum one second step)
> <many messages like this from all the nodes n001-n009
> Jul 11 20:21:31 pac rsyslogd-2177: imuxsock begins to drop messages =
from pid 3582 due to rate-limiting
> Jul 11 20:22:25 pac rsyslogd-2177: imuxsock lost 116 messages from pid =
3582 due to rate-limiting
> Jul 11 20:22:25 pac /usr/sbin/gmetad[3582]: poll() timeout from source =
0 for [Pac] data source after 0 bytes read
> <bunch more of these and RRD_update errors>
> Jul 11 20:41:54 pac rsyslogd-2177: imuxsock begins to drop messages =
from pid 3582 due to rate-limiting
> Jul 11 20:42:34 pac rsyslogd-2177: imuxsock lost 116 messages from pid =
3582 due to rate-limiting
> Jul 11 21:09:56 pac kernel: nfsd: peername failed (err 107)!
> <repeated 9 more times>
> Jul 11 21:09:59 pac /usr/sbin/gmetad[3582]: poll() timeout from source =
0 for [Pac] data source after 0 bytes read
> <repeated ~50 more times>
> Jul 11 21:48:30 pac /usr/sbin/gmetad[3582]: poll() timeout from source =
0 for [Pac] data source after 0 bytes read
> Jul 11 21:48:43 pac kernel: nfsd: peername failed (err 107)!
> <repeated 3 more times>
> Jul 11 21:53:59 pac /usr/sbin/gmetad[3582]: poll() timeout from source =
0 for [Pac] data source after 0 bytes read
> Jul 11 22:39:05 pac rsnapshot[24727]: /usr/bin/rsnapshot -V -c =
/etc/rsnapshotData.conf daily: completed successfully
> Jul 11 23:16:24 pac /usr/sbin/gmetad[3582]: poll() timeout from source =
0 for [Pac] data source after 0 bytes read
> <EOF>
>=20
>=20
> The difference is it was able to recover once the rsnapshot jobs had =
completed and our other cluster jobs (daligner) are still running and =
servers are responsive.

That does describe a possible server overload. Using only GbE could
slow things down enough to avoid catastrophic deadlock.


> We are going to let this large job finish with the NFS/TCP before I =
file a bug report with CentOS..   but i thought this extra info might be =
helpful in troubleshooting.  I found the CentOS bug report page and =
there are several options for the "Category"  including "rdma" or =
"kernel" ... which do you think I should file it under?

I'm not familiar with the CentOS bug database. If there's an "NFS"
category, I would go with that.

Before filing, you should search that database to see if there are
similar bugs. Simply Googling "peername failed!" brings up several
NFSD related entries right at the top of the list that appear
similar to your circumstance (and there is no mention of NFS/RDMA).


--
Chuck Lever



