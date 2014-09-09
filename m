Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:45593 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625AbaIIFtc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 01:49:32 -0400
Date: Tue, 9 Sep 2014 07:49:29 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 03/19] pnfs: force a layout commit when encountering
	busy segments during recall
Message-ID: <20140909054929.GA12459@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-4-git-send-email-hch@lst.de> <CAHQdGtQ5--A4_NJpJZ=VEkomCbFYM=6AitSEdexShvBk=aJsPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQ5--A4_NJpJZ=VEkomCbFYM=6AitSEdexShvBk=aJsPQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 08, 2014 at 05:37:42PM -0700, Trond Myklebust wrote:
> Why wouldn't it make more sense to call pnfs_layoutcommit_inode()
> unconditionally before the call to pnfs_mark_matching_lsegs_invalid()?

It would minimally reduce the latency, but otherwise be not very different.
The downside is that we'll now need two i_lock roundtrips per recall.

But if this is your preference I can easily fix it up.
