Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34395 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030301AbbCLP5m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2015 11:57:42 -0400
Received: by igal13 with SMTP id l13so1283572iga.1
        for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2015 08:57:41 -0700 (PDT)
Message-ID: <1426175859.15787.1.camel@primarydata.com>
Subject: Re: [PATCH v3] NFS: Don't zap caches on fallocate()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 12 Mar 2015 11:57:39 -0400
In-Reply-To: <1425571566-3117-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1425571566-3117-1-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

On Thu, 2015-03-05 at 11:06 -0500, Anna Schumaker wrote:
> This patch adds a GETATTR to the end of ALLOCATE and DEALLOCATE
> operations so we can set the updated inode size and change attribute
> directly.  DEALLOCATE will still need to release pagecache pages, so
> nfs42_proc_deallocate() now calls truncate_pagecache_range() before
> contacting the server.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/nfs/inode.c          |  1 -
>  fs/nfs/nfs42proc.c      | 23 +++++++++++++++++++----
>  fs/nfs/nfs42xdr.c       | 20 ++++++++++++++++----
>  fs/nfs/nfs4file.c       |  1 -
>  include/linux/nfs_xdr.h |  4 ++++
>  5 files changed, 39 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index d42dff6..e92386f 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -192,7 +192,6 @@ void nfs_zap_caches(struct inode *inode)
>         nfs_zap_caches_locked(inode);
>         spin_unlock(&inode->i_lock);
>  }
> -EXPORT_SYMBOL_GPL(nfs_zap_caches);

This patch appears to be completely whitespace-borked. Can you please
fix up your mailer and resend?

Thanks
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




