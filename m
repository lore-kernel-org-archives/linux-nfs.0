From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 3/3] mountd: fix crossmnt options in v2/v3 case
Date: Sun, 7 Mar 2010 16:58:26 -0500
Message-ID: <20100307215826.GA14104@fieldses.org>
References: <20100307200607.GA13006@fieldses.org> <1267992481-13332-1-git-send-email-bfields@citi.umich.edu> <1267992481-13332-2-git-send-email-bfields@citi.umich.edu> <1267992481-13332-3-git-send-email-bfields@citi.umich.edu> <20100308082516.260e5f70@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54454 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709Ab0CGV5I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Mar 2010 16:57:08 -0500
In-Reply-To: <20100308082516.260e5f70-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 08, 2010 at 08:25:16AM +1100, Neil Brown wrote:
> On Sun,  7 Mar 2010 15:08:01 -0500
> "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> 
> > The extra cache entries added here all get the options of the parent
> > export.  This is incorrect, since once of the children may be explicitly
> > exported with different options, and the parent crossmnt shouldn't
> > override the explicit child export.
> > 
> > What's more, this is unnecessary, since in the newcache case we'll
> > request these on demand when we need them.
> 
> Are you sure that removing this doesn't break something else?

Maybe so--thanks for looking at this.

> It was explicitly added in commit 323d1c4d69b65ab36d, apparently for a good
> reason.
> 
> Also, it shouldn't be causing the problem described as cache_export_ent
> should only be called where 'exp' is the lowest (furthest from the root)
> export for any directory in 'path'.

Hm.  Is nfsd_fh() following that rule?

> So any child mounts that are found should not be explicitly exported.
>
> This code is needed to handle a case where you have
> /a /a/b /a/b/c all mount points, /a is exported with crossmnt,
> and a mount request comes in for /a/b/c (or /a/b).
> mountd needs to get the filehandle for /a/b/c, so that filesystem must be
> exported to the kernel.

Yes, I didn't look carefully enough.  I think I must have assumed the
first dump_to_cache did that.  But wouldn't it be sufficient to just do:

	dump_to_cache(f, domain, path, e_path);

(as in the below) instead of also running through all the parents?

> We cannot really on upcalls filling in that
> information as doing so would cause mountd to deadlock - it asks the kernel
> for a filehandle, the kernel asks it for export information, and mountd is
> single-threaded...

Don't we have this problem already, then?  The export cache really is
just a cache, and we should be prepared for a given entry to be purged
at any time.

--b.

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 7dec468..f682a9b 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -810,53 +810,13 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
 	if (!f)
 		return -1;
 
-	err = dump_to_cache(f, domain, exp->e_path, exp);
+	err = dump_to_cache(f, domain, path, exp);
 	if (err) {
 		xlog(L_WARNING,
 		     "Cannot export %s, possibly unsupported filesystem or"
 		     " fsid= required", exp->e_path);
 	}
 
-	while (err == 0 && (exp->e_flags & NFSEXP_CROSSMOUNT) && path) {
-		/* really an 'if', but we can break out of
-		 * a 'while' more easily */
-		/* Look along 'path' for other filesystems
-		 * and export them with the same options
-		 */
-		struct stat stb;
-		int l = strlen(exp->e_path);
-		int dev;
-
-		if (strlen(path) <= l || path[l] != '/' ||
-		    strncmp(exp->e_path, path, l) != 0)
-			break;
-		if (stat(exp->e_path, &stb) != 0)
-			break;
-		dev = stb.st_dev;
-		while(path[l] == '/') {
-			char c;
-			/* errors for submount should fail whole filesystem */
-			int err2;
-
-			l++;
-			while (path[l] != '/' && path[l])
-				l++;
-			c = path[l];
-			path[l] = 0;
-			err2 = lstat(path, &stb);
-			path[l] = c;
-			if (err2 < 0)
-				break;
-			if (stb.st_dev == dev)
-				continue;
-			dev = stb.st_dev;
-			path[l] = 0;
-			dump_to_cache(f, domain, path, exp);
-			path[l] = c;
-		}
-		break;
-	}
-
 	fclose(f);
 	return err;
 }
