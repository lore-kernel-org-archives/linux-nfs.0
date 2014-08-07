Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:35217 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303AbaHGMKz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 08:10:55 -0400
Date: Thu, 7 Aug 2014 14:10:52 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        "faibish, sorin" <faibish_sorin@emc.com>
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger
	than page size
Message-ID: <20140807121052.GA5678@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-9-git-send-email-hch@lst.de> <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com> <20140807112537.GA3437@lst.de> <CA+a=Yy4muAYw8KjZcFh4NMwOOizD=gNXNeweLHix46vjQoS53Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+a=Yy4muAYw8KjZcFh4NMwOOizD=gNXNeweLHix46vjQoS53Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 07, 2014 at 07:51:57PM +0800, Peng Tao wrote:
> Is it bl_find_get_zeroing_page() you are concerning about?

That's the primary culprit.

If you want to do the read-modify write cycle properly you'll have to
do it at the time the invalid extent is read, not written.  Take a look
at my patch to add a flag to do that in page 5, although it would
be a lot more involved to do it for large pnfs block sizes.  Given
that the code never really fully worked beforehand I'm not tempted
to come up with that myself, though.

