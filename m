Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51831 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbaGOHtr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 03:49:47 -0400
Date: Tue, 15 Jul 2014 00:49:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH/RFC] NFS: state manager thread must start running.
Message-ID: <20140715074942.GA6166@infradead.org>
References: <20140715163942.1d94304f@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140715163942.1d94304f@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 04:39:42PM +1000, NeilBrown wrote:
> I suggested in an earlier email that it might be possible to use a
> work-queue for this.  I concluded that it wasn't a good idea.
> If a server was down, the manager cold block indefinitely.
> If memory was tight and only one workqueue thread was active,
> this would block other NFS mounts.

So allocate one workqueue per mount?

