Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-out2.uio.no ([129.240.10.58]:43374 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860Ab2E2Pbu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 11:31:50 -0400
Message-ID: <1338303611.5433.14.camel@lade.trondhjem.org>
Subject: Re: [PATCH] Honor the no_root_squash flag on pseudo roots.
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 29 May 2012 11:00:11 -0400
In-Reply-To: <1338296836-28243-1-git-send-email-steved@redhat.com>
References: <1338296836-28243-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-05-29 at 09:07 -0400, Steve Dickson wrote:
> If root squashing is turned off on a export that
> has multiple directories, the parent directories
> of the pseudo exports that's built, also needs to
> have root squashing turned off.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mountd/v4root.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index 708eb61..ad8a3e7 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -92,7 +92,14 @@ v4root_create(char *path, nfs_export *export)
>  	exp = export_create(&eep, 0);
>  	if (exp == NULL)
>  		return NULL;
> -	xlog(D_CALL, "v4root_create: path '%s'", exp->m_export.e_path);
> +	/*
> +	 * Honor the no_root_squash flag 
> +	 */
> +	if ((curexp->e_flags & NFSEXP_ROOTSQUASH) == 0)
> +		exp->m_export.e_flags &= ~NFSEXP_ROOTSQUASH;
> +	xlog(D_CALL, "v4root_create: path '%s' flags 0x%x", 
> +		exp->m_export.e_path, exp->m_export.e_flags);
> +
>  	return &exp->m_export;
>  }


As long as the user is authenticated, why do we care whether or not they
are squashed to user 'nobody' for authorisation purposes? There
shouldn't be any permission checks enforced on the pseudo-root, should
there?

Cheers
  Trond

