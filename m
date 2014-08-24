Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49659 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaHXB2A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Aug 2014 21:28:00 -0400
Date: Sat, 23 Aug 2014 18:27:57 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, hch@infradead.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/10] locks: generic_delete_lease doesn't need a
 file_lock at all
Message-ID: <20140824012757.GA21609@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408804878-1331-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 23, 2014 at 10:41:11AM -0400, Jeff Layton wrote:
> +static int generic_delete_lease(struct file *filp)
>  {
>  	struct file_lock *fl, **before;
>  	struct dentry *dentry = filp->f_path.dentry;
>  	struct inode *inode = dentry->d_inode;
>  
> -	trace_generic_delete_lease(inode, *flp);
> -

Can you keep the tracepoint and modify it to not need the file_lock
pointer?  It really helped me with some debugging lately.

Otherwise looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
