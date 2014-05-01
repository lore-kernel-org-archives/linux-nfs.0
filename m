Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:45167 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbaEAUTU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 16:19:20 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so3612494pdj.29
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 13:19:19 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 2/3] nfs: rename members of nfs_pgio_data
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1398971693-82399-3-git-send-email-dros@primarydata.com>
Date: Thu, 1 May 2014 16:19:14 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <6E840B50-223E-462C-B9A7-BC48C6DC5906@primarydata.com>
References: <1398971693-82399-1-git-send-email-dros@primarydata.com> <1398971693-82399-3-git-send-email-dros@primarydata.com>
To: Adamson Weston Andros <dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 1, 2014, at 15:14, Weston Andros Adamson <dros@primarydata.com> wrote:

> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index a7ccc8c..8564539 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1261,13 +1261,13 @@ struct nfs_pgio_data {
> 	struct list_head	list;
> 	struct rpc_task		task;
> 	struct nfs_fattr	fattr;
> -	struct nfs_writeverf	verf;		/* Used for writes */
> +	struct nfs_writeverf	rpc_verf;	/* Used for writes */

Can we just make this “writeverf"? It isn’t really an rpc object, so the ‘rpc_’ prefix seems a little misleading.

> 	struct nfs_pgio_args	args;		/* argument struct */
> 	struct nfs_pgio_res	res;		/* result struct */
> 	unsigned long		timestamp;	/* For lease renewal */
> 	int (*pgio_done_cb)(struct rpc_task *task, struct nfs_pgio_data *data);
> 	__u64			mds_offset;	/* Filelayout dense stripe */
> -	struct nfs_page_array	pages;
> +	struct nfs_page_array	page_array;
> 	struct nfs_client	*ds_clp;	/* pNFS data server */
> 	int			ds_idx;		/* ds index if ds_clp is set */
> };
> -- 
> 1.8.5.2 (Apple Git-48)
> 

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

