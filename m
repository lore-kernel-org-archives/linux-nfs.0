Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:35130 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416AbaHGLZm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 07:25:42 -0400
Date: Thu, 7 Aug 2014 13:25:37 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        "faibish, sorin" <faibish_sorin@emc.com>
Subject: Re: [PATCH 08/17] pnfs/blocklayout: reject pnfs blocksize larger
	than page size
Message-ID: <20140807112537.GA3437@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de> <1407396229-4785-9-git-send-email-hch@lst.de> <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CA+a=Yy42e46zA+X-VQQj9RAzZ4T+A7dOOrjUMVONsh8Pt8QdcQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 07, 2014 at 06:43:14PM +0800, Peng Tao wrote:
> So this kills EMC server support.

Given the state the code  claiming support for any server is a large
exaggeration..

> Can you please share what kind of
> badly deadlock you saw with large block size support?

The read-modify write code (which I'll remove later) can lock arbitary
numbers of additional pages from the writeback back code without doing
a trylock, which is required for doing this in page writeback.  Note
that it's not a deadlock, but I can also trivіally corrupt data in
those pages as it doesn't lock against them, you just need a race
window where it's modified after writeback has been started for a large
extents, which isn't too hard to hit with tools like fsstress.

