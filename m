From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: Bug#476577: corrected patch
Date: Mon, 21 Apr 2008 00:34:16 +0200
Message-ID: <20080420223416.GA12722@uio.no>
References: <20080417200928.GA20809@kodama.kitenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Joey Hess <joeyh@debian.org>, 476577@bugs.debian.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:53544 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbYDTWeY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Apr 2008 18:34:24 -0400
In-Reply-To: <20080417200928.GA20809-goE9YToxfH7EOVZ/abRnzaxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys,

Would you please consider this patch for inclusion into upstream? It looks
more than reasonable to me, at least.

/* Steinar */

On Thu, Apr 17, 2008 at 04:09:28PM -0400, Joey Hess wrote:
> Hmm, nmudiff did not send in the patch I expected. Here is a
> corrected/tested one.
> 
> -- 
> see shy jo

> diff -ur foo/nfs-utils-1.1.2/debian/changelog nfs-utils-1.1.2/debian/changelog
> --- foo/nfs-utils-1.1.2/debian/changelog	2008-04-17 16:06:27.000000000 -0400
> +++ nfs-utils-1.1.2/debian/changelog	2008-04-17 15:33:41.000000000 -0400
> @@ -1,3 +1,10 @@
> +nfs-utils (1:1.1.2-2.1) UNRELEASED; urgency=low
> +
> +  * Avoid writing to or fchmodding /etc/mtab if it is a symlink.
> +    Closes: #476577
> +
> + -- Joey Hess <joeyh@debian.org>  Thu, 17 Apr 2008 15:30:49 -0400
> +
>  nfs-utils (1:1.1.2-2) unstable; urgency=low
>  
>    * Remove ${misc:Depends} from binary variables -- it is not used, and not
> diff -ur foo/nfs-utils-1.1.2/utils/mount/fstab.c nfs-utils-1.1.2/utils/mount/fstab.c
> --- foo/nfs-utils-1.1.2/utils/mount/fstab.c	2008-03-14 11:46:29.000000000 -0400
> +++ nfs-utils-1.1.2/utils/mount/fstab.c	2008-04-17 15:40:01.000000000 -0400
> @@ -52,7 +52,7 @@
>  	return var_mtab_does_not_exist;
>  }
>  
> -static int
> +int
>  mtab_is_a_symlink(void) {
>          get_mtab_info();
>          return var_mtab_is_a_symlink;
> diff -ur foo/nfs-utils-1.1.2/utils/mount/fstab.h nfs-utils-1.1.2/utils/mount/fstab.h
> --- foo/nfs-utils-1.1.2/utils/mount/fstab.h	2008-03-14 11:46:29.000000000 -0400
> +++ nfs-utils-1.1.2/utils/mount/fstab.h	2008-04-17 15:38:30.000000000 -0400
> @@ -7,6 +7,7 @@
>  #define _PATH_FSTAB "/etc/fstab"
>  #endif
>  
> +int mtab_is_a_symlink(void);
>  int mtab_is_writable(void);
>  int mtab_does_not_exist(void);
>  
> diff -ur foo/nfs-utils-1.1.2/utils/mount/mount.c nfs-utils-1.1.2/utils/mount/mount.c
> --- foo/nfs-utils-1.1.2/utils/mount/mount.c	2008-03-14 11:46:29.000000000 -0400
> +++ nfs-utils-1.1.2/utils/mount/mount.c	2008-04-17 15:39:34.000000000 -0400
> @@ -257,6 +257,13 @@
>  		return EX_SUCCESS;
>  	}
>  
> +        /* Avoid writing if the mtab is a symlink to /proc/mounts, since
> +	   that would create a file /proc/mounts in case the proc filesystem
> +           is not mounted, and the fchmod below would also fail. */
> +	if (mtab_is_a_symlink()) {
> +		return EX_SUCCESS;
> +	}
> +
>  	lock_mtab();
>  
>  	mtab = nfs_setmntent(MOUNTED, "a+");




-- 
Homepage: http://www.sesse.net/
