Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53723 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741Ab3A2SNp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2013 13:13:45 -0500
Date: Tue, 29 Jan 2013 13:13:44 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: fanchaoting <fanchaoting@cn.fujitsu.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Check the nfsd support version when enable or
 disable the minorversion
Message-ID: <20130129181344.GA4209@fieldses.org>
References: <50FFB43A.8030105@cn.fujitsu.com>
 <20130123232458.GB6565@fieldses.org>
 <510247B8.4020207@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <510247B8.4020207@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 25, 2013 at 04:52:08PM +0800, fanchaoting wrote:
> when enable or disable the minorversion throw /proc/fs/nfsd/versions,
> it should check the support version. now only nfs4 suppport minorversion.
> 
> Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>

Apologies, I'd already committed the same fix (and credited you with
reported-by:) before seeing this.--b.

> 
> ---
>  fs/nfsd/nfsctl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 7493428..65889ec 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -534,7 +534,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
>                         else
>                                 num = simple_strtol(vers, &minorp, 0);
>                         if (*minorp == '.') {
> -                               if (num < 4)
> +                               if (num != 4)
>                                         return -EINVAL;
>                                 minor = simple_strtoul(minorp+1, NULL, 0);
>                                 if (minor == 0)
> --
> 1.7.10.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
