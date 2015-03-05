Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:37458 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbCEUSC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2015 15:18:02 -0500
Received: by mail-vc0-f180.google.com with SMTP id le20so12273326vcb.11
        for <linux-nfs@vger.kernel.org>; Thu, 05 Mar 2015 12:18:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150305184238.GD15674@fieldses.org>
References: <20150305155511.26051.93398.stgit@manet.1015granger.net>
	<20150305184238.GD15674@fieldses.org>
Date: Thu, 5 Mar 2015 15:18:00 -0500
Message-ID: <CAHQdGtSrJS6XEegy7COxBijMKg5UTMa8nCopfFnWGrF2FaxXPA@mail.gmail.com>
Subject: Re: [PATCH] nfs(5): Update close-to-open discussion in DATA AND
 METADATA COHERENCY
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 5, 2015 at 1:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Mar 05, 2015 at 11:06:37AM -0500, Chuck Lever wrote:
>> The discussion of close-to-open describes the GETATTR and data flush
>> behavior implemented on the Linux client, but does not describe what
>> happens between open() and close(). The lack of strict cache
>> coherency surprises users who expect single-system behavior
>> similar to local file systems.
>>
>> An explicit description of this behavior is inserted.  Additional
>> clarifications are made of the surrounding text.
>>
>> Text contributed by Trond, Bruce, Chuck, and Chris Perl.
>>
>> Link: http://marc.info/?l=linux-nfs&m=142472673425307&w=2
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Hi-
>>
>> TBH I'm more concerned about nfs(5) than I am about the antique NFS
>> FAQ. Besides, my sf.net login expired long ago, after I retired from
>> FAQ maintenance.
>
> If someone wanted to just copy the whole thing over to the linux-nfs.org
> wiki, I'd support that.
>
>> Thus I'm proposing this change to nfs(5). Then I'd like to suggest
>> eventually replacing the bulk of FAQ A8 with a pointer to the DATA
>> AND METADATA COHERENCE section of nfs(5).
>
> Moving it to the man pages sounds fine to me too, though.
>
>> Comments?
>
> We're leading with the mechanism (flushing and attribute checking),
> which I think encourages people to reason starting from the
> implementation.  We know that's difficult.
>
> I'd rather lead with a conservative black-box explanation of what
> applications can and cannot depend on.
>

This should be the case here. Exactly what are we saying that you
believe goes beyond the close-to-open caching model?

>>
>>  utils/mount/nfs.man |   29 ++++++++++++++++++++++-------
>>  1 file changed, 22 insertions(+), 7 deletions(-)
>>
>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>> index fe4f9b1..4df8a16 100644
>> --- a/utils/mount/nfs.man
>> +++ b/utils/mount/nfs.man
>> @@ -1148,9 +1148,11 @@ is expensive to achieve, especially on wide area networks.
>>  As such, NFS settles for weaker cache coherence that
>>  satisfies the requirements of most file sharing types.
>>  .SS "Close-to-open cache consistency"
>> -Typically file sharing is completely sequential.
>> -First client A opens a file, writes something to it, then closes it.
>> -Then client B opens the same file, and reads the changes.
>> +Typically applications share files in a sequential manner.
>> +First application A opens a file, writes something to it, then closes it.
>> +Then application B opens the same file, and reads the changes.
>> +This typical sharing behavior is leveraged to keep NFS operations
>> +from multiple clients fast.
>>  .P
>>  When an application opens a file stored on an NFS version 3 server,
>>  the NFS client checks that the file exists on the server
>> @@ -1165,14 +1167,27 @@ This also gives the NFS client an opportunity to report
>>  write errors to the application via the return code from
>>  .BR close (2).
>>  .P
>> -The behavior of checking at open time and flushing at close time
>> -is referred to as
>> +To maintain good performance, the NFS client only occasionally checks
>> +whether its cache remains valid between open() and close().
>> +.P
>> +The behavior of checking a file at open time and flushing at close time,
>> +with relaxed consistency checking in between, is referred to as
>>  .IR "close-to-open cache consistency" ,
>>  or
>>  .IR CTO .
>> -It can be disabled for an entire mount point using the
>> +.P
>> +Note that applications cannot rely on implicit cache revalidation
>> +while a file is held open.
>> +If an open file changes on the NFS server, read() on clients may return
>> +stale data or holes, unless the application explicitly serializes
>> +file changes with reads using file locking or some other technique.
>> +.P
>> +In rare cases, sending a GETATTR on every open()
>> +may still be too much overhead.
>> +Close-to-open can be relaxed further
>> +for an entire NFS version 3 mount point using the
>>  .B nocto
>> -mount option.
>> +mount option, at the cost of even weaker client cache coherence.
>>  .SS "Weak cache consistency"
>>  There are still opportunities for a client's data cache
>>  to contain stale data.
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
