Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755152Ab2E2TTG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 15:19:06 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q4TJJ6vq009426
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 29 May 2012 15:19:06 -0400
Message-ID: <4FC52102.3000107@RedHat.com>
Date: Tue, 29 May 2012 15:18:26 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Honor the no_root_squash flag on pseudo roots.
References: <1338296836-28243-1-git-send-email-steved@redhat.com>
In-Reply-To: <1338296836-28243-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/29/2012 09:07 AM, Steve Dickson wrote:
> If root squashing is turned off on a export that
> has multiple directories, the parent directories
> of the pseudo exports that's built, also needs to
> have root squashing turned off.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

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
>  
