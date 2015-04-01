Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:56223 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbbDAItk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2015 04:49:40 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 3E37E280738
	for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2015 10:49:38 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 315DC13E9B
	for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2015 10:49:38 +0200 (MEST)
Date: Wed, 1 Apr 2015 10:49:37 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Christoph Hellwig <hch@lst.de>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-ID: <186656243.1028813.1427878177493.JavaMail.zimbra@desy.de>
In-Reply-To: <1427876113-27004-1-git-send-email-hch@lst.de>
References: <1427876113-27004-1-git-send-email-hch@lst.de>
Subject: Re: [PATCH] nfs-utils: add support for the "pnfs" export option
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Christoph Hellwig" <hch@lst.de>
> To: "Steve Dickson" <SteveD@redhat.com>
> Cc: linux-nfs@vger.kernel.org
> Sent: Wednesday, April 1, 2015 10:15:13 AM
> Subject: [PATCH] nfs-utils: add support for the "pnfs" export option

> This goes along with the patch just sent to Bruce to make pnfs
> support conditional.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
> support/include/nfs/export.h | 1 +
> support/nfs/exports.c        | 3 +++
> utils/exportfs/exportfs.c    | 2 ++
> 3 files changed, 6 insertions(+)
> 
> diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
> index 2f59e6a..1194255 100644
> --- a/support/include/nfs/export.h
> +++ b/support/include/nfs/export.h
> @@ -26,6 +26,7 @@
> #define	NFSEXP_CROSSMOUNT	0x4000
> #define NFSEXP_NOACL		0x8000 /* reserved for possible ACL related use */
> #define NFSEXP_V4ROOT		0x10000
> +#define NFSEXP_PNFS            0x20000
> /*
>  * All flags supported by the kernel before addition of the
>  * export_features interface:
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 4b17d3c..97f9e67 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -275,6 +275,7 @@ putexportent(struct exportent *ep)
> 		"no_" : "");
> 	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
> 		fprintf(fp, "nordirplus,");
> +	fprintf(fp, "%s", (ep->e_flags & NFSEXP_PNFS)? "pnfs," : "");
> 	if (ep->e_flags & NFSEXP_FSID) {
> 		fprintf(fp, "fsid=%d,", ep->e_fsid);
> 	}
> @@ -581,6 +582,8 @@ parseopts(char *cp, struct exportent *ep, int warn, int
> *had_subtree_opt_ptr)
> 			clearflags(NFSEXP_NOACL, active, ep);
> 		else if (strcmp(opt, "no_acl") == 0)
> 			setflags(NFSEXP_NOACL, active, ep);
> +		else if (!strcmp(opt, "pnfs"))
> +			setflags(NFSEXP_PNFS, active, ep);

and no_pnfs as well to match other options.

Tigran.

> 		else if (strncmp(opt, "anonuid=", 8) == 0) {
> 			char *oe;
> 			ep->e_anonuid = strtol(opt+8, &oe, 10);
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 48eac00..8758231 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -821,6 +821,8 @@ dump(int verbose, int export_format)
> 				c = dumpopt(c, "nordirplus");
> 			if (ep->e_flags & NFSEXP_NOACL)
> 				c = dumpopt(c, "no_acl");
> +			if (ep->e_flags & NFSEXP_PNFS)
> +				c = dumpopt(c, "pnfs");
> 			if (ep->e_flags & NFSEXP_FSID)
> 				c = dumpopt(c, "fsid=%d", ep->e_fsid);
> 			if (ep->e_uuid)
> --
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
