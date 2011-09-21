Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42461 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752441Ab1IUPfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 11:35:31 -0400
Date: Wed, 21 Sep 2011 11:35:30 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/6] leases: break leases on any attribute modification
Message-ID: <20110921153530.GB21510@fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <1316617097-21384-6-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1316617097-21384-6-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 21, 2011 at 10:58:16AM -0400, J. Bruce Fields wrote:
> NFSv4 uses leases to guarantee that clients can cash metadata as well as
						  ^^^^

Um, you know what I meant.  Corrected in my local repo.--b.


> data.
> 
> (I suspect the same is true for Samba.)
> 
> This covers chmod, chown, etc.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/attr.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/attr.c b/fs/attr.c
> index 538e279..4ce31cb 100644
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -231,6 +231,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
>  	error = security_inode_setattr(dentry, attr);
>  	if (error)
>  		return error;
> +	error = break_lease(inode, O_WRONLY);
> +	if (error)
> +		return error;
>  
>  	if (inode->i_op->setattr)
>  		error = inode->i_op->setattr(dentry, attr);
> -- 
> 1.7.4.1
> 
