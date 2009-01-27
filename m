From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] dlm: initialize file_lock struct in GETLK before
	copying conflicting lock
Date: Tue, 27 Jan 2009 17:34:01 -0500
Message-ID: <20090127223401.GL9151@fieldses.org>
References: <1232651764-10799-1-git-send-email-jlayton@redhat.com> <1232651764-10799-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, cluster-devel@redhat.com,
	teigland@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48949 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbZA0WeB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jan 2009 17:34:01 -0500
In-Reply-To: <1232651764-10799-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2009 at 02:16:03PM -0500, Jeff Layton wrote:
> dlm_posix_get fills out the relevant fields in the file_lock before
> returning when there is a lock conflict, but doesn't clean out any of
> the other fields in the file_lock.
> 
> When nfsd does a NFSv4 lockt call, it sets the fl_lmops to
> nfsd_posix_mng_ops before calling the lower fs. When the lock comes back
> after testing a lock on GFS2, it still has that field set. This confuses
> nfsd into thinking that the file_lock is a nfsd4 lock.
> 
> Fix this by making DLM reinitialize the file_lock before copying the
> fields from the conflicting lock.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

I'll leave this one to gfs2 people to apply unless I'm told otherwise.

--b.

> ---
>  fs/dlm/plock.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
> index eba87ff..ca46f11 100644
> --- a/fs/dlm/plock.c
> +++ b/fs/dlm/plock.c
> @@ -304,7 +304,9 @@ int dlm_posix_get(dlm_lockspace_t *lockspace, u64 number, struct file *file,
>  	if (rv == -ENOENT)
>  		rv = 0;
>  	else if (rv > 0) {
> +		locks_init_lock(fl);
>  		fl->fl_type = (op->info.ex) ? F_WRLCK : F_RDLCK;
> +		fl->fl_flags = FL_POSIX;
>  		fl->fl_pid = op->info.pid;
>  		fl->fl_start = op->info.start;
>  		fl->fl_end = op->info.end;
> -- 
> 1.5.5.6
> 
