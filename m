Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43080 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab0HRU3K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:29:10 -0400
Date: Wed, 18 Aug 2010 16:29:09 -0400
From: Christoph Hellwig <hch@infradead.org>
To: andros@netapp.com
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 10/50] pnfs_submit: register unregister pnfs module
Message-ID: <20100818202909.GD16851@infradead.org>
References: <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1281735122-1496-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> +#ifdef CONFIG_NFS_V4_1
> +	err = pnfs_initialize();
> +	if (err)
> +		goto out00;
> +#endif /* CONFIG_NFS_V4_1 */

Unless the pnfs code goes into it's own module anyway this really
screams for stubs for the !CONFIG_NFS_V4_1 case to avoid all the
ifdef mess.

