Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35510 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932420AbaHYUBg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 16:01:36 -0400
Date: Mon, 25 Aug 2014 16:01:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, hch@infradead.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/10] locks: close potential race in lease_get_mtime
Message-ID: <20140825200127.GB21957@fieldses.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-2-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408804878-1331-2-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 23, 2014 at 10:41:09AM -0400, Jeff Layton wrote:
> lease_get_mtime is called without the i_lock held, so there's no
> guarantee about the stability of the list. Between the time when we
> assign "flock" and then dereference it to check whether it's a lease
> and for write, the lease could be freed.
> 
> Ensure that that doesn't occur by taking the i_lock before trying
> to check the lease.

ACK.

Though I still wonder whether we shouldn't just axe lease_get_mtime.

What it's doing is telling v2/v3 clients that the mtime of a
write-leased file is always the current time, in order to force
applications such as make to open the file and break the lease, thus
forcing any cached writes to be flushed to the server.  Otherwise the
worry was that they'd never find out about writes cached by Samba
clients somewhere.

Talking over NFS write delegation implementation with Trond, he
convinced me that our least-worst option for handling the same problem
there would be just to continue to depend on clients holding write
leases to touch the file at appropriate times (like close and unlock).

I don't know what sort of behavior Samba or its clients has here.  Even
if they're not terribly good about keeping the mtime updated the lost of
consistency might be less-worse than this faking up of the mtime.

Looking at the git history, lease_get_mtime appears to have been part of
the lease code from the time it was first merged in 2.4.0-test9pre6, so
it may not have been added in response to an actual practical problem.

Digging around, here's a reference to last time this came up, because
somebody was irritated that make was constantly rebuilding things for no
reason:

	https://bugzilla.samba.org/show_bug.cgi?id=5103

Anyway, that's all orthogonal to this patch, ACK to it for now.

--b.

> 
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/locks.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index d7e15a256f8f..58ce8897f2e4 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1456,8 +1456,18 @@ EXPORT_SYMBOL(__break_lease);
>   */
>  void lease_get_mtime(struct inode *inode, struct timespec *time)
>  {
> -	struct file_lock *flock = inode->i_flock;
> -	if (flock && IS_LEASE(flock) && (flock->fl_type == F_WRLCK))
> +	bool has_lease = false;
> +	struct file_lock *flock;
> +
> +	if (inode->i_flock) {
> +		spin_lock(&inode->i_lock);
> +		flock = inode->i_flock;
> +		if (flock && IS_LEASE(flock) && (flock->fl_type == F_WRLCK))
> +			has_lease = true;
> +		spin_unlock(&inode->i_lock);
> +	}
> +
> +	if (has_lease)
>  		*time = current_fs_time(inode->i_sb);
>  	else
>  		*time = inode->i_mtime;
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
