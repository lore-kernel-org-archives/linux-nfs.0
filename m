Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbbDBRXA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 13:23:00 -0400
Message-ID: <551D7AF0.6040803@RedHat.com>
Date: Thu, 02 Apr 2015 13:22:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] nfs-utils: add support for the "pnfs" export option
References: <1427964185-24123-1-git-send-email-hch@lst.de>
In-Reply-To: <1427964185-24123-1-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/02/2015 04:43 AM, Christoph Hellwig wrote:
> This goes along with the patch just sent to Bruce to make pnfs
> support conditional.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
Committed.. 

steved.

> ---
>  support/include/nfs/export.h | 1 +
>  support/nfs/exports.c        | 5 +++++
>  utils/exportfs/exportfs.c    | 2 ++
>  utils/exportfs/exports.man   | 9 +++++++++
>  4 files changed, 17 insertions(+)
> 
> diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
> index 2f59e6a..1194255 100644
> --- a/support/include/nfs/export.h
> +++ b/support/include/nfs/export.h
> @@ -26,6 +26,7 @@
>  #define	NFSEXP_CROSSMOUNT	0x4000
>  #define NFSEXP_NOACL		0x8000 /* reserved for possible ACL related use */
>  #define NFSEXP_V4ROOT		0x10000
> +#define NFSEXP_PNFS            0x20000
>  /*
>   * All flags supported by the kernel before addition of the
>   * export_features interface:
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 4b17d3c..9b325b9 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -275,6 +275,7 @@ putexportent(struct exportent *ep)
>  		"no_" : "");
>  	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
>  		fprintf(fp, "nordirplus,");
> +	fprintf(fp, "%spnfs", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
>  	if (ep->e_flags & NFSEXP_FSID) {
>  		fprintf(fp, "fsid=%d,", ep->e_fsid);
>  	}
> @@ -581,6 +582,10 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
>  			clearflags(NFSEXP_NOACL, active, ep);
>  		else if (strcmp(opt, "no_acl") == 0)
>  			setflags(NFSEXP_NOACL, active, ep);
> +		else if (!strcmp(opt, "pnfs"))
> +			setflags(NFSEXP_PNFS, active, ep);
> +		else if (!strcmp(opt, "no_pnfs"))
> +			clearflags(NFSEXP_PNFS, active, ep);
>  		else if (strncmp(opt, "anonuid=", 8) == 0) {
>  			char *oe;
>  			ep->e_anonuid = strtol(opt+8, &oe, 10);
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 48eac00..8758231 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -821,6 +821,8 @@ dump(int verbose, int export_format)
>  				c = dumpopt(c, "nordirplus");
>  			if (ep->e_flags & NFSEXP_NOACL)
>  				c = dumpopt(c, "no_acl");
> +			if (ep->e_flags & NFSEXP_PNFS)
> +				c = dumpopt(c, "pnfs");
>  			if (ep->e_flags & NFSEXP_FSID)
>  				c = dumpopt(c, "fsid=%d", ep->e_fsid);
>  			if (ep->e_uuid)
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index 88d9fbe..9309246 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -408,6 +408,15 @@ If the client asks for alternative locations for the export point, it
>  will be given this list of alternatives. (Note that actual replication
>  of the filesystem must be handled elsewhere.)
>  
> +.TP
> +.IR pnfs
> +This option allows enables the use of pNFS extension if protocol level
> +is NFSv4.1 or higher, and the filesystem supports pNFS exports.  With
> +pNFS clients can bypass the server and perform I/O directly to storage
> +devices. The default can be explicitly requested with the
> +.I no_pnfs
> +option.
> +
>  .SS User ID Mapping
>  .PP
>  .B nfsd
> 
