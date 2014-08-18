Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45628 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828AbaHRTKD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 15:10:03 -0400
Date: Mon, 18 Aug 2014 15:10:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Rishi Agrawal <Rishi_Agrawal@symantec.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Ram Pandiri <ram_pandiri@symantec.com>,
        Sreeharsha Sarabu <Sreeharsha_Sarabu@symantec.com>,
        Abhijit Dey <Abhijit_Dey@symantec.com>,
        Tushar Shinde <Tushar_Shinde@symantec.com>,
        "bfields@redhat.com" <bfields@redhat.com>
Subject: Re: [PATCH] nfsd: allow turning off nfsv3 readdir_plus
Message-ID: <20140818191001.GB1096@fieldses.org>
References: <20AEB6A025F81A4288597093171D1B5719CF5813D2@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
 <53DF992D.6090404@RedHat.com>
 <20140804152411.GB23341@fieldses.org>
 <20140804214646.GK23341@fieldses.org>
 <20140805182134.GQ23341@fieldses.org>
 <4B8EA414FDE8F8449D981669FD32FD231356A61CFF@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
 <4B8EA414FDE8F8449D981669FD32FD231356A61D08@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B8EA414FDE8F8449D981669FD32FD231356A61D08@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 18, 2014 at 11:06:03AM -0700, Rajesh Ghanekar wrote:
