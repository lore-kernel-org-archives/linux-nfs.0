Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40686 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab0IMPHC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 11:07:02 -0400
Date: Mon, 13 Sep 2010 11:07:00 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
Message-ID: <20100913150700.GA3920@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
 <1283450419-5648-8-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1283450419-5648-8-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 02, 2010 at 02:00:13PM -0400, Fred Isaman wrote:
>  static struct pnfs_layoutdriver_type *
>  find_pnfs_driver(u32 id) {
> -	return NULL;
> +	struct  pnfs_layoutdriver_type *local;
> +
> +	spin_lock(&pnfs_spinlock);
> +	local = find_pnfs_driver_locked(id);
> +	spin_unlock(&pnfs_spinlock);
> +	return local;

What about refcounting the structure?

> +	spin_lock(&pnfs_spinlock);
> +	if (!find_pnfs_driver_locked(ld_type->id)) {
> +		list_add(&ld_type->pnfs_tblid, &pnfs_modules_tbl);
> +		status = 0;
> +		dprintk("%s Registering id:%u name:%s\n", __func__, ld_type->id,
> +			ld_type->name);
> +	} else
> +		printk(KERN_ERR "%s Module with id %d already loaded!\n",
> +			__func__, ld_type->id);
> +	spin_unlock(&pnfs_spinlock);

In other places we generally don't bother doing these checks, so for
pnfs with just three clients it's even more poinless.

