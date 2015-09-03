Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41396 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756852AbbICSbG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2015 14:31:06 -0400
Date: Thu, 3 Sep 2015 14:31:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: add support for "nowcc" option
Message-ID: <20150903183103.GB10088@fieldses.org>
References: <1441301785-17602-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441301785-17602-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 03, 2015 at 01:36:25PM -0400, Jeff Layton wrote:
> This is the userland companion patch for the patch to add a "nowcc"
> option to knfsd. This just adds the necessary code to allow userspace
> to set that option.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  support/include/nfs/export.h |  3 ++-
>  support/nfs/exports.c        |  5 +++++
>  utils/exportfs/exportfs.c    |  2 ++
>  utils/exportfs/exports.man   | 14 ++++++++++++++
>  4 files changed, 23 insertions(+), 1 deletion(-)
> 
> diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
> index 1194255899bd..68bee5c2f305 100644
> --- a/support/include/nfs/export.h
> +++ b/support/include/nfs/export.h
> @@ -26,7 +26,8 @@
>  #define	NFSEXP_CROSSMOUNT	0x4000
>  #define NFSEXP_NOACL		0x8000 /* reserved for possible ACL related use */
>  #define NFSEXP_V4ROOT		0x10000
> -#define NFSEXP_PNFS            0x20000
> +#define NFSEXP_PNFS		0x20000
> +#define NFSEXP_NOWCC		0x40000
>  /*
>   * All flags supported by the kernel before addition of the
>   * export_features interface:
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 0aea6f154f09..791b5f756c9c 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -276,6 +276,7 @@ putexportent(struct exportent *ep)
>  	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
>  		fprintf(fp, "nordirplus,");
>  	fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
> +	fprintf(fp, "%swcc,", (ep->e_flags & NFSEXP_NOWCC) ? "no" : "");
>  	if (ep->e_flags & NFSEXP_FSID) {
>  		fprintf(fp, "fsid=%d,", ep->e_fsid);
>  	}
> @@ -586,6 +587,10 @@ parseopts(char *cp, struct exportent *ep, int warn, int *had_subtree_opt_ptr)
>  			setflags(NFSEXP_PNFS, active, ep);
>  		else if (!strcmp(opt, "no_pnfs"))
>  			clearflags(NFSEXP_PNFS, active, ep);
> +		else if (!strcmp(opt, "wcc"))
> +			clearflags(NFSEXP_NOWCC, active, ep);
> +		else if (!strcmp(opt, "nowcc"))
> +			setflags(NFSEXP_NOWCC, active, ep);
>  		else if (strncmp(opt, "anonuid=", 8) == 0) {
>  			char *oe;
>  			ep->e_anonuid = strtol(opt+8, &oe, 10);
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 87582316b086..a2afc80ee6ea 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -823,6 +823,8 @@ dump(int verbose, int export_format)
>  				c = dumpopt(c, "no_acl");
>  			if (ep->e_flags & NFSEXP_PNFS)
>  				c = dumpopt(c, "pnfs");
> +			if (ep->e_flags & NFSEXP_NOWCC)
> +				c = dumpopt(c, "nowcc");
>  			if (ep->e_flags & NFSEXP_FSID)
>  				c = dumpopt(c, "fsid=%d", ep->e_fsid);
>  			if (ep->e_uuid)
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index 93092463153b..9213a228bb04 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -417,6 +417,20 @@ devices. The default can be explicitly requested with the
>  .I no_pnfs
>  option.
>  
> +.TP
> +.IR nowcc
> +This option disables the collection and reporting of WCC (weak cache
> +consistency) data in NFSv3 requests.  RFC 1813 recommends that all
> +servers report this information to the clients as it allows the client
> +to avoid some extra round trips to the server.  In some underlying
> +filesystems however, collecting this data can be cost prohibitive and
> +atomicity is difficult to guarantee.

Which filesystems?

> Also, in some client use-cases WCC
> +data is ignored or not terribly useful.  The default is to always report
> +weak cache consistency data to the client in NFSv3 requests, and can be
> +explicitly requested with the
> +.I wcc
> +option.
> +

This is a little vague.  Can we give users any better guidelines?

--b.
