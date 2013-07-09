Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33385 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754128Ab3GIPG6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 11:06:58 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UwZVJ-0002de-Op
	for linux-nfs@vger.kernel.org; Tue, 09 Jul 2013 11:06:57 -0400
Date: Tue, 9 Jul 2013 11:06:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: support minorversion 1 by default
Message-ID: <20130709150657.GB8281@fieldses.org>
References: <20130709031928.GN29071@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130709031928.GN29071@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 08, 2013 at 11:19:28PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We now have minimal minorversion 1 support; turn it on by default.
> 
> This can still be turned off with "echo -4.1 >/proc/fs/nfsd/versions".

I intend this for 3.11, since as far as I can tell we're up to spec and
the 4.1-specific bugs I know about have been fixed.

--b.

> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfssvc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 262df5c..6b9f48c 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -116,7 +116,7 @@ struct svc_program		nfsd_program = {
>  
>  };
>  
> -u32 nfsd_supported_minorversion;
> +u32 nfsd_supported_minorversion = 1;
>  
>  int nfsd_vers(int vers, enum vers_op change)
>  {
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
