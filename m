From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: reconnect_path() breaks NFS server causing occasional EACCES
Date: Mon, 7 Apr 2008 21:55:19 +0200
Message-ID: <20080407195519.GA5249@janus>
References: <20080404102449.GA10209@janus> <20080407184346.GF3305@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@lst.de>, Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:58151 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751678AbYDGTzW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2008 15:55:22 -0400
In-Reply-To: <20080407184346.GF3305@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 07, 2008 at 02:43:46PM -0400, J. Bruce Fields wrote:
> Thanks for the patch and the nice test case....
> 
> On Fri, Apr 04, 2008 at 12:24:49PM +0200, Frank van Maarseveen wrote:
> > Occasionally we experience EACCES errors which are caused by the exportfs
> > reconnect_path() function called by the NFS server (NFSv3). The following
> > reproduces it reliably on the client.
> 
> OK, so you're trying to use a directory that you previously descended
> into, but that you no longer have the right to look up?

Correct. Based on identity and permission bits the process should have
access but it no longer has.

> 
> > 
> > Compile cd-droppriv.c and make it setuid root:
> > --------
> > #include <stdio.h>
> > #include <stdarg.h>
> > #include <unistd.h>
> > #include <string.h>
> > #include <stdlib.h>
> > #include <errno.h>
> > #include <dirent.h>
> > 
> > void die(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
> > void die(const char *fmt, ...)
> > {
> > 	va_list ap;
> > 
> > 	va_start(ap, fmt);
> > 	fprintf(stderr, "cd-droppriv: ");
> > 	vfprintf(stderr, fmt, ap);
> > 	va_end(ap);
> > 	exit(1);
> > }
> > 
> > int main(int argc, char **argv)
> > {
> > 	if (chdir(argv[1]) == -1)
> > 		die("chdir: %s\n", strerror(errno));
> > 	if (setuid(getuid()) == -1)
> > 		die("setuid: %s\n", strerror(errno));
> > 	printf("Restart the NFS server then press <enter>.\n");
> > 	getchar();
> > 	if (opendir(".") == NULL)
> > 		die("opendir: %s\n", strerror(errno));
> > 	return 0;
> > }
> > --------
> > 
> > As root, create a directory tree on the client. The export options on
> > the server for /mnt include no_root_squash and no_subtree_check:
> > 
> > 	mkdir -p /mnt/a/b
> > 	chmod 700 /mnt/a
> > 	chmod 777 /mnt/a/b
> > 
> > Run the program as non-root on the client:
> > 
> > 	cd-droppriv /mnt/a/b
> > 
> > and press <enter>. When the server is restarted before pressing <enter>
> > opendir() fails with EACCES:
> > 
> > 	cd-droppriv: opendir: Permission denied
> > 
> > This happens too when dentries are dropped on the server due to memory
> > pressure. The following seems to fix the problem (2.6.24.4):
> > 
> > --- ./fs/exportfs/expfs.c.orig	2008-02-04 14:24:21.000000000 +0100
> > +++ ./fs/exportfs/expfs.c	2008-04-03 18:00:20.000000000 +0200
> > @@ -170,7 +170,7 @@ reconnect_path(struct vfsmount *mnt, str
> >  			}
> >  			dprintk("%s: found name: %s\n", __FUNCTION__, nbuf);
> >  			mutex_lock(&ppd->d_inode->i_mutex);
> > -			npd = lookup_one_len(nbuf, ppd, strlen(nbuf));
> > +			npd = lookup_one_noperm(nbuf, ppd);
> 
> Anyone who depends on the "x" bit to control access to objects in an
> nfs-exported filesystem is already in trouble.  We could do so for
> directories (at the expense of non-posix-like behavior such as what
> you've seen), but we probably can't for files.  So I'm inclined to think
> this is the right thing to do.

Several file access issues have been fixed in the past. Redirecting
output of setuid-root programs (X server) when squash_root is in effect
and paging in execute-only files over NFS comes to my mind.

> 
> The "DON'T USE THIS FUNCTION EVER, thanks." suggests we should at least
> consult the person who added that comment (cc'd) before adding a call to
> lookup_one_noperm().  (And if we decide to do this, we should make a
> note of this in that comment.)

yes.

> 
> Also, I'm curious: could you explain how you hit this In Real Life,
> before you made this test case?

The NFS patch to deal with >16 groups on NFSv3 with AUTH_SYS I maintain
on www.frankvm.com/nfs-ngroups hit this problem first. Interactive shells
became unusable after a nightly run server mirroring script expelled
a lot of dentries from memory. The nfs-ngroups patch makes the client
picky about which groups to use in NFS requests in order to avoid the
16 groups limit.

> 
> --b.
> 
> >  			mutex_unlock(&ppd->d_inode->i_mutex);
> >  			if (IS_ERR(npd)) {
> >  				err = PTR_ERR(npd);
> > @@ -447,8 +447,7 @@ struct dentry *exportfs_decode_fh(struct
> >  		err = exportfs_get_name(mnt, target_dir, nbuf, result);
> >  		if (!err) {
> >  			mutex_lock(&target_dir->d_inode->i_mutex);
> > -			nresult = lookup_one_len(nbuf, target_dir,
> > -						 strlen(nbuf));
> > +			nresult = lookup_one_noperm(nbuf, target_dir);
> >  			mutex_unlock(&target_dir->d_inode->i_mutex);
> >  			if (!IS_ERR(nresult)) {
> >  				if (nresult->d_inode) {
> > 
> > -- 
> > Frank
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Frank
