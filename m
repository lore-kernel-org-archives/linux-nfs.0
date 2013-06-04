Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:28553 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813Ab3FDQQu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jun 2013 12:16:50 -0400
Message-ID: <51AE12E8.1000500@oracle.com>
Date: Tue, 04 Jun 2013 18:16:40 +0200
From: jens kusch <jens.kusch@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: strange nfsd scheduling in 2.6.32
References: <51A8B08C.3090309@oracle.com> <20130603193758.GB2109@fieldses.org>
In-Reply-To: <20130603193758.GB2109@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for reply! We tested on 2.6.39-400 and the issue was gone.

On 6/3/2013 9:37 PM, J. Bruce Fields wrote:
> On Fri, May 31, 2013 at 04:15:40PM +0200, jens kusch wrote:
>> Hi all,
>>
>> we have a problem with nfsd performance in 2.6.32. They don't seem
>> to able to cope with the load. This is different in 2.6.18. Anybody
>> seen this before?
>>
>> On Linux 2.6.32:
>>
>> - IOs are often processed by nfsd processes in a delayed fashion, as
>> if they have been queued before (seen from application traces).
>> - NFS pool statistics show only a smaller fraction processed
>> immediately (10..20%). The rest is queued or delayed.
>> - On the other hand there are lots of nfsd processes that sit idle
>> at the same time!
>> - CPU usage is very unevenly distributed among the nfsd servers,
>> many are never used
>>
>> I'd just like to emphasize one detail: note the output from
>> /proc/fs/nfsd/pool_stats below:
>>
>> # pool packets-arrived sockets-enqueued threads-woken
>> overloads-avoided threads-timedout
>> 0 7740103 1837083 885771 1837081 480
>>
>> The stat overloads-avoided always gets incremented in our runs. Here
>> is a brief description:
> The patch that added the "overload-avoidance" thing didn't work in
> practice, and I couldn't figure out what it was meant to do, so it got
> revoked with
>
> 	78c210efdefe07131f91ed512a3308b15bb14e2f Revert "knfsd: avoid
> 	overloading the CPU scheduler with enormous load averages"
>
> Does appling that revoke help?
>
> --b.
>
>
>> Counts how many times the sunrpc server layer chose not to wake an
>> nfsd thread, despite the presence of idle nfsd threads, because too
>> many nfsd threads had been recently woken but could not get enough
>> CPU time to actually run. In our runs, CPU utilization never gets
>> close to 100%, so I wonder why NFS decided not to wake up one of the
>> idle threads we see.
>>
>> In our runs, CPU utilization never gets close to 100%, so I wonder
>> why NFS decided not to wake up one of the idle threads we see.
>>
>>
>> On Linux 2.6.18
>>
>> - Performance via NFS is better
>> - CPU usage is more evenly distributed among the nfsd processes, all
>> nfsd processes are really used
>>
>> We would appreciate any hint about what could be wrong in 2.6.32.
>>
>> Best regards,
>> Jens
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

