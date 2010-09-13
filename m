From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
Date: Mon, 13 Sep 2010 11:08:44 -0400
Message-ID: <20100913150844.GB3920@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
 <1283450419-5648-9-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40288 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab0IMPIo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 11:08:44 -0400
In-Reply-To: <1283450419-5648-9-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 02, 2010 at 02:00:14PM -0400, Fred Isaman wrote:
> +static int __init nfs4filelayout_init(void)
> +{
> +	printk(KERN_INFO "%s: NFSv4 File Layout Driver Registering...\n",
> +	       __func__);
> +
> +	/*
> +	 * Need to register file_operations struct with global list to indicate
> +	 * that NFS4 file layout is a possible pNFS I/O module
> +	 */
> +	return pnfs_register_layoutdriver(&filelayout_type);

And I thought we were dealing with an UFO detection device here..

Sarcasm aside, this is one of the most pointless and incorrect comments I've
seen for a while.

> +	/* Unregister NFS4 file layout driver with pNFS client*/
> +	pnfs_unregister_layoutdriver(&filelayout_type);

This one is not too useful either.

