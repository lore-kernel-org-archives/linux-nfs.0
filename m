Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59922 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbcEYSUD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 14:20:03 -0400
Date: Wed, 25 May 2016 14:20:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thomas Haynes <loghyr@primarydata.com>
Cc: hch <hch@lst.de>, Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/4] nfsd: Can leak pnfs_block_extent on error
Message-ID: <20160525182001.GB12306@fieldses.org>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
 <1464152979-103988-3-git-send-email-loghyr@primarydata.com>
 <20160525150724.GA27535@lst.de>
 <308154CA-0C3A-4D4F-82F0-6E2F221DBC18@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <308154CA-0C3A-4D4F-82F0-6E2F221DBC18@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 25, 2016 at 06:12:25PM +0000, Thomas Haynes wrote:
> 
> > On May 25, 2016, at 8:07 AM, Christoph Hellwig <hch@lst.de> wrote:
> > 
> > On Tue, May 24, 2016 at 10:09:37PM -0700, Tom Haynes wrote:
> >> Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> > 
> > How was this reported?
> 
> Code inspection. My guess is no one ever hit the error cases
> in there.
> 
> > 
> > Like other NFS procedures the private data should be freed by the
> > XDR encode callback (nfsd4_encode_layoutget in this case) even
> > in the error case.  It could be that there is a bug somewhere,
> > but it probably shouldn't be fixed here.
> > 
> 
> No, it doesn’t do that on errors:

We have in nfsd4_block_proc_layoutget:

	bex = kzalloc(sizeof(*bex), GFP_KERNEL);
	if (!bex)
		goto out_error;
	args->lg_content = bex;

and then in nfsd4_encode_layoutget:

	kfree(lgp->lg_content);

So, I think we're OK as is?

--b.


> 
> nfsd4_layoutget():
> 
>        nfserr = ops->proc_layoutget(d_inode(current_fh->fh_dentry),
>                                      current_fh, lgp);
>         if (nfserr)
>                 goto out_put_stid;
> 
>         nfserr = nfsd4_insert_layout(lgp, ls);
> 
> out_put_stid:
>         mutex_unlock(&ls->ls_mutex);
>         nfs4_put_stid(&ls->ls_stid);
> out:
>         return nfserr;
> }
> 
> So on error we never do anything with the lgp and the memory would
> be dropped.
