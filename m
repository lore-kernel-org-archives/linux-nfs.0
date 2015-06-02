Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:33335 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892AbbFBBnI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2015 21:43:08 -0400
Received: by pdbqa5 with SMTP id qa5so120976723pdb.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Jun 2015 18:43:08 -0700 (PDT)
Message-ID: <556D0A27.4060802@gmail.com>
Date: Tue, 02 Jun 2015 09:43:03 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] exports: add allow_umount option for user un-mounting
 cached exports
References: <5561EB38.5090105@gmail.com>
In-Reply-To: <5561EB38.5090105@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please ignore this patch. Sorry for the noise.

thanks,
Kinglong Mee

On 5/24/2015 11:16 PM, Kinglong Mee wrote:
> After nfsd get exports cache, user cannot umounts the filesystem
> which base on for a reference of the vfsmnt.
> 
> This patch introduces a new option "allow_umount" for nfsd pining to
> the vfsmnt, not get a refernce. At all, user can umount now.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  support/include/nfs/export.h | 3 ++-
>  support/nfs/exports.c        | 6 ++++++
>  utils/exportfs/exports.man   | 8 ++++++++
>  3 files changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
> index 1194255..ca4e0c1 100644
> --- a/support/include/nfs/export.h
> +++ b/support/include/nfs/export.h
> @@ -26,7 +26,8 @@
>  #define	NFSEXP_CROSSMOUNT	0x4000
>  #define NFSEXP_NOACL		0x8000 /* reserved for possible ACL related use */
>  #define NFSEXP_V4ROOT		0x10000
> -#define NFSEXP_PNFS            0x20000
> +#define NFSEXP_PNFS		0x20000
> +#define NFSEXP_ALLOW_UMOUNT	0x40000
>  /*
>   * All flags supported by the kernel before addition of the
>   * export_features interface:
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 0aea6f1..ed5b984 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -276,6 +276,8 @@ putexportent(struct exportent *ep)
>  	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
>  		fprintf(fp, "nordirplus,");
>  	fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
> +	if (ep->e_flags & NFSEXP_ALLOW_UMOUNT)
> +		fprintf(fp, "allow_umount,");
>  	if (ep->e_flags & NFSEXP_FSID) {
>  		fprintf(fp, "fsid=%d,", ep->e_fsid);
>  	}
> @@ -586,6 +588,10 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
>  			setflags(NFSEXP_PNFS, active, ep);
>  		else if (!strcmp(opt, "no_pnfs"))
>  			clearflags(NFSEXP_PNFS, active, ep);
> +		else if (!strcmp(opt, "allow_umount"))
> +			setflags(NFSEXP_ALLOW_UMOUNT, active, ep);
> +		else if (!strcmp(opt, "no_allow_umount"))
> +			clearflags(NFSEXP_ALLOW_UMOUNT, active, ep);
>  		else if (strncmp(opt, "anonuid=", 8) == 0) {
>  			char *oe;
>  			ep->e_anonuid = strtol(opt+8, &oe, 10);
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index 9309246..d3947a4 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -417,6 +417,14 @@ devices. The default can be explicitly requested with the
>  .I no_pnfs
>  option.
>  
> +.TP
> +.IR allow_umount
> +This option allows user un-mounting the filesystem where cached nfsd exports
> +is based on. Otherwise, the kernel may returns -EBUSY and un-mounting fail.
> +The default is without the
> +.I allow_umount
> +option.
> +
>  .SS User ID Mapping
>  .PP
>  .B nfsd
> 
