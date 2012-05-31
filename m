Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44586 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517Ab2EaSvP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 14:51:15 -0400
Date: Thu, 31 May 2012 20:51:11 +0200
From: Jan Kara <jack@suse.cz>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/6] vfs: fix outdated i_mutex_lock_class documentation
Message-ID: <20120531185111.GA13647@quack.suse.cz>
References: <1338429016-20119-1-git-send-email-bfields@redhat.com>
 <1338429016-20119-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1338429016-20119-3-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 30-05-12 21:50:12, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  include/linux/fs.h |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 038076b..5584a29 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -861,7 +861,8 @@ static inline int inode_unhashed(struct inode *inode)
>   * 0: the object of the current VFS operation
>   * 1: parent
>   * 2: child/target
> - * 3: quota file
> + * 3: xattr
> + * 4: quota file
  This isn't correct anymore, is it? Just remove references to quota in this
comment...

>   *
>   * The locking order between these classes is
>   * parent -> child -> normal -> xattr -> quota

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
