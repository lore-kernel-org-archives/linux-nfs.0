Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab2K1OlM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 09:41:12 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qASEfB21031994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Nov 2012 09:41:12 -0500
Message-ID: <50B62286.9060002@RedHat.com>
Date: Wed, 28 Nov 2012 09:41:10 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2 V2] mount.nfs: error message clean up.
References: <1354035684-15802-1-git-send-email-steved@redhat.com> <1354035684-15802-2-git-send-email-steved@redhat.com>
In-Reply-To: <1354035684-15802-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 27/11/12 12:01, Steve Dickson wrote:
> Remove a unnecessary newline in an error message.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mount/error.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
Committed....

steved.

> diff --git a/utils/mount/error.c b/utils/mount/error.c
> index 83ad1d2..f8fc13f 100644
> --- a/utils/mount/error.c
> +++ b/utils/mount/error.c
> @@ -225,7 +225,7 @@ void mount_error(const char *spec, const char *mount_point, int error)
>  	case ENOENT:
>  		if (spec)
>  			nfs_error(_("%s: mounting %s failed, "
> -				"reason given by server:\n  %s"),
> +				"reason given by server: %s"),
>  				progname, spec, strerror(error));
>  		else
>  			nfs_error(_("%s: mount point %s does not exist"),
> 
