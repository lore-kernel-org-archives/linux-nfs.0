Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:58834 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082AbbCCRoF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 12:44:05 -0500
Received: by mail-vc0-f182.google.com with SMTP id hy4so1095627vcb.13
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 09:44:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <A6E54346-E80D-48B4-B0DF-D646376B42E8@oracle.com>
References: <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
	<CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
	<CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
	<CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
	<CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
	<CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>
	<20150227224029.GA8750@fieldses.org>
	<0836BFA3-1F2D-4CD0-AB25-3DBA916D941C@oracle.com>
	<CAAih9mgZd=-L0Yj=4G4UmqW3fsGKiJtXsK8S8Steme4niguptQ@mail.gmail.com>
	<DCF31069-FEF7-4DD8-9FD0-575262181A43@oracle.com>
	<20150302205850.GG8033@fieldses.org>
	<3E668056-0C9D-440D-86E5-CCB5AF74D7A7@oracle.com>
	<CAAih9mieawzDqPU=6YEJAM=MbS-f3RdOckL_bSKG7fXDm2CSKQ@mail.gmail.com>
	<A6E54346-E80D-48B4-B0DF-D646376B42E8@oracle.com>
Date: Tue, 3 Mar 2015 12:44:03 -0500
Message-ID: <CAHQdGtSWqhhXMzvQ9Z3hr=t0Xu7z4D9o=qQn2YaDSYmyxxWqtQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Chris Perl <cperl@janestreet.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 3, 2015 at 10:30 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Mar 3, 2015, at 8:29 AM, Chris Perl <cperl@janestreet.com> wrote:
>
>> Just to quickly answer the earlier question about whether I have
>> received a good answer from this list:  Yes, I have, and I appreciate
>> all the time and discussion spent helping me understand what I've been
>> seeing.
>>
>>> I read Chris’s e-mail as a request for more detail in the answer
>>> I proposed before. Maybe I’m wrong.
>>>
>>> Is this not sufficient:
>>>
>>> “Because NFS is not a cluster or “single system image” filesystem,
>>> applications must provide proper serialization of reads and writes
>>> among multiple clients to ensure correct application behavior and
>>> prevent corruption of file data. The close-to-open mechanism is not
>>> adequate in the presence of concurrent opens for write when multiple
>>> clients are involved.”
>>>
>>> Perhaps the “presence of concurrent opens for write” should be
>>> replaced with “presence of concurrent writes.” But what else needs
>>> to be said?
>>
>> I'm trying to decide if, having read the above in the FAQ, it would
>> have been obvious to me that what I was seeing was expected.
>
> That’s exactly the right question to ask.
>
>> I don't
>> know that it would have been.  That paragraph seems to impart to me
>> the idea that if you don't synchronize your readers and writers you
>> might get weird results, much like a local file system.  However, I
>> thought the way in which my updates were happening made this ok, as I
>> was only ever appending data to a given file.
>>
>> I guess I was hoping for something more along the lines of (this would
>> be meant to be inserted after paragraph 6 of A8 in the FAQ):
>>
>> Furthermore, in the presence of multiple clients, at least one of
>> which is writing to a given file, close-to-open cache consistency
>> makes no guarantee's about the data that might be returned from the
>> cache on a client issuing reads concurrent with those writes.  It may
>> return stale data or it may return incorrect data.
>
> This works for me. Bruce, Trond, any thoughts?
>

I'd say we can give stronger advice. As I said earlier, close-to-open
is a known model that is implemented by most NFS clients that want to
cache data, so I see no reason not to go into more detail. If ever we
change the Linux client behaviour in ways that differ, then we can no
longer claim to be doing close-to-open.

So here are the things we can document:

1) The client will revalidate its cached attributes and data on
open(). If the file or directory has changed on the server, the data
cache will be invalidated/flushed.
2) The client will revalidate its cached attributes on close().
3) Between open() and close(), the behaviour w.r.t. cache revalidation
is undefined. The client may on occasion check whether or not its
cached data is valid, but applications must not rely on such
behaviour. If the file is changed on the server during that time, then
the behaviour of read()/readdir() on the client is undefined. In
particular, note that read() may return stale data and/or holes.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
