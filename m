Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840Ab3DVRIe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Apr 2013 13:08:34 -0400
Message-ID: <51756E67.1030604@RedHat.com>
Date: Mon, 22 Apr 2013 13:07:51 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH: nfs-utils] mountd: fix exporting of "/" with sec= setting.
References: <20130411110150.39f127aa@notabene.brown>
In-Reply-To: <20130411110150.39f127aa@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/04/13 21:01, NeilBrown wrote:
> 
> 
> Commit 91bb95f2689e84856ecdf6fac365489d36709cf9
>    4set_root: force "fsid=0" for all exports of '/'
> 
> set NFSEXP_FSID for the export of "/" if nothing else had any fsid set,
> however it didn't also set the flag for all security flavours.  So the
> kernel complains that the flags on the security flavours don't match and
> it rejects the export.
> 
> So call fix_pseudoflavor_flags() in write_secinfo() to make sure that
> any fiddling that has been done to e_flags gets copied to e_secinfo.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed...

steved.

> 
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 5960feb..1fbf754 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -177,6 +177,7 @@ struct export_features {
>  };
>  
>  struct export_features *get_export_features(void);
> +void fix_pseudoflavor_flags(struct exportent *ep);
>  
>  /* Record export error.  */
>  extern int export_errno;
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 6c08a2b..dea040f 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -469,7 +469,7 @@ static void clearflags(int mask, unsigned int active, struct exportent *ep)
>   * ensure that the export flags agree with the flags on each
>   * pseudoflavor:
>   */
> -static void fix_pseudoflavor_flags(struct exportent *ep)
> +void fix_pseudoflavor_flags(struct exportent *ep)
>  {
>  	struct export_features *ef;
>  	struct sec_entry *p;
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 978698d..53552b3 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -735,6 +735,7 @@ static void write_secinfo(FILE *f, struct exportent *ep, int flag_mask)
>  		/* There was no sec= option */
>  		return;
>  	}
> +	fix_pseudoflavor_flags(ep);
>  	qword_print(f, "secinfo");
>  	qword_printint(f, p - ep->e_secinfo);
>  	for (p = ep->e_secinfo; p->flav; p++) {
> 
