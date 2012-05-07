Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:28589 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756467Ab2EGOpG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 10:45:06 -0400
References: <1336399651-6596-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1336399651-6596-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <B1119637-19EE-44E5-B25A-9655D2ACA8DF@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/3] NFS: Don't do a full flush to disk on close() if we hold a delegation
Date: Mon, 7 May 2012 10:48:03 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I thought the reason we wait for flush completion on close() was to report errors.

Sent from my iPad

On May 7, 2012, at 10:07 AM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> If we hold a delegation then we know that it should be safe to continue
> to cache the data beyond the close(). However since the process that wrote
> the data may die after close(), we may still want to send the data to
> server before those RPCSEC_GSS credentials expire. We therefore compromise
> by starting writeback to the server, but don't wait for completion.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/file.c |    7 +++++++
> 1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index aa9b709..8eda8a6 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -174,6 +174,13 @@ nfs_file_flush(struct file *file, fl_owner_t id)
>    if ((file->f_mode & FMODE_WRITE) == 0)
>        return 0;
> 
> +    /*
> +     * If we're holding a write delegation, then just start the i/o
> +     * but don't wait for completion (or send a commit).
> +     */
> +    if (nfs_have_delegation(inode, FMODE_WRITE))
> +        return filemap_fdatawrite(file->f_mapping);
> +
>    /* Flush writes to the server and return any errors */
>    return vfs_fsync(file, 0);
> }
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
