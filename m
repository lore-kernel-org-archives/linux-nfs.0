Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:17274 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaARQZy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Jan 2014 11:25:54 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH v2] nfs(5): Treatment of *atime mount options
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <52DAA526.9090408@RedHat.com>
Date: Sat, 18 Jan 2014 11:25:43 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <91E8B377-BDE9-4EA4-A0D4-4707A9275872@oracle.com>
References: <20140116173120.1876.84785.stgit@seurat.1015granger.net> <52DAA526.9090408@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 18, 2014, at 11:00 AM, Steve Dickson <SteveD@redhat.com> wrote:

> On 16/01/14 12:31, Chuck Lever wrote:
>> I was reminded recently that NFS treats file atime time stamps
>> differently than other filesystems.  It also ignores the generic
>> *atime mount options because it cannot support the atime semantics
>> of local filesystems.
>> 
>> We should document that somewhere.  nfs(5) seems like a logical
>> place for it.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> I'm a bit confused... What is the different between this patch
> and the one you posted back in Nov 18
>   http://www.spinics.net/lists/linux-nfs/msg40559.html
> which turned to commit
> 
>  commit f41c591f8f4d492ee84994bb86810fb90bef8d4b
>  Author: Chuck Lever <chuck.lever@oracle.com>
>  Date:   Wed Nov 20 14:10:06 2013 -0500

I pulled, but didn’t see this one.  If you already have it post 1.2.9, you can ignore this patch.


> 
> steved.
>> ---
>> utils/mount/nfs.man |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++
>> 1 file changed, 59 insertions(+)
>> 
>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>> index 67031b5..2250963 100644
>> --- a/utils/mount/nfs.man
>> +++ b/utils/mount/nfs.man
>> @@ -1227,6 +1227,65 @@ If absolute cache coherence among clients is required,
>> applications should use file locking. Alternatively, applications
>> can also open their files with the O_DIRECT flag
>> to disable data caching entirely.
>> +.SS "File timestamp maintainence"
>> +NFS servers are responsible for managing file and directory timestamps
>> +.RB ( atime ,
>> +.BR ctime ", and"
>> +.BR mtime ).
>> +When a file is accessed or updated on an NFS server,
>> +the file's timestamps are updated just like they would be on a filesystem
>> +local to an application.
>> +.P
>> +NFS clients cache file attributes, including timestamps.
>> +A file's timestamps are updated on NFS clients when its attributes
>> +are retrieved from the NFS server.
>> +Thus there may be some delay before timestamp updates
>> +on an NFS server appear to applications on NFS clients.
>> +.P
>> +To comply with the POSIX filesystem standard, the Linux NFS client
>> +relies on NFS servers to keep a file's
>> +.B mtime
>> +and
>> +.B ctime
>> +timestamps properly up to date.
>> +It does this by flushing local data changes to the server
>> +before reporting
>> +.B mtime
>> +to applications via system calls such as
>> +.BR stat (2).
>> +.P
>> +The Linux client handles
>> +.B atime
>> +updates more loosely, however.
>> +NFS clients maintain good performance by caching data,
>> +but that means that application reads, which normally update
>> +.BR atime ,
>> +are not reflected to the server where a file's
>> +.B atime
>> +is actually maintained.
>> +.P
>> +Because of this caching behavior,
>> +the Linux NFS client does not support generic atime-related mount options.
>> +See
>> +.BR mount (8)
>> +for details on these options.
>> +.P
>> +In particular, the
>> +.BR atime / noatime ,
>> +.BR diratime / nodiratime ,
>> +.BR relatime / norelatime ,
>> +and
>> +.BR strictatime / nostrictatime
>> +mount options have no effect on NFS mounts.
>> +.P
>> +.I /proc/mounts
>> +may report that the
>> +.B relatime
>> +mount option is set on NFS mounts, but in fact the
>> +.B atime
>> +semantics are always as described here, and are not like
>> +.B relatime
>> +semantics.
>> .SS "Directory entry caching"
>> The Linux NFS client caches the result of all NFS LOOKUP requests.
>> If the requested directory entry exists on the server,
>> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



