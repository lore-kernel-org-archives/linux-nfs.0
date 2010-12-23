Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3097 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab0LWTZ2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 14:25:28 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBNJPPpr009875
	for <linux-nfs@vger.kernel.org>; Thu, 23 Dec 2010 11:25:25 -0800 (PST)
Subject: Re: [PATCH 13/15] pnfs: add CB_LAYOUTRECALL handling
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1293125397-30088-14-git-send-email-iisaman@netapp.com>
References: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
	 <1293125397-30088-14-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 23 Dec 2010 14:25:24 -0500
Message-ID: <1293132324.2938.47.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-23 at 12:29 -0500, Fred Isaman wrote:
> This is the heart of the wave 2 submission.  Add the code to trigger
> drain and forget of any afected layouts.  In addition, we set a
> "barrier", below which any LAYOUTGET reply is ignored.  This is to
> compensate for the fact that we do not wait for outstanding LAYOUTGETs
> to complete as per section 12.5.5.2.1 of RFC 5661.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/callback_proc.c |  119 +++++++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfs/nfs4_fs.h       |    1 +
>  fs/nfs/pnfs.c          |   84 ++++++++++++++++++++++++++--------
>  fs/nfs/pnfs.h          |   12 +++++
>  4 files changed, 196 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index c1bb157..a8e8e20 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -12,6 +12,7 @@
>  #include "callback.h"
>  #include "delegation.h"
>  #include "internal.h"
> +#include "pnfs.h"
>  
>  #ifdef NFS_DEBUG
>  #define NFSDBG_FACILITY NFSDBG_CALLBACK
> @@ -107,10 +108,126 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
>  
>  #if defined(CONFIG_NFS_V4_1)
>  
> +static int initiate_layout_draining(struct nfs_client *clp,
          ^^^ u32

> +				    struct cb_layoutrecallargs *args)
> +{
> +	struct pnfs_layout_hdr *lo;
> +	int rv = NFS4ERR_NOMATCHING_LAYOUT;
          ^^^ u32

> +
> +	if (args->cbl_recall_type == RETURN_FILE) {
> +		LIST_HEAD(free_me_list);
> +
> +		args->cbl_inode = NULL;
> +		spin_lock(&clp->cl_lock);
> +		list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
> +			if (nfs_compare_fh(&args->cbl_fh,
> +					   &NFS_I(lo->plh_inode)->fh))
> +				continue;
> +			if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
> +				rv = NFS4ERR_DELAY;
> +			else {
> +				/* Without this, layout can be freed as soon
> +				 * as we release cl_lock.  Matched in
> +				 * do_callback_layoutrecall.
> +				 */
> +				get_layout_hdr(lo);
> +				args->cbl_inode = lo->plh_inode;
> +				rv = NFS4_OK;
> +			}
> +			break;
> +		}
> +		spin_unlock(&clp->cl_lock);
> +
> +		spin_lock(&lo->plh_inode->i_lock);

What guarantees do you have that the inode still exists here? Does the
layout segment hold a reference to it?

Also, How do you know that (!test_bit(NFS_LAYOUT_BULK_RECALL,
&lo->plh_flags)) is still valid when you get here?

> +		if (rv == NFS4_OK) {
> +			lo->plh_block_lgets++;
> +			mark_matching_lsegs_invalid(lo, &free_me_list,
> +						    args->cbl_range.iomode);
> +			if (list_empty(&lo->plh_segs))
> +				rv = NFS4ERR_NOMATCHING_LAYOUT;
> +		}
> +		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
> +		spin_unlock(&lo->plh_inode->i_lock);
> +		pnfs_free_lseg_list(&free_me_list);
> +	} else {
> +		struct pnfs_layout_hdr *tmp;
> +		LIST_HEAD(recall_list);
> +		LIST_HEAD(free_me_list);
> +		struct pnfs_layout_range range = {
> +			.iomode = IOMODE_ANY,
> +			.offset = 0,
> +			.length = NFS4_MAX_UINT64,
> +		};
> +
> +		spin_lock(&clp->cl_lock);
> +		list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
> +			if ((args->cbl_recall_type == RETURN_FSID) &&
> +			    memcmp(&NFS_SERVER(lo->plh_inode)->fsid,
> +				   &args->cbl_fsid, sizeof(struct nfs_fsid)))
> +				continue;
> +			get_layout_hdr(lo);
> +			BUG_ON(!list_empty(&lo->plh_bulk_recall));
> +			list_add(&lo->plh_bulk_recall, &recall_list);
> +		}
> +		spin_unlock(&clp->cl_lock);
> +		list_for_each_entry_safe(lo, tmp,
> +					 &recall_list, plh_bulk_recall) {
> +			spin_lock(&lo->plh_inode->i_lock);

Ditto. What guarantees that the inode still exists here, and how do you
avoid races with a file return request?

> +			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
> +			mark_matching_lsegs_invalid(lo, &free_me_list, range.iomode);
> +			list_del_init(&lo->plh_bulk_recall);
> +			if (!list_empty(&lo->plh_segs))
> +				rv = NFS4_OK;
> +			spin_unlock(&lo->plh_inode->i_lock);
> +			put_layout_hdr(lo);
> +		}
> +		pnfs_free_lseg_list(&free_me_list);
> +	}
> +	return rv;
> +}

Shouldn't the above really be 2 different functions? One for file
return, and the other for bulk layout returns?

> +static u32 do_callback_layoutrecall(struct nfs_client *clp,
> +				    struct cb_layoutrecallargs *args)
> +{
> +	u32 status, res = NFS4ERR_DELAY;
> +
> +	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
> +	if (test_and_set_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state))
> +		goto out;
> +	status = initiate_layout_draining(clp, args);
> +	if (status)
          ^^^^^^^^^^^
If you are going to insist on spelling out 'rv = NFS4_OK' instead of 'rv
= 0' in initiate_layout_draining(), then shouldn't the above test be 'if
(status != NFS4_OK)'?

Please just dump all these NFS4_OK references, and replace them with 'rv
= 0' so that tests like the above make sense. That's consistent with the
rest of the NFS code.

> +		res = status;
> +	else if (args->cbl_recall_type == RETURN_FILE) {
> +		struct pnfs_layout_hdr *lo;
> +
> +		lo = NFS_I(args->cbl_inode)->layout;
> +		spin_lock(&lo->plh_inode->i_lock);
> +		lo->plh_block_lgets--;
> +		spin_unlock(&lo->plh_inode->i_lock);
> +		put_layout_hdr(lo);
> +		res = NFS4ERR_DELAY;

Eh? Why doesn't this belong in (the split up version of)
initiate_layout_draining()?

> +	}
> +	clear_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state);
> +out:
> +	dprintk("%s returning %i\n", __func__, res);
> +	return res;
> +
> +}
> +

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