> Hi Bruce/Steve,
>     I am resending with the description of the patch for
> nfs-utils (copied from Bruce's text). Please note that both
> the patches, nfs kernel and nfs-utils, will have following
> same Signed-off-by signature.
> 
> From: Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>

OK, thanks, applying for 3.18.--b.

> 
> One of our customer's application only needs file names, not file
> attributes. With directories having 10K+ inodes (assuming buffer cache
> has directory blocks cached having file names, but inode cache is
> limited and hence need eviction of older cached inodes), older inodes
> are evicted periodically. So if they keep on doing readdir(2) from NSF
> client on multiple directories, some directory's files are periodically
> removed from inode cache and hence new readdir(2) on same directory
> requires disk access to bring back inodes again to inode cache.
> 
> As READDIRPLUS request fetches attributes also, doing getattr on each
> file on server, it causes unnecessary disk accesses. If READDIRPLUS on
> NFS client is returned with -ENOTSUPP, NFS client uses READDIR request
> which just gets the names of the files in a directory, not attributes,
> hence avoiding disk accesses on server.
> 
> There's already a corresponding client-side mount option, but an export
> option reduces the need for configuration across multiple clients.
> 
> This flag affects NFSv3 only.  If it turns out it's needed for NFSv4 as
> well then we may have to figure out how to extend the behavior to NFSv4,
> but it's not currently obvious how to do that.
> 
> ------
> 
> Signed-off-by: Rajesh Ghanekar <rajesh_ghanekar@symantec.com>
> 
> diff -uprN nfs-utils-1.3.0.old/support/include/nfs/export.h nfs-utils-1.3.0/support/include/nfs/export.h
> --- nfs-utils-1.3.0.old/support/include/nfs/export.h	2014-03-25 20:42:07.000000000 +0530
> +++ nfs-utils-1.3.0/support/include/nfs/export.h	2014-08-18 22:28:24.420262810 +0530
> @@ -17,7 +17,8 @@
>  #define NFSEXP_ALLSQUASH	0x0008
>  #define NFSEXP_ASYNC		0x0010
>  #define NFSEXP_GATHERED_WRITES	0x0020
> -/* 40, 80, 100 unused */
> +#define NFSEXP_NOREADDIRPLUS	0x0040
> +/* 80, 100 unused */
>  #define NFSEXP_NOHIDE		0x0200
>  #define NFSEXP_NOSUBTREECHECK	0x0400
>  #define NFSEXP_NOAUTHNLM	0x0800
> diff -uprN nfs-utils-1.3.0.old/support/nfs/exports.c nfs-utils-1.3.0/support/nfs/exports.c
> --- nfs-utils-1.3.0.old/support/nfs/exports.c	2014-03-25 20:42:07.000000000 +0530
> +++ nfs-utils-1.3.0/support/nfs/exports.c	2014-08-18 22:28:24.600262814 +0530
> @@ -273,6 +273,8 @@ putexportent(struct exportent *ep)
>  		"in" : "");
>  	fprintf(fp, "%sacl,", (ep->e_flags & NFSEXP_NOACL)?
>  		"no_" : "");
> +	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
> +		fprintf(fp, "nordirplus,");
>  	if (ep->e_flags & NFSEXP_FSID) {
>  		fprintf(fp, "fsid=%d,", ep->e_fsid);
>  	}
> @@ -539,6 +541,8 @@ parseopts(char *cp, struct exportent *ep
>  			clearflags(NFSEXP_ASYNC, active, ep);
>  		else if (!strcmp(opt, "async"))
>  			setflags(NFSEXP_ASYNC, active, ep);
> +		else if (!strcmp(opt, "nordirplus"))
> +			setflags(NFSEXP_NOREADDIRPLUS, active, ep);
>  		else if (!strcmp(opt, "nohide"))
>  			setflags(NFSEXP_NOHIDE, active, ep);
>  		else if (!strcmp(opt, "hide"))
> diff -uprN nfs-utils-1.3.0.old/utils/exportfs/exports.man nfs-utils-1.3.0/utils/exportfs/exports.man
> --- nfs-utils-1.3.0.old/utils/exportfs/exports.man	2014-03-25 20:42:07.000000000 +0530
> +++ nfs-utils-1.3.0/utils/exportfs/exports.man	2014-08-18 22:27:23.360261358 +0530
> @@ -360,6 +360,13 @@ supported so the same configuration can
>  kernels alike.
>  
>  .TP
> +.IR nordirplus
> +This option will allow disabling READDIRPLUS request handling.
> +When enabled, READDIRPLUS requests from NFS client will be returned
> +with "not supported" reply. Most of the NFS client implementations
> +starts to use READDIR request if READDIRPLUS is returned with
> +"not supported" reply. This option is only applicable for NFSv3.
> +.TP
>  .IR refer= path@host[+host][:path@host[+host]]
>  A client referencing the export point will be directed to choose from
>  the given list an alternative location for the filesystem.
> 
> -----
> 
> Thanks,
> Rajesh
> 
> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Rajesh Ghanekar
> Sent: Monday, August 18, 2014 11:17 PM
> To: J. Bruce Fields; Steve Dickson
> Cc: Rishi Agrawal; linux-nfs@vger.kernel.org; Ram Pandiri; Sreeharsha Sarabu; Abhijit Dey; Tushar Shinde; bfields@redhat.com
> Subject: RE: [PATCH] nfsd: allow turning off nfsv3 readdir_plus
> 
> Hi Bruce, Steve,
>        Here is the nfs-utils patch reworked. Sorry for top posting, though.
> We had to wait for internal legal approval to complete, and hence got delayed. Same "signed-off" by signature can go to nfsd kernel patch which you have reworked. Please let me know if I need to resend (copy from your mail with signed-off added) nfsd kernel patch.
> 
> Signed-off-by: Rajesh Ghanekar <rajesh_ghanekar@symantec.com>
> 
> 
> diff -uprN nfs-utils-1.3.0.old/support/include/nfs/export.h nfs-utils-1.3.0/support/include/nfs/export.h
> --- nfs-utils-1.3.0.old/support/include/nfs/export.h	2014-03-25 20:42:07.000000000 +0530
> +++ nfs-utils-1.3.0/support/include/nfs/export.h	2014-08-18 22:28:24.420262810 +0530
> @@ -17,7 +17,8 @@
>  #define NFSEXP_ALLSQUASH	0x0008
>  #define NFSEXP_ASYNC		0x0010
>  #define NFSEXP_GATHERED_WRITES	0x0020
> -/* 40, 80, 100 unused */
> +#define NFSEXP_NOREADDIRPLUS	0x0040
> +/* 80, 100 unused */
>  #define NFSEXP_NOHIDE		0x0200
>  #define NFSEXP_NOSUBTREECHECK	0x0400
>  #define NFSEXP_NOAUTHNLM	0x0800
> diff -uprN nfs-utils-1.3.0.old/support/nfs/exports.c nfs-utils-1.3.0/support/nfs/exports.c
> --- nfs-utils-1.3.0.old/support/nfs/exports.c	2014-03-25 20:42:07.000000000 +0530
> +++ nfs-utils-1.3.0/support/nfs/exports.c	2014-08-18 22:28:24.600262814 +0530
> @@ -273,6 +273,8 @@ putexportent(struct exportent *ep)
>  		"in" : "");
>  	fprintf(fp, "%sacl,", (ep->e_flags & NFSEXP_NOACL)?
>  		"no_" : "");
> +	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
> +		fprintf(fp, "nordirplus,");
>  	if (ep->e_flags & NFSEXP_FSID) {
>  		fprintf(fp, "fsid=%d,", ep->e_fsid);
>  	}
> @@ -539,6 +541,8 @@ parseopts(char *cp, struct exportent *ep
>  			clearflags(NFSEXP_ASYNC, active, ep);
>  		else if (!strcmp(opt, "async"))
>  			setflags(NFSEXP_ASYNC, active, ep);
> +		else if (!strcmp(opt, "nordirplus"))
> +			setflags(NFSEXP_NOREADDIRPLUS, active, ep);
>  		else if (!strcmp(opt, "nohide"))
>  			setflags(NFSEXP_NOHIDE, active, ep);
>  		else if (!strcmp(opt, "hide"))
> diff -uprN nfs-utils-1.3.0.old/utils/exportfs/exports.man nfs-utils-1.3.0/utils/exportfs/exports.man
> --- nfs-utils-1.3.0.old/utils/exportfs/exports.man	2014-03-25 20:42:07.000000000 +0530
> +++ nfs-utils-1.3.0/utils/exportfs/exports.man	2014-08-18 22:27:23.360261358 +0530
> @@ -360,6 +360,13 @@ supported so the same configuration can  kernels alike.
>  
>  .TP
> +.IR nordirplus
> +This option will allow disabling READDIRPLUS request handling.
> +When enabled, READDIRPLUS requests from NFS client will be returned 
> +with "not supported" reply. Most of the NFS client implementations 
> +starts to use READDIR request if READDIRPLUS is returned with "not 
> +supported" reply. This option is only applicable for NFSv3.
> +.TP
>  .IR refer= path@host[+host][:path@host[+host]]
>  A client referencing the export point will be directed to choose from  the given list an alternative location for the filesystem.
> 
> 
> Thanks,
> Rajesh
> 
> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Tuesday, August 05, 2014 11:52 PM
> To: Steve Dickson
> Cc: Rishi Agrawal; linux-nfs@vger.kernel.org; Rajesh Ghanekar; Ram Pandiri; Sreeharsha Sarabu; Abhijit Dey; Tushar Shinde; bfields@redhat.com
> Subject: Re: [PATCH] nfsd: allow turning off nfsv3 readdir_plus
> 
> On Mon, Aug 04, 2014 at 05:46:47PM -0400, J. Bruce Fields wrote:
> > On Mon, Aug 04, 2014 at 11:24:11AM -0400, bfields wrote:
> > > +static int
> > > +nfsd3_is_readdirplus_supported(struct svc_rqst *rqstp, struct 
> > > +svc_fh *fhp) {
> > > +	struct svc_export *exp;
> > > +	int supported = 1; /* fall back to readdirplus supported in case of errors.*/
> > > +	int err;
> > > +
> > > +	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_READ);
> > > +	if (err) {
> > > +		goto out;
> > > +	}
> > 
> > Actually, this isn't right: errors from fh_verify should be returned 
> > to the client or weird things could happen (e.g. what should have been 
> > a transient DELAY error could result in the client turning off 
> > readdirplus).
> 
> Apologies, I misread: as the comment above notes, it falls back on allowing readdirplus when this fails, so I don't think there's a real bug here.
> 
> > And MAY_READ is more than nfsd_readdir actually asks for, I think, 
> > probably should just be MAY_NOP here.
> > 
> > I'll fix that up.--b.
> 
> But it's probably still better to return the fh_verify error on failure, as follows.
> 
> --b.
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c index 72ffd7cce3c3..30a739d896ff 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -1145,6 +1145,7 @@ static struct flags {
>  	{ NFSEXP_ALLSQUASH, {"all_squash", ""}},
>  	{ NFSEXP_ASYNC, {"async", "sync"}},
>  	{ NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
> +	{ NFSEXP_NOREADDIRPLUS, {"nordirplus", ""}},
>  	{ NFSEXP_NOHIDE, {"nohide", ""}},
>  	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
>  	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}}, diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c index fa2525b2e9d7..247b06fb400d 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -471,6 +471,14 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
>  	resp->buflen = resp->count;
>  	resp->rqstp = rqstp;
>  	offset = argp->cookie;
> +
> +	nfserr = fh_verify(rqstp, &resp->fh, S_IFDIR, NFSD_MAY_NOP);
> +	if (nfserr)
> +		RETURN_STATUS(nfserr);
> +
> +	if (resp->fh.fh_export->ex_flags & NFSEXP_NOREADDIRPLUS)
> +		RETURN_STATUS(nfserr_notsupp);
> +
>  	nfserr = nfsd_readdir(rqstp, &resp->fh,
>  				     &offset,
>  				     &resp->common,
> diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
> index cf47c313794e..584b6ef3a5e8 100644
> --- a/include/uapi/linux/nfsd/export.h
> +++ b/include/uapi/linux/nfsd/export.h
> @@ -28,7 +28,8 @@
>  #define NFSEXP_ALLSQUASH	0x0008
>  #define NFSEXP_ASYNC		0x0010
>  #define NFSEXP_GATHERED_WRITES	0x0020
> -/* 40 80 100 currently unused */
> +#define NFSEXP_NOREADDIRPLUS    0x0040
> +/* 80 100 currently unused */
>  #define NFSEXP_NOHIDE		0x0200
>  #define NFSEXP_NOSUBTREECHECK	0x0400
>  #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
> @@ -47,7 +48,7 @@
>   */
>  #define	NFSEXP_V4ROOT		0x10000
>  /* All flags that we claim to support.  (Note we don't support NOACL.) */
> -#define NFSEXP_ALLFLAGS		0x17E3F
> +#define NFSEXP_ALLFLAGS		0x1FE7F
>  
>  /* The flags that may vary depending on security flavor: */
>  #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
