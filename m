Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760972AbbKUPey (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Nov 2015 10:34:54 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 346B880085
	for <linux-nfs@vger.kernel.org>; Sat, 21 Nov 2015 15:34:54 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-60-53.rdu2.redhat.com [10.10.60.53])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tALFYrtG003933
	for <linux-nfs@vger.kernel.org>; Sat, 21 Nov 2015 10:34:53 -0500
Subject: Re: [PATCH] mount.nfs: Teach mount.nfs about the mountversion option
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1436193748-4301-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56508F1D.6080001@RedHat.com>
Date: Sat, 21 Nov 2015 10:34:53 -0500
MIME-Version: 1.0
In-Reply-To: <1436193748-4301-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/06/2015 10:42 AM, Steve Dickson wrote:
> When the mountversion option is used, there should
> not be any mount negotiations with the server.
> 
> Also, when the option is used, its know that the mount
> is a v4 mount and a V_SPECFIC type.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed.. 

steved.

> ---
>  utils/mount/network.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index b5ed850..ebc39d3 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -92,6 +92,7 @@ static const char *nfs_version_opttbl[] = {
>  	"v4",
>  	"vers",
>  	"nfsvers",
> +	"minorversion",
>  	NULL,
>  };
>  
> @@ -1272,7 +1273,11 @@ nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
>  	if (!(version->major = strtol(version_val, &cptr, 10)))
>  		goto ret_error;
>  
> -	if (version->major < 4)
> +	if (strcmp(nfs_version_opttbl[i], "minorversion") == 0) {
> +		version->v_mode = V_SPECIFIC;
> +		version->minor = version->major;
> +		version->major = 4;
> +	} else if (version->major < 4)
>  		version->v_mode = V_SPECIFIC;
>  
>  	if (*cptr == '.') {
> 
