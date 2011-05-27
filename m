Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6657 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab1E0OZK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2011 10:25:10 -0400
Message-ID: <4DDFB446.1040804@panasas.com>
Date: Fri, 27 May 2011 17:25:10 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 22/32] pnfs: layoutreturn
References: <4DDD7392.6040505@panasas.com> <1306358953-17598-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306358953-17598-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2011 12:29 AM, Benny Halevy wrote:

<snip>

> +/* Initiates a LAYOUTRETURN(FILE) */
> +int
> +_pnfs_return_layout(struct inode *ino)
> +{
> +	struct pnfs_layout_hdr *lo = NULL;
> +	struct nfs_inode *nfsi = NFS_I(ino);
> +	LIST_HEAD(tmp_list);
> +	struct nfs4_layoutreturn *lrp;
> +	nfs4_stateid stateid;
> +	int status = 0;
> +
> +	dprintk("--> %s\n", __func__);
> +
> +	spin_lock(&ino->i_lock);
> +	lo = nfsi->layout;
> +	if (!lo || !mark_matching_lsegs_invalid(lo, &tmp_list, NULL)) {
> +		spin_unlock(&ino->i_lock);
> +		dprintk("%s: no layout segments to return\n", __func__);
> +		goto out;
> +	}
> +	stateid = nfsi->layout->plh_stateid;
> +	/* Reference matched in nfs4_layoutreturn_release */
> +	get_layout_hdr(lo);
> +	spin_unlock(&ino->i_lock);
> +	pnfs_free_lseg_list(&tmp_list);
> +
> +	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
> +
> +	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
> +	if (unlikely(lrp == NULL)) {
-	if (unlikely(lrp == NULL)) {
+	if (unlikely(!lrp)) {

Benny what happened to the:
		put_layout_hdr(lo);

That was there the last version? It is still most needed!

If you are at it also please do the above change as well

Boaz
> +		status = -ENOMEM;
> +		goto out;
> +	}
> +
> +	lrp->args.stateid = stateid;
> +	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
> +	lrp->args.inode = ino;
> +	lrp->clp = NFS_SERVER(ino)->nfs_client;
> +
> +	status = nfs4_proc_layoutreturn(lrp);
> +out:
> +	dprintk("<-- %s status: %d\n", __func__, status);
> +	return status;
> +}
> +
