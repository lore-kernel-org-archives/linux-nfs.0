From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: reconnect_path() breaks NFS server causing occasional EACCES
Date: Mon, 7 Apr 2008 14:43:46 -0400
Message-ID: <20080407184346.GF3305@fieldses.org>
References: <20080404102449.GA10209@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@lst.de>, Neil Brown <neilb@suse.de>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036AbYDGSnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Apr 2008 14:43:49 -0400
In-Reply-To: <20080404102449.GA10209@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the patch and the nice test case....

On Fri, Apr 04, 2008 at 12:24:49PM +0200, Frank van Maarseveen wrote:
> Occasionally we experience EACCES errors which are caused by the exportfs
> reconnect_path() function called by the NFS server (NFSv3). The following
> reproduces it reliably on the client.

OK, so you're trying to use a directory that you previously descended
into, but that you no longer have the right to look up?

> 
> Compile cd-droppriv.c and make it setuid root:
> --------
> #include <stdio.h>
> #include <stdarg.h>
> #include <unistd.h>
> #include <string.h>
> #include <stdlib.h>
> #include <errno.h>
> #include <dirent.h>
> 
> void die(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
> void die(const char *fmt, ...)
> {
> 	va_list ap;
> 
> 	va_start(ap, fmt);
> 	fprintf(stderr, "cd-droppriv: ");
> 	vfprintf(stderr, fmt, ap);
> 	va_end(ap);
> 	exit(1);
> }
> 
> int main(int argc, char **argv)
> {
> 	if (chdir(argv[1]) == -1)
> 		die("chdir: %s\n", strerror(errno));
> 	if (setuid(getuid()) == -1)
> 		die("setuid: %s\n", strerror(errno));
> 	printf("Restart the NFS server then press <enter>.\n");
> 	getchar();
> 	if (opendir(".") == NULL)
> 		die("opendir: %s\n", strerror(errno));
> 	return 0;
> }
> --------
> 
> As root, create a directory tree on the client. The export options on
> the server for /mnt include no_root_squash and no_subtree_check:
> 
> 	mkdir -p /mnt/a/b
> 	chmod 700 /mnt/a
> 	chmod 777 /mnt/a/b
> 
> Run the program as non-root on the client:
> 
> 	cd-droppriv /mnt/a/b
> 
> and press <enter>. When the server is restarted before pressing <enter>
> opendir() fails with EACCES:
> 
> 	cd-droppriv: opendir: Permission denied
> 
> This happens too when dentries are dropped on the server due to memory
> pressure. The following seems to fix the problem (2.6.24.4):
> 
> --- ./fs/exportfs/expfs.c.orig	2008-02-04 14:24:21.000000000 +0100
> +++ ./fs/exportfs/expfs.c	2008-04-03 18:00:20.000000000 +0200
> @@ -170,7 +170,7 @@ reconnect_path(struct vfsmount *mnt, str
>  			}
>  			dprintk("%s: found name: %s\n", __FUNCTION__, nbuf);
>  			mutex_lock(&ppd->d_inode->i_mutex);
> -			npd = lookup_one_len(nbuf, ppd, strlen(nbuf));
> +			npd = lookup_one_noperm(nbuf, ppd);

Anyone who depends on the "x" bit to control access to objects in an
nfs-exported filesystem is already in trouble.  We could do so for
directories (at the expense of non-posix-like behavior such as what
you've seen), but we probably can't for files.  So I'm inclined to think
this is the right thing to do.

The "DON'T USE THIS FUNCTION EVER, thanks." suggests we should at least
consult the person who added that comment (cc'd) before adding a call to
lookup_one_noperm().  (And if we decide to do this, we should make a
note of this in that comment.)

Also, I'm curious: could you explain how you hit this In Real Life,
before you made this test case?

--b.

>  			mutex_unlock(&ppd->d_inode->i_mutex);
>  			if (IS_ERR(npd)) {
>  				err = PTR_ERR(npd);
> @@ -447,8 +447,7 @@ struct dentry *exportfs_decode_fh(struct
>  		err = exportfs_get_name(mnt, target_dir, nbuf, result);
>  		if (!err) {
>  			mutex_lock(&target_dir->d_inode->i_mutex);
> -			nresult = lookup_one_len(nbuf, target_dir,
> -						 strlen(nbuf));
> +			nresult = lookup_one_noperm(nbuf, target_dir);
>  			mutex_unlock(&target_dir->d_inode->i_mutex);
>  			if (!IS_ERR(nresult)) {
>  				if (nresult->d_inode) {
> 
> -- 
> Frank
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
