Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-99-17-64-89.dsl.sfldmi.sbcglobal.net ([99.17.64.89]:43734
	"EHLO crunch.scalableinformatics.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750836Ab0HYRRg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 13:17:36 -0400
Message-ID: <4C754DB4.5060608@scalableinformatics.com>
Date: Wed, 25 Aug 2010 13:07:00 -0400
From: Joe Landman <landman@scalableinformatics.com>
Reply-To: landman@scalableinformatics.com
To: davidr@ressman.org
CC: linux-nfs@vger.kernel.org
Subject: Re: fsync/wb deadlocks in 2.6.32
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
In-Reply-To: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

davidr@ressman.org wrote:
> Hello all,
> 
> I have ~100 nfs clients running Ubuntu 10.04 LTS, and under moderate and
> heavy v3 write loads, I will periodically get deadlocks in nfs_do_fsync().
> Unfortunately, it's rare enough that I've not been able to come up with
> a test case that works reliably. The usage pattern looks like this:
> 
> 1. 8 jobs are started on each of 100 nodes (each node has 8 cores)
> 2. These jobs stat(), read() and close() unique files of size 10-20MB
>    on the source NFS filesystem.
> 3. They open(), write(), and close() the files on the target NFS
>    filesystem (not the same as the source filesystem). Occasionally, the
>    clients will insert a mkdir() before the open().
> 4. Steps 2-3 are repeated for a total of ~20m files (as in, all clients copy a
>    total of 20m files cumulatively)
> 
> After an hour or two, at least one of these nodes gives a series of these
> messages:
> 
> [88792.122324] INFO: task awk:7184 blocked for more than 120 seconds.

Did you get an "nfs server not responding" type message in the logs?

[...]

> Here are the current mount options:
>   async,nocto,proto=udp,auto,intr,noatime,nodiratime, \
>   rsize=32768,rw,vers=3,wsize=32768
> 
> I've tried tcp/udp, cto/nocto (i.e., grasping at straws), and none of
> those options appear to have any effect either.

If you get the nfs server not responding message, you might switch to
	
	proto=tcp,retrans=10

or similar (try retrans=N if you just want to play with that).

> As far as I can tell, the problem appears to be unrelated to the
> NFS server. We've seen these hangs while writing to a RHEL server
> (2.6.18-92.1.22.el5) as well as an F5 ARX NFS proxy.

Is it possible that a server or switch was overloaded during this 
interval?

> If anyone has seen this before, knows what it is, or needs more info
> from me, please let me know.

Things like this, usually under heavy load situations, when we hit a 
spot of resource contention (usually network or server being too busy).



> 
> Thanks,
> 
> David
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Joseph Landman, Ph.D
Founder and CEO
Scalable Informatics Inc.
email: landman@scalableinformatics.com
web  : http://scalableinformatics.com
        http://scalableinformatics.com/jackrabbit
phone: +1 734 786 8423 x121
fax  : +1 866 888 3112
cell : +1 734 612 4615
