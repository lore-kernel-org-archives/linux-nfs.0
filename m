Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:33194 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbaAPRUp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 12:20:45 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] nfs(5): Clarify DATA AND METADATA COHERENCE section
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <EDDCEDED-2C93-460F-A5B4-91A50C44F2B7@gmail.com>
Date: Thu, 16 Jan 2014 12:20:40 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D29E5BC8-70DF-4612-93D3-117E7D9B2BC1@oracle.com>
References: <20140116170841.1489.82372.stgit@seurat.1015granger.net> <EDDCEDED-2C93-460F-A5B4-91A50C44F2B7@gmail.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 16, 2014, at 12:14 PM, Trond Myklebust <trondmy@gmail.com> wrote:

> 
> On Jan 16, 2014, at 12:09, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> How about something like this?
> 
> We really want something in the acregmin/max, acdirmin/max descriptions that refers to the cache coherency discussion too.

“noac” now has:

                      The DATA  AND  METADATA  COHERENCE  section  contains  a
                      detailed discussion of these trade-offs.

“lookupcache” has:

                      The DATA  AND  METADATA  COHERENCE  section  contains  a
                      detailed discussion of these trade-offs.

And “cto” has:

                      server changes only occasionally.  The DATA AND METADATA
                      COHERENCE section discusses the behavior of this  option
                      in more detail.

We can add this to ac{reg,dir}{min,max}:

                      See the DATA AND METADATA COHERENCE section for  a  full
                      discussion of attribute caching.

Is that what you were thinking?

> Cheers,
>  Trond
> 
>> 
>> utils/mount/nfs.man |   28 ++++++++++++++++++----------
>> 1 file changed, 18 insertions(+), 10 deletions(-)
>> 
>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>> index 2250963..99c9fc3 100644
>> --- a/utils/mount/nfs.man
>> +++ b/utils/mount/nfs.man
>> @@ -1161,24 +1161,32 @@ perfect cache coherence among their clients.
>> Perfect cache coherence among disparate NFS clients
>> is expensive to achieve, especially on wide area networks.
>> As such, NFS settles for weaker cache coherence that
>> -satisfies the requirements of most file sharing types. Normally,
>> -file sharing is completely sequential:
>> -first client A opens a file, writes something to it, then closes it;
>> -then client B opens the same file, and reads the changes.
>> -.DT
>> +satisfies the requirements of most file sharing types.
>> .SS "Close-to-open cache consistency"
>> -When an application opens a file stored on an NFS server,
>> -the NFS client checks that it still exists on the server
>> +Typically file sharing is completely sequential.
>> +First client A opens a file, writes something to it, then closes it.
>> +Then client B opens the same file, and reads the changes.
>> +.P
>> +When an application opens a file stored on an NFS version 3 server,
>> +the NFS client checks that the file exists on the server
>> and is permitted to the opener by sending a GETATTR or ACCESS request.
>> +The NFS client sends these requests
>> +independent of the freshness of the file's attribute cache.
>> +.P
>> When the application closes the file,
>> the NFS client writes back any pending changes
>> to the file so that the next opener can view the changes.
>> This also gives the NFS client an opportunity to report
>> -any server write errors to the application
>> -via the return code from
>> +write errors to the application via the return code from
>> .BR close (2).
>> +.P
>> The behavior of checking at open time and flushing at close time
>> -is referred to as close-to-open cache consistency.
>> +is referred to as
>> +.IR "close-to-open cache consistency" ,
>> +or CTO.
>> +It can be disabled for an entire mount point using the
>> +.B nocto
>> +mount option.
>> .SS "Weak cache consistency"
>> There are still opportunities for a client's data cache
>> to contain stale data.
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



