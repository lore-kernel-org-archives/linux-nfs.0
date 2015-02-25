Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f181.google.com ([209.85.220.181]:49010 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbbBYRhY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 12:37:24 -0500
Received: by mail-vc0-f181.google.com with SMTP id im6so1900916vcb.12
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 09:37:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
	<CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
	<CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
Date: Wed, 25 Feb 2015 12:37:23 -0500
Message-ID: <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chris Perl <cperl@janestreet.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 25, 2015 at 12:04 PM, Chris Perl <cperl@janestreet.com> wrote:
>> That's expected behaviour, yes. NFS close-to-open cache consistency
>> semantics do not allow for concurrent access while the file is being
>> updated.
>
> Can you elaborate on that a bit?
>
> My rough understanding of close-to-open cache consistency is basically
> that a clients changes are not guaranteed to be on the server until a
> close(2) and that a client is only guaranteed to check for updates on
> open(2).
>
> I can therefore see why one client reading while another is appending
> could result in stale data being read from the cache (and indeed, this
> is the reason the test program I provided continually open and closes
> the file, seeking as necessary).  But I'm having a hard time seeing
> why close-to-open cache consistency allows for returning data from the
> cache that never existed in the file.

So imagine 2 WRITE calls that are being sent to an initially empty
file. One WRITE call is for offset 0, and length 4096 bytes. The
second call is for offset 4096 and length 4096 bytes.
Imagine now that the first WRITE gets delayed (either because the page
cache isn't flushing that part of the file yet or because it gets
re-ordered in the RPC layer or on the server), and the second WRITE is
received and processed by the server first.
Once the delayed WRITE is processed there will be data at offset 0,
but until that happens, anyone reading the file on the server will see
a hole of length 4096 bytes.

This kind of issue is why close-to-open cache consistency relies on
only one client accessing the file on the server when it is open for
writing.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
