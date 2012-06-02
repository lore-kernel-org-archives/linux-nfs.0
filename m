Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:53380 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756051Ab2FBWve (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Jun 2012 18:51:34 -0400
Message-ID: <4FCA98E7.2030006@panasas.com>
Date: Sun, 3 Jun 2012 01:51:19 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <andros@netapp.com>
CC: <trond.myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
References: <1338571178-2096-1-git-send-email-andros@netapp.com> <1338571178-2096-2-git-send-email-andros@netapp.com>
In-Reply-To: <1338571178-2096-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/01/2012 08:19 PM, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> When fencing, pnfs_return_layout can be called mulitple times with in-flight
> i/o referencing lsegs on it's plh_segs list.
> 
> Remember that LAYOUTRETURN has been called, and do not call it again.
> 


NACK

In objects-layout we must report all errors on layout_return. We
accumulate them and report of all errors at once. So we need
the return after all in flights are back. (And no new IOs are
sent) Otherwise we might miss some.

Also the RFC mandates that we do not use any layout or have
IOs in flight, once we return the layout.

I was under the impression that only when the last reference
on a layout is dropped only then we send the lo_return.
If it is not so, this is the proper fix.

1. Mark LO invalid so all new IO waits or goes to MDS
3. When LO ref drops to Zero send the lo_return.
4. After LAYOUTRETURN_DONE is back, re-enable layouts.

I'm so sorry it is not so today. I should have tested for
this. I admit that all my error injection tests are
single-file single thread so I did not test for this.

Sigh, work never ends. Tell me if I can help with this
Boaz

> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/pnfs.c |    6 ++++--
>  fs/nfs/pnfs.h |   13 +++++++++++++
>  2 files changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 854df5e..9ffd5f8 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -664,11 +664,11 @@ _pnfs_return_layout(struct inode *ino)
>  	nfs4_stateid stateid;
>  	int status = 0, empty = 0;
>  
> -	dprintk("--> %s\n", __func__);
> +	dprintk("--> %s for inode %lu\n", __func__, ino->i_ino);
>  
>  	spin_lock(&ino->i_lock);
>  	lo = nfsi->layout;
> -	if (!lo) {
> +	if (!lo || pnfs_test_layout_returned(lo)) {
>  		spin_unlock(&ino->i_lock);
>  		dprintk("%s: no layout to return\n", __func__);
>  		return status;
> @@ -705,6 +705,8 @@ _pnfs_return_layout(struct inode *ino)
>  	lrp->clp = NFS_SERVER(ino)->nfs_client;
>  
>  	status = nfs4_proc_layoutreturn(lrp);
> +	if (status == 0)
> +		pnfs_mark_layout_returned(lo);
>  out:
>  	dprintk("<-- %s status: %d\n", __func__, status);
>  	return status;
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 29fd23c..8be6de2 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -64,6 +64,7 @@ enum {
>  	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
>  	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
>  	NFS_LAYOUT_INVALID,		/* layout is being destroyed */
> +	NFS_LAYOUT_RETURNED,		/* layout has already been returned */
>  };
>  
>  enum layoutdriver_policy_flags {
> @@ -255,6 +256,18 @@ struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *
>  bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
>  void nfs4_deviceid_purge_client(const struct nfs_client *);
>  
> +static inline void
> +pnfs_mark_layout_returned(struct pnfs_layout_hdr *lo)
> +{
> +	set_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
> +}
> +
> +static inline bool
> +pnfs_test_layout_returned(struct pnfs_layout_hdr *lo)
> +{
> +	return test_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
> +}
> +
>  static inline int lo_fail_bit(u32 iomode)
>  {
>  	return iomode == IOMODE_RW ?


