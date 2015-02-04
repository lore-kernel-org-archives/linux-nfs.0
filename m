Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:56744 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966585AbbBDRf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 12:35:29 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so4077014pad.7
        for <linux-nfs@vger.kernel.org>; Wed, 04 Feb 2015 09:35:28 -0800 (PST)
Date: Wed, 4 Feb 2015 09:35:26 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 44/53] nfs41: introduce NFS_LAYOUT_RETURN_BEFORE_CLOSE
Message-ID: <20150204173525.GA50870@kitty.kitty>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
 <1422916747-86649-45-git-send-email-loghyr@primarydata.com>
 <54D2546F.1030206@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54D2546F.1030206@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 04, 2015 at 12:18:39PM -0500, Anna Schumaker wrote:
> Hi Tao and Tom,
> 
> On 02/02/2015 05:38 PM, Tom Haynes wrote:
> > From: Peng Tao <tao.peng@primarydata.com>
> > 
> > When it is set, generic pnfs would try to send layoutreturn right
> > before last close/delegation_return regard less NFS_LAYOUT_ROC is
> > set or not. LD can then make sure layoutreturn is always sent
> > rather than being omitted.
> > 
> > The difference against NFS_LAYOUT_RETURN is that
> > NFS_LAYOUT_RETURN_BEFORE_CLOSE does not block usage of the layout so
> > LD can set it and expect generic layer to try pnfs path at the
> > same time.
> > 
> > Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> > Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> > ---
> >  fs/nfs/nfs4proc.c |  2 ++
> >  fs/nfs/pnfs.c     | 40 +++++++++++++++++++++++++++++++++-------
> >  fs/nfs/pnfs.h     |  1 +
> >  3 files changed, 36 insertions(+), 7 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 2397c0f..7e1a97a 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -7797,6 +7797,8 @@ static void nfs4_layoutreturn_release(void *calldata)
> >  	if (lrp->res.lrs_present)
> >  		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
> >  	clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
> > +	clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE, &lo->plh_flags);
> > +	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
> >  	lo->plh_block_lgets--;
> >  	spin_unlock(&lo->plh_inode->i_lock);
> >  	pnfs_put_layout_hdr(lrp->args.layout);
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index 0a0e209..d3c2ca7 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -909,6 +909,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
> >  		status = -ENOMEM;
> >  		spin_lock(&ino->i_lock);
> >  		lo->plh_block_lgets--;
> > +		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
> >  		spin_unlock(&ino->i_lock);
> >  		pnfs_put_layout_hdr(lo);
> >  		goto out;
> > @@ -926,11 +927,6 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
> >  
> >  	status = nfs4_proc_layoutreturn(lrp, sync);
> >  out:
> > -	if (status) {
> > -		spin_lock(&ino->i_lock);
> > -		clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
> > -		spin_unlock(&ino->i_lock);
> > -	}
> >  	dprintk("<-- %s status: %d\n", __func__, status);
> >  	return status;
> >  }
> > @@ -1028,8 +1024,9 @@ bool pnfs_roc(struct inode *ino)
> >  {
> >  	struct pnfs_layout_hdr *lo;
> >  	struct pnfs_layout_segment *lseg, *tmp;
> > +	nfs4_stateid stateid;
> >  	LIST_HEAD(tmp_list);
> > -	bool found = false;
> > +	bool found = false, layoutreturn = false;
> >  
> >  	spin_lock(&ino->i_lock);
> >  	lo = NFS_I(ino)->layout;
> > @@ -1050,7 +1047,20 @@ bool pnfs_roc(struct inode *ino)
> >  	return true;
> >  
> >  out_nolayout:
> > +	if (lo) {
> > +		stateid = lo->plh_stateid;
> > +		layoutreturn =
> > +			test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
> > +					   &lo->plh_flags);
> > +		if (layoutreturn) {
> > +			lo->plh_block_lgets++;
> > +			pnfs_get_layout_hdr(lo);
> > +		}
> > +	}
> >  	spin_unlock(&ino->i_lock);
> > +	if (layoutreturn)
> > +		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
> > +				       NFS4_MAX_UINT64, true);
> 
> What are the extra arguments to pnfs_send_layoutreturn() here?  My compiler isn't happy:

Hi Anna,

So the next patch fixes this up. :-)

I think this was from the review comment you had about not passing these
down into pnfs_send_layoutreturn().

Tom



> 
> fs/nfs/pnfs.c: In function 'pnfs_roc':
> fs/nfs/pnfs.c:1062:3: error: too many arguments to function 'pnfs_send_layoutreturn'
>    pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
>    ^
> fs/nfs/pnfs.c:900:1: note: declared here
>  pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
>  ^
> fs/nfs/pnfs.c: In function 'pnfs_roc_drain':
> fs/nfs/pnfs.c:1130:3: error: too many arguments to function 'pnfs_send_layoutreturn'
>    pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
>    ^
> fs/nfs/pnfs.c:900:1: note: declared here
>  pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
>  ^
> scripts/Makefile.build:257: recipe for target 'fs/nfs/pnfs.o' failed
> 
> Thanks,
> Anna
> >  	return false;
> >  }
> >  
> > @@ -1085,8 +1095,9 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
> >  	struct nfs_inode *nfsi = NFS_I(ino);
> >  	struct pnfs_layout_hdr *lo;
> >  	struct pnfs_layout_segment *lseg;
> > +	nfs4_stateid stateid;
> >  	u32 current_seqid;
> > -	bool found = false;
> > +	bool found = false, layoutreturn = false;
> >  
> >  	spin_lock(&ino->i_lock);
> >  	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list)
> > @@ -1103,7 +1114,22 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
> >  	 */
> >  	*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
> >  out:
> > +	if (!found) {
> > +		stateid = lo->plh_stateid;
> > +		layoutreturn =
> > +			test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
> > +					   &lo->plh_flags);
> > +		if (layoutreturn) {
> > +			lo->plh_block_lgets++;
> > +			pnfs_get_layout_hdr(lo);
> > +		}
> > +	}
> >  	spin_unlock(&ino->i_lock);
> > +	if (layoutreturn) {
> > +		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
> > +		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
> > +				       NFS4_MAX_UINT64, false);
> > +	}
> >  	return found;
> >  }
> >  
> > diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> > index 443d199..c383dd5 100644
> > --- a/fs/nfs/pnfs.h
> > +++ b/fs/nfs/pnfs.h
> > @@ -96,6 +96,7 @@ enum {
> >  	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
> >  	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
> >  	NFS_LAYOUT_RETURN,		/* Return this layout ASAP */
> > +	NFS_LAYOUT_RETURN_BEFORE_CLOSE,	/* Return this layout before close */
> >  	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
> >  	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
> >  };
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
