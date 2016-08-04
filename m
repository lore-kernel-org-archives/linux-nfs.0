Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:32903 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756378AbcHDMrl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2016 08:47:41 -0400
Date: Thu, 4 Aug 2016 05:47:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, fdmanana@kernel.org,
        linux-btrfs@vger.kernel.org, NFS List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] exportfs: be careful to only return expected errors.
Message-ID: <20160804124719.GA5676@infradead.org>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org>
 <874m7i8oou.fsf@notabene.neil.brown.name>
 <20160722015904.GB29969@fieldses.org>
 <87bn1q75ut.fsf@notabene.neil.brown.name>
 <20160722200843.GA7463@fieldses.org>
 <877fbxperp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <877fbxperp.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 04, 2016 at 10:19:06AM +1000, NeilBrown wrote:
> 
> 
> When nfsd calls fh_to_dentry, it expect ESTALE or ENOMEM as errors.
> In particular it can be tempting to return ENOENT, but this is not
> handled well by nfsd.
> 
> Rather than requiring strict adherence to error code code filesystems,
> treat all unexpected error codes the same as ESTALE.  This is safest.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> I didn't add a dprintk for unexpected error messages, partly
> because dprintk isn't usable in exportfs.  I could have used pr_debug()
> but I really didn't see much value.
> 
> This has been tested together with the btrfs change, and it restores
> correct functionality.

I don't really like all this magic which is partially historic.  I think
we should instead allow the fs to return any error from the export
operations, and forbid returning NULL entirely.  Then the actualy caller
(nfsd) can sort out which errors it wants to send over the wire.
