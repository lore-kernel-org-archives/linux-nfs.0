Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47565 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721Ab3JCJzO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 05:55:14 -0400
Date: Thu, 3 Oct 2013 02:55:11 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131003095511.GA30147@infradead.org>
References: <20130929114327.GB25750@infradead.org>
 <52481939.7060405@primarydata.com>
 <20130929121345.GA21083@infradead.org>
 <52481B11.2080407@primarydata.com>
 <20130929122130.GI21083@infradead.org>
 <20130929123553.GA7510@infradead.org>
 <20131001203047.GH16245@pad.fieldses.org>
 <524C0556.9070705@primarydata.com>
 <20131002160759.GB27988@infradead.org>
 <524D0873.40602@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524D0873.40602@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 03, 2013 at 09:02:27AM +0300, Benny Halevy wrote:
> Just that this is dlm specific logic.
> For example, using dlm_ino_hash() in nfsd4_pnfs_dlm_layoutget().
> Or even knowing that
> 	layout->lg_stripe_type = STRIPE_SPARSE;
> assumes knowledge of the underlying cluster fs implementation.

Which in-tree or soon in-tree filesystem do you care about?  And why
don't we see pnfs support for it submitted instead of the fairly useless
gfs2 support?

