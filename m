Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tus1smtoutpex02.symantec.com ([216.10.195.242]:49754 "EHLO
	tus1smtoutpex02.symantec.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752370AbaHTMv1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 08:51:27 -0400
Date: Wed, 20 Aug 2014 18:21:13 +0530
From: Rajesh Ghanekar <rajesh_ghanekar@symantec.com>
To: Steve Dickson <SteveD@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Abhijit Dey <Abhijit_Dey@symantec.com>,
        Sreeharsha Sarabu <Sreeharsha_Sarabu@symantec.com>,
        Ram Pandiri <ram_pandiri@symantec.com>,
        Rishi Agrawal <Rishi_Agrawal@symantec.com>,
        Tushar Shinde <Tushar_Shinde@symantec.com>
Subject: Re: [PATCH] nfs-utils: Allow turning off nfsv3 readdir_plus
Message-ID: <20140820125102.GA9992@electron>
References: <53F44A4F.605@symantec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <53F44A4F.605@symantec.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2014 at 12:12:15AM -0700, Rajesh Ghanekar wrote:
> Hi Steve,
>     Please see the nfs-utils patch for making readdir_plus
> configurable for NFSv3. I already sent it in
> "[PATCH] nfsd: allow turning off nfsv3 readdir_plus", so
> apologies for resending, but I thought to make its own subject.
> Let me know if you think any changes are required.

Resending as my mail client did "tab to spaces" conversion.
Corrected now, hopefully.

From: Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>

One of our customer's application only needs file names, not file
attributes. With directories having 10K+ inodes (assuming buffer cache
has directory blocks cached having file names, but inode cache is
limited and hence need eviction of older cached inodes), older inodes
are evicted periodically. So if they keep on doing readdir(2) from NSF
client on multiple directories, some directory's files are periodically
removed from inode cache and hence new readdir(2) on same directory
requires disk access to bring back inodes again to inode cache.

As READDIRPLUS request fetches attributes also, doing getattr on each
file on server, it causes unnecessary disk accesses. If READDIRPLUS on
NFS client is returned with -ENOTSUPP, NFS client uses READDIR request
which just gets the names of the files in a directory, not attributes,
hence avoiding disk accesses on server.

There's already a corresponding client-side mount option, but an export
option reduces the need for configuration across multiple clients.

This flag affects NFSv3 only.  If it turns out it's needed for NFSv4 as
well then we may have to figure out how to extend the behavior to NFSv4,
but it's not currently obvious how to do that.

-----

Signed-off-by: Rajesh Ghanekar <rajesh_ghanekar@symantec.com>

diff -uprN nfs-utils-1.3.0.old/support/include/nfs/export.h nfs-utils-1.3.0/support/include/nfs/export.h
--- nfs-utils-1.3.0.old/support/include/nfs/export.h	2014-03-25 20:42:07.000000000 +0530
+++ nfs-utils-1.3.0/support/include/nfs/export.h	2014-08-18 22:28:24.420262810 +0530
@@ -17,7 +17,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40, 80, 100 unused */
+#define NFSEXP_NOREADDIRPLUS	0x0040
+/* 80, 100 unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define NFSEXP_NOAUTHNLM	0x0800
diff -uprN nfs-utils-1.3.0.old/support/nfs/exports.c nfs-utils-1.3.0/support/nfs/exports.c
--- nfs-utils-1.3.0.old/support/nfs/exports.c	2014-03-25 20:42:07.000000000 +0530
+++ nfs-utils-1.3.0/support/nfs/exports.c	2014-08-18 22:28:24.600262814 +0530
@@ -273,6 +273,8 @@ putexportent(struct exportent *ep)
 		"in" : "");
 	fprintf(fp, "%sacl,", (ep->e_flags & NFSEXP_NOACL)?
 		"no_" : "");
+	if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
+		fprintf(fp, "nordirplus,");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
@@ -539,6 +541,8 @@ parseopts(char *cp, struct exportent *ep
 			clearflags(NFSEXP_ASYNC, active, ep);
 		else if (!strcmp(opt, "async"))
 			setflags(NFSEXP_ASYNC, active, ep);
+		else if (!strcmp(opt, "nordirplus"))
+			setflags(NFSEXP_NOREADDIRPLUS, active, ep);
 		else if (!strcmp(opt, "nohide"))
 			setflags(NFSEXP_NOHIDE, active, ep);
 		else if (!strcmp(opt, "hide"))
diff -uprN nfs-utils-1.3.0.old/utils/exportfs/exports.man nfs-utils-1.3.0/utils/exportfs/exports.man
--- nfs-utils-1.3.0.old/utils/exportfs/exports.man	2014-03-25 20:42:07.000000000 +0530
+++ nfs-utils-1.3.0/utils/exportfs/exports.man	2014-08-19 12:32:30.498780854 +0530
@@ -360,6 +360,11 @@ supported so the same configuration can
 kernels alike.
 
 .TP
+.IR nordirplus
+This option will disable READDIRPLUS request handling.  When set,
+READDIRPLUS requests from NFS clients return NFS3ERR_NOTSUPP, and
+clients fall back on READDIR.  This option affects only NFSv3 clients.
+.TP
 .IR refer= path@host[+host][:path@host[+host]]
 A client referencing the export point will be directed to choose from
 the given list an alternative location for the filesystem.

-----

Thanks,
Rajesh

> 
> From: Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>
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
> -----
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
> +++ nfs-utils-1.3.0/utils/exportfs/exports.man	2014-08-19 12:32:30.498780854 +0530
> @@ -360,6 +360,11 @@ supported so the same configuration can
>  kernels alike.
>  
>  .TP
> +.IR nordirplus
> +This option will disable READDIRPLUS request handling.  When set,
> +READDIRPLUS requests from NFS clients return NFS3ERR_NOTSUPP, and
> +clients fall back on READDIR.  This option affects only NFSv3 clients.
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
