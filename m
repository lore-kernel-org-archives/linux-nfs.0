From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix NLM reference count panic
Date: Fri, 4 Jan 2008 18:24:22 -0500
Message-ID: <20080104232422.GF14827@fieldses.org>
References: <477EB7D1.9030303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58388 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753700AbYADXYX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 18:24:23 -0500
In-Reply-To: <477EB7D1.9030303@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 04, 2008 at 05:48:49PM -0500, Wendy Cheng wrote:
> This fixes the incorrect fclose call inside nlm_traverse_files() where 
> a posix lock could still be held by NFS client. Problem was found in a
> kernel panic inside locks_remove_flock() (fs/locks.c:2034) as part of 
> the fclose call due to NFS-NLM locks still hanging on inode->i_flock list. 
> 
> Also see: http://people.redhat.com/wcheng/Patches/NFS/NLM/001.txt

Next time it'd be best just to include that into the referred-to text
into the message.

>  svcsubs.c |    3 +--
>  1 files changed, 1 insertion(+), 2 deletions(-)
> 
> --- gfs2-nmw/fs/lockd/svcsubs.c	2007-04-10 11:59:09.000000000 -0400
> +++ linux/fs/lockd/svcsubs.c	2007-04-18 10:01:23.000000000 -0400
> @@ -250,8 +250,7 @@ nlm_traverse_files(struct nlm_host *host
>  			mutex_lock(&nlm_file_mutex);
>  			file->f_count--;
>  			/* No more references to this file. Let go of it. */
> -			if (list_empty(&file->f_blocks) && !file->f_locks
> -			 && !file->f_shares && !file->f_count) {
> +			if (!nlm_file_inuse(file)) {
>  				hlist_del(&file->f_list);
>  				nlmsvc_ops->fclose(file->f_file);
>  				kfree(file);

This just replaces the file->f_locks check by a search of the inode's
lock list.

What confuses me here is that the nlm_inspect_file() call just above
already did that search, and set file->f_locks accordingly.  The only
difference is that now we've acquired the nlm_file_mutex.  I don't
understand yet how that makes a difference.

--b.
