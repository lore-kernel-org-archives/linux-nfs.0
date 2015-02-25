Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:53055 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102AbbBYVrc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 16:47:32 -0500
Received: by mail-vc0-f170.google.com with SMTP id hq12so2518785vcb.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 13:47:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
	<CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
	<CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
	<CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
	<CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
Date: Wed, 25 Feb 2015 16:47:31 -0500
Message-ID: <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chris Perl <cperl@janestreet.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 25, 2015 at 4:02 PM, Chris Perl <cperl@janestreet.com> wrote:
>> So imagine 2 WRITE calls that are being sent to an initially empty
>> file. One WRITE call is for offset 0, and length 4096 bytes. The
>> second call is for offset 4096 and length 4096 bytes.
>> Imagine now that the first WRITE gets delayed (either because the page
>> cache isn't flushing that part of the file yet or because it gets
>> re-ordered in the RPC layer or on the server), and the second WRITE is
>> received and processed by the server first.
>> Once the delayed WRITE is processed there will be data at offset 0,
>> but until that happens, anyone reading the file on the server will see
>> a hole of length 4096 bytes.
>>
>> This kind of issue is why close-to-open cache consistency relies on
>> only one client accessing the file on the server when it is open for
>> writing.
>
> Fair enough.  I am taking note of the fact that you said "This kind of
> issue" implying there are probably other subtle cases I'm not thinking
> about or that your example does not illustrate.
>
> That said, in your example, there exists some moment in time when the
> file on the server actually does have a hole in it full of 0's.  In my
> case, the file never contains 0's.
>
> To be fair, when testing with an Isilon, I can't actually inspect the
> state of the file on the server in any meaningful way, so I can't be
> certain that's true.  But, from the view point of the reading client
> at the NFS layer there are never 0's read back across the wire.  I've
> confirmed this by matching up wireshark traces while reproducing and
> the READ reply's never contain 0's.  The 0's manifest due to reading
> too far past where there is valid data in the page cache.

Then that could be a GETATTR or something similar extending the file
size outside the READ rpc call. Since the pagecache data is copied to
userspace without any locks being held, we cannot prevent that race.
We're not going to push to fix that particular issue, since it is only
one of many possible races (see my previous example) when you try to
violate close-to-open cache consistency.

> Does this still fall under the "not expected to work" category because
> of the close-to-open issues you explained, or is there perhaps
> something to fix here because its entirely on the reading client side?

There is nothing to fix. The close-to-open cache consistency model is
clear that your applications must not access a file that is being
modified on another client or on the server.

If you choose to operate outside that caching model, then your
application needs to provide its own consistency. Usually, that means
either using POSIX file locking, or using O_DIRECT/uncached I/O in
combination with some other synchronisation method.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
