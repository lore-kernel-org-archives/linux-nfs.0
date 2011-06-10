Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13501 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652Ab1FJCxa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 22:53:30 -0400
Message-ID: <4DF1871C.1070001@panasas.com>
Date: Thu, 09 Jun 2011 19:53:16 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] NFSv4.1: Add an initialisation callback for pNFS
References: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-2-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-3-git-send-email-Trond.Myklebust@netapp.com> <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 06:31 PM, Trond Myklebust wrote:
<snip>
> +void
> +pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
> +{
> +	BUG_ON(pgio->pg_lseg != NULL);
> +
> +	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> +					   req->wb_context,
> +					   req_offset(req),
> +					   req->wb_bytes,
> +					   IOMODE_READ,
> +					   GFP_KERNEL);
> +}
> +EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
> +
> +void
> +pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
> +{
> +	BUG_ON(pgio->pg_lseg != NULL);
> +
> +	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
> +					   req->wb_context,
> +					   req_offset(req),
> +					   req->wb_bytes,
> +					   IOMODE_RW,
> +					   GFP_NOFS);
> +}
> +EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
> +

These two above are identical except the IOMODE_{READ,RW} variable.
Why don't you just have one and let the caller pass the IOMODE_ as a
3rd parameter. Do you expect more code to be  added here?

Boaz
