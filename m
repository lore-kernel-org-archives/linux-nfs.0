Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52308 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631Ab0IWOFv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 10:05:51 -0400
Date: Thu, 23 Sep 2010 10:05:50 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfsd-next] nfsd: Export get_task_comm for nfsd
Message-ID: <20100923140550.GA10137@infradead.org>
References: <4C9B176E.4090808@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C9B176E.4090808@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 23, 2010 at 01:01:34PM +0400, Pavel Emelyanov wrote:
> The git://linux-nfs.org/~bfields/linux.git nfsd-next branch doesn't
> compile when nfsd is a module with the following error:
> 
>    ERROR: "get_task_comm" [fs/nfsd/nfsd.ko] undefined!
> 
> The get_task_comm is used in nfsctl_transaction_read's printk.

Why doesn't it simply use current->comm as countless other users?
Assuming it doesn't actually want to print comm for a non-current users
which would rather surprise me.
