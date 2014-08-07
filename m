Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35115 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757353AbaHGNna (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 09:43:30 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so10365840igb.8
        for <linux-nfs@vger.kernel.org>; Thu, 07 Aug 2014 06:43:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140807121052.GA5678@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-9-git-send-email-hch@lst.de>
 <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com>
 <20140807112537.GA3437@lst.de> <CA+a=Yy4muAYw8KjZcFh4NMwOOizD=gNXNeweLHix46vjQoS53Q@mail.gmail.com>
 <20140807121052.GA5678@lst.de>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 7 Aug 2014 21:43:09 +0800
Message-ID: <CA+a=Yy4YmBzYFUTHb72hyZ1--N_w6YDZhmbFEAU11YTt+1qxOg@mail.gmail.com>
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger than
 page size
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        "faibish, sorin" <faibish_sorin@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 7, 2014 at 8:10 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Thu, Aug 07, 2014 at 07:51:57PM +0800, Peng Tao wrote:
>> Is it bl_find_get_zeroing_page() you are concerning about?
>
> That's the primary culprit.
>
> If you want to do the read-modify write cycle properly you'll have to
> do it at the time the invalid extent is read, not written.  Take a look
> at my patch to add a flag to do that in page 5, although it would
> be a lot more involved to do it for large pnfs block sizes.  Given
> that the code never really fully worked beforehand I'm not tempted
> to come up with that myself, though.
>
we can't assume all pages written back have their pari pages (for 8K
block size e.g.) read in read_pagelists(). A page can also be read in
via MDS read. So what we need is a hook into nfs_readpage to read or
zero additional pages. But we might not even have a layout there.
