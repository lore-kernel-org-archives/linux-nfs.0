Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:41853 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbaGCN2t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 09:28:49 -0400
Received: by mail-vc0-f179.google.com with SMTP id id10so207857vcb.10
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 06:28:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1404388459-32288-1-git-send-email-jlayton@primarydata.com>
References: <1404388459-32288-1-git-send-email-jlayton@primarydata.com>
Date: Thu, 3 Jul 2014 09:28:48 -0400
Message-ID: <CAHQdGtRTYC5_cdva+yT7d4xrcKF6CL7YbY7oY1rnudUPL0VnDw@mail.gmail.com>
Subject: Re: [PATCH] nfsd: properly convert return from commit_metadata to __be32
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 3, 2014 at 7:54 AM, Jeff Layton <jlayton@primarydata.com> wrote:
> Commit 2a7420c03e504 (nfsd: Ensure that nfsd_create_setattr commits
> files to stable storage), added a couple of calls to commit_metadata,
> but doesn't convert their return codes to __be32 in the appropriate
> places.
>
> Cc: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/vfs.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index e1b792ada45b..f501a9b5c9df 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -463,7 +463,7 @@ out_put_write_access:
>         if (size_change)
>                 put_write_access(inode);
>         if (!err)
> -               err = commit_metadata(fhp);
> +               err = nfserrno(commit_metadata(fhp));
>  out:
>         return err;
>  }
> @@ -1122,7 +1122,7 @@ nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
>         if (iap->ia_valid)
>                 return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
>         /* Callers expect file metadata to be committed here */
> -       return commit_metadata(resfhp);
> +       return nfserrno(commit_metadata(resfhp));
>  }
>
>  /* HPUX client sometimes creates a file in mode 000, and sets size to 0.
> --
> 1.9.3
>

Doh! Thanks Jeff!...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
