Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47907 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757551Ab2BIIhX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2012 03:37:23 -0500
Received: by wgbdt10 with SMTP id dt10so1451901wgb.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Feb 2012 00:37:22 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20120208210150.GB29238@umich.edu>
References: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
	<20120208162322.GA13315@fieldses.org>
	<1328722042.3234.13.camel@lade.trondhjem.org>
	<20120208174901.GA28564@umich.edu>
	<20120208183151.GA14316@fieldses.org>
	<20120208203140.GA29238@umich.edu>
	<1328734255.3234.32.camel@lade.trondhjem.org>
	<20120208210150.GB29238@umich.edu>
Date: Thu, 9 Feb 2012 09:37:22 +0100
Message-ID: <CAGue13qU7OJ+Obnc0vtGt8_2BsydeOXmwhHNzctJbWitV4AVvA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] NFSv4.1: Convert slotid from u8 to u32
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Jim Rees <rees@umich.edu>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Putting my 'high energy physics community' hat on let me comment on it.

As soon as we trying to use nfs over high latency networks the
application efficiency rapidly drops. Efficiency is wallTIme/cpuTime.
We have solve this in our home grown protocols by adding vector read
and vector write. Vector is set of offset_length. As most of the our
files has DB like structure, after reading header (something like
index) we knew where data is located. This allows us to perform in
some work loads 100 times better than NFS.

Posix does not provides such interface. But we can simulate that with
fadvise calls (and we do). Since nfs-4.0 we got compound  operations.
And you can (in theory) build a compound with multiple READ or WRITE
ops. Nevertheless this does not work for several reasons: maximal
reply size and you still have to wait for full reply. and some reply
may be up 100MB in size.

The solution here is to issue multiple requests in parallel. And this
is possible only if you have enough session slots. Server can reply
out of order and populate clients file system cache.

Tigran.

On Wed, Feb 8, 2012 at 10:01 PM, Jim Rees <rees@umich.edu> wrote:
> Myklebust, Trond wrote:
>
>  On Wed, 2012-02-08 at 15:31 -0500, Jim Rees wrote:
>  > J. Bruce Fields wrote:
>  >
>  >   On Wed, Feb 08, 2012 at 12:49:01PM -0500, Jim Rees wrote:
>  >   > Myklebust, Trond wrote:
>  >   >
>  >   >   10GigE + high latencies is exactly where we're seeing the value. Andy
>  >   >   has been working with the high energy physics community doing NFS
>  >   >   traffic between the US and CERN...
>  >   >
>  >   > CITI to CERN is just over 120ms.  I don't know what it would be from Andy's
>  >   > house.  Does he have 10G at home yet?
>  >
>  >   That still seems short of what you'd need to get a 255MB bandwidth-delay
>  >   product.
>  >
>  >   I'm just curious what the experiment is here and whether there's a
>  >   possibility the real problem is elsewhere.
>  >
>  > In my opinion, any fix that involves allocating multiple parallel data
>  > streams (rpc slots, tcp connections) is masking the real problem.  But it's
>  > an effective fix.
>
>  Who said anything about multiple tcp connections? All the slots do is
>  allow the server to process more RPC calls in parallel by feeding it
>  more work. How is that masking a problem?
>
> Sorry, the comma was intended to be "or".  I realize there is just one tcp
> connection.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
