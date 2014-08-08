Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:45841 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594AbaHHK3Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 06:29:16 -0400
Received: by mail-ig0-f178.google.com with SMTP id uq10so792356igb.17
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 03:29:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140807162059.GA23188@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-9-git-send-email-hch@lst.de>
 <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com>
 <20140807112537.GA3437@lst.de> <CA+a=Yy4muAYw8KjZcFh4NMwOOizD=gNXNeweLHix46vjQoS53Q@mail.gmail.com>
 <20140807121052.GA5678@lst.de> <CA+a=Yy4YmBzYFUTHb72hyZ1--N_w6YDZhmbFEAU11YTt+1qxOg@mail.gmail.com>
 <20140807162059.GA23188@lst.de>
From: Peng Tao <bergwolf@gmail.com>
Date: Fri, 8 Aug 2014 18:28:56 +0800
Message-ID: <CA+a=Yy5YRTnTwoO4HUAAJnRbwdwT1o7Gvr2Ke=dZq9gOX8X2fA@mail.gmail.com>
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger than
 page size
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        "faibish, sorin" <faibish_sorin@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 8, 2014 at 12:20 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Thu, Aug 07, 2014 at 09:43:09PM +0800, Peng Tao wrote:
>> we can't assume all pages written back have their pari pages (for 8K
>> block size e.g.) read in read_pagelists(). A page can also be read in
>> via MDS read. So what we need is a hook into nfs_readpage to read or
>> zero additional pages. But we might not even have a layout there.
>
> We can't assume the page is there for writeback either, what all this
> mess exists for.
In write_pagelist, we can find or create the pair page. It is indeed
cow extent that makes things complicated by requiring to read from
disk. If we drop cow support (which is required by rfc but I don't
know of any server that supports it), we can just zero the extra pages
and mark them uptodate. No extra read in or writeback required. That
is doable IMHO.

> That's why we really shouldn't even attempt to support
> a a block size large than the page size, and that's also why the local
> Linux filesystems strictly refuse to support it.  If you want to hack
> around it you will run into problems in either case.
>
> I also don't really see why a server would insist on this large block
> size, there really isn't any major benefit in doing that today (aka the last 20
> years) now that we have extent based filesystems.
