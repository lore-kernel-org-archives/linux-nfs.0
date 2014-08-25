Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:40813 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932233AbaHYOJy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 10:09:54 -0400
Date: Mon, 25 Aug 2014 16:09:52 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/19] pnfs: add return_range method
Message-ID: <20140825140952.GA13911@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-9-git-send-email-hch@lst.de> <53FB3F2A.409@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53FB3F2A.409@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 25, 2014 at 09:50:34AM -0400, Anna Schumaker wrote:
> > +	} else {
> > +		if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
> > +			NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
> > +				&args->cbl_range);
> > +		}
> >  	}
> Is there a reason you're nesting the else-if here?

To catch the intent - the first two clauses find excuses why we can't return
quite yet, while this if is for an optional feature in the actual return
path. If I wasn't updating but newly writing the function I'd actually
do something like:

	...

	rv = NFS4ERR_DELAY;
	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
		goto out_set_stateid;

	if (pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
			&args->cbl_range)) {
		need_commit = true;
		goto out_set_stateid;
	}

	rv = NFS4ERR_NOMATCHING_LAYOUT;
	if (NFS_SERVER(ino)->pnfs_curr_ld->return_range) {
		NFS_SERVER(ino)->pnfs_curr_ld->return_range(lo,
				&args->cbl_range);
	}

out_set_stateid:
	...

