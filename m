Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42203 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965401AbbD0UgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Apr 2015 16:36:24 -0400
Date: Mon, 27 Apr 2015 16:36:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd/blocklayout: pretend we can send deviceid
 notifications
Message-ID: <20150427203622.GH4083@fieldses.org>
References: <1430139014-28013-1-git-send-email-hch@lst.de>
 <1430139014-28013-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1430139014-28013-2-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 27, 2015 at 02:50:13PM +0200, Christoph Hellwig wrote:
> Commit df52699e4fcef ("NFSv4.1: Don't cache deviceids that have no
> notifications") causes the Linux NFS client stop caching deviceid
> unless a server pretends to support deviceid notifications.  While
> this behavior is stupid and the language around this area in rfc5661
> is a mess carified by an errata that I submittted, Trond insists
> on this behavior.  Not caching deviceids degrades block layout
> performance massively as a GETDEVICEINFO is fairly expensive.
> 
> So add this hack to make the Linux client happy again.

OK, thanks.--b.

> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/blocklayout.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index 03d647b..cdefaa3 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -181,6 +181,17 @@ nfsd4_block_proc_layoutcommit(struct inode *inode,
>  }
>  
>  const struct nfsd4_layout_ops bl_layout_ops = {
> +	/*
> +	 * Pretend that we send notification to the client.  This is a blatant
> +	 * lie to force recent Linux clients to cache our device IDs.
> +	 * We rarely ever change the device ID, so the harm of leaking deviceids
> +	 * for a while isn't too bad.  Unfortunately RFC5661 is a complete mess
> +	 * in this regard, but I filed errata 4119 for this a while ago, and
> +	 * hopefully the Linux client will eventually start caching deviceids
> +	 * without this again.
> +	 */
> +	.notify_types		=
> +			NOTIFY_DEVICEID4_DELETE | NOTIFY_DEVICEID4_CHANGE,
>  	.proc_getdeviceinfo	= nfsd4_block_proc_getdeviceinfo,
>  	.encode_getdeviceinfo	= nfsd4_block_encode_getdeviceinfo,
>  	.proc_layoutget		= nfsd4_block_proc_layoutget,
> -- 
> 1.9.1
