Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45077 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab0LUP0j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Dec 2010 10:26:39 -0500
Date: Tue, 21 Dec 2010 10:26:39 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 04/14] pnfs: wave 2: change layout state seqlock to a
 spinlock
Message-ID: <20101221152639.GC30248@infradead.org>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
 <1292898046-7336-5-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292898046-7336-5-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 20, 2010 at 09:20:36PM -0500, Fred Isaman wrote:
> This prepares for future changes, where the layout state needs
> to change atomically with several other variables.  In particular,
> it will need to know if lo->segs is empty, as we test that instead
> of manipulating the NFS_LAYOUT_STATEID_SET bit.  Moreover, the
> layoutstateid is not really a read-mostly structure, as it is
> written almost as often as it is read.

It also renames a couple of functions.

