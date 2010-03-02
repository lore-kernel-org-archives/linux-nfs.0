From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with crossmnt since 1.2.1
Date: Mon, 1 Mar 2010 22:20:02 -0500
Message-ID: <20100302032002.GA29212@fieldses.org>
References: <20100228100643.GG26178@teal.hq.k1024.org> <20100301204010.GE23539@fieldses.org> <20100301211306.GA16341@teal.hq.k1024.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51356 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508Ab0CBDSy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 22:18:54 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1NmIeR-0007eb-0Q
	for linux-nfs@vger.kernel.org; Mon, 01 Mar 2010 22:20:03 -0500
In-Reply-To: <20100301211306.GA16341-kWFYwFCQMdQkLqoNrXjPMti2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 01, 2010 at 10:13:06PM +0100, Iustin Pop wrote:
> On Mon, Mar 01, 2010 at 03:40:10PM -0500, J. Bruce Fields wrote:
> > On Sun, Feb 28, 2010 at 11:06:43AM +0100, Iustin Pop wrote:
> > > Since nfs-utils 1.2.1, there are some problems with crossmnt usage. See
> > > Debian bug http://bugs.debian.org/567546, but in short the problem seems
> > > to be that sub-mounts (/a/b) take the top-level mount (/a) options
> > > instead of their own, due to a bug in how mountd generates the crossmnt
> > > subexports.
> > > 
> > > I checked that reverting the write_secinfo changes in commit
> > > bc0a6ab03089fc1ea4fea26ed9635c2cc918b01b fix the issue, but that might
> > > only be a side effect, not the actual cause.
> > > 
> > > A short test:
> > > - have /a and /a/b exported, with different flags (e.g. ro on /a, rw on
> > >   /a/b)
> > > - restart the mountd, clear exports, etc.
> > > - try a mount on the client of /a/b, it gets readonly
> > > - umount & remount, it's now r/w
> > > - however, clearing the kernel export table (exportfs -f), makes the
> > >   next mount again get read-only 
> > > 
> > > Disabling crossmnt fixes the issue completely, so I would venture to
> > > guess that the subexports creation code has some issue, but I don't know
> > > enough of this to be able to debug it.
> > 
> > Thanks for the report.  What's the latest nfs-utils version you've
> > tested?
> 
> 1.2.2 - which is broken, as is 1.2.1. 1.2.0 works, because of the above
> commit which, again, I presume un-hides the problem.
> 
> Also there are reports of older versions being broken.
> 
> > On a quick skim of the latest code I see one clear bug
> > (path[strlen(path)] will never be '/'!), but that should have caused
> > crossmnt to never get enforced at all rather than to override anything.
> > 
> > Could you retest the latest from the upstream git, with this patch
> > applied, and see if the problem is still present?
> 
> I've tested right now with
> git://git.linux-nfs.org/projects/steved/nfs-utils.git (I hope this is the right
> upstream repo) plus the patch - still happens, no change.
> 
> One thing that is interesting is that only the first mount gets the
> wrong options, if the client unmounts and remounts (at this point the
> exports are in the kernel's cache) the options are right. As long as the
> kernel cache is populated, the options are right, if one clears the
> cache, the first mount will be wrong. Maybe this helps, I find it an
> interesting behaviour.
> 
> > Then if it is I'll try to go reproduce it myself....
> 
> For reference, here is the exports file I use for tests:
> /srv/nfs       client(sec=sys,ro,sync,fsid=0,subtree_check,crossmnt)
> /srv/nfs/homes client(sec=sys,rw,sync,subtree_check)
> 
> And here is the fstab entry on the client:
> server:/srv/nfs/homes /home     nfs     noauto,hard,bg,sec=sys,proto=tcp 0 0
> 
> The rest of the tools on server and client are Debian's nfs-utils 1.2.1
> (they have just a few, very trivial and unrelated, patches). The problem
> manifests (in my case) with both nfsv3/sec=sys and nfsv4/sec=krb*.

The loop in utils/mountd/cache.c:cache_export_ent() looks extremely
suspicious: it seems to be populating the kernel's export cache with
parameters taken from the parent export.  I can't see why that's
necessary at all--those exports can be looked up on demand later when
they're needed.  Something as simple as the following might help?
(Totally untested!)

--b.

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index d63e10a..7d87812 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -619,7 +619,7 @@ static int is_subdirectory(char *subpath, char *path)
 	int l = strlen(path);
 
 	return strcmp(subpath, path) == 0
-		|| (strncmp(subpath, path, l) == 0 && path[l] == '/');
+		|| (strncmp(subpath, path, l) == 0 && subpath[l] == '/');
 }
 
 static int path_matches(nfs_export *exp, char *path)
@@ -817,46 +817,6 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
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
