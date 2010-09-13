Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55599 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab0IMOor (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 10:44:47 -0400
Date: Mon, 13 Sep 2010 10:44:44 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
Message-ID: <20100913144444.GA31105@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
 <1283450419-5648-8-git-send-email-iisaman@netapp.com>
 <1284146604.10062.68.camel@heimdal.trondhjem.org>
 <4C8E05CD.7090407@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C8E05CD.7090407@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 13, 2010 at 01:06:53PM +0200, Boaz Harrosh wrote:
> Me two BTW.
> I will later need a per super-block resources, mainly slabs and work_q.

Slab caches are always globals, as should workqueues be.  With Tejun's
recent work most work queues should go away completely.

> I think we should just pass nfss to the LD and let it take care of accessing
> nfss->nfs_client for the device cache. (It is done so later in the tree, right?)

You can add this later once a laypout driver actually needing it is
introduced.

