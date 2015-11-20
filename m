Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759817AbbKTPXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 10:23:18 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id DF90C19F99A
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2015 15:23:17 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-58-101.rdu2.redhat.com [10.10.58.101])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tAKFNGjN022094
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2015 10:23:17 -0500
Subject: Re: [PATCH] mount.nfs: Teach mount.nfs about the mountversion option
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1436193748-4301-1-git-send-email-steved@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <564F3AE4.1070104@RedHat.com>
Date: Fri, 20 Nov 2015 10:23:16 -0500
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
> ---
>  utils/mount/network.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
Wow... this slide through the cracks... I still
think its a good idea so with no objection I'm
planning on committing this... 

So take solace in the fact it takes awhile for
my own patches to get in! ;-)

steved.

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
