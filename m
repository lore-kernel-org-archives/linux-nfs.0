From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Tue, 26 Oct 2004 17:32:07 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098775926.21421.371.camel@hole.melbourne.sgi.com>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
	 <1098413781.21421.37.camel@hole.melbourne.sgi.com>
	 <20041022024349.GA30004@fieldses.org>
	 <1098696830.21421.163.camel@hole.melbourne.sgi.com>
	 <1098715298.10720.38.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "Dr. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMLVW-0002sQ-4i
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 00:12:38 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CMLVU-0001fc-Ld
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 00:12:38 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1098715298.10720.38.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 2004-10-26 at 00:41, Trond Myklebust wrote:
> m=E5 den 25.10.2004 Klokka 19:33 (+1000) skreiv Greg Banks:
>=20
> > Trond, I don't think it's a good idea to make no_subtree_check the
> > default, as this would have the undesirable side effect of defeating
> > directory permission checks.  Perhaps we can just make it behave
> > more helpfully.
>=20
> If by "make it behave more helpfully" you mean get rid of the aliased
> filehandles, then I'm fine with that. I'm curious to see how you propose
> to do it though: as far as I can see there is no way to reconcile the
> goal of proper directory permission checks and sane filehandle
> behaviour.

Ok you've convinced me, and ->splat<- is the sound of an open can
of worms hitting the Too Hard basket.

Trond, I see you've got a fix for the nfs_rename() dentry refcount bug=20
in your 2.6.10-rc1 patchset, thanks.

> Since the permissions problem is solvable in other ways (i.e. by only
> exporting partitions/volumes), and in fact that is the way all other
> known NFS server implementations expect you to solve the problem,

When the problem is solved at all...OTOH those other OSes don't
have dentry caches which want to remain connected, so Linux is a
special case.

>  then I
> see no problems with making that the default.

Well, you can have that discussion with Neil.

> Look more closely: get_parent() expects the parameter to be a directory.
> I don't think ext2/3 or XFS encode a list of parent directories in the
> on-disk inode for a regular file.

Good point.

BTW, the following hunk is in your 2.6.10-rc1 NFS_ALL.dif but missing
from the corresponding exploded patchset.


--- linux-2.6.10-rc1-up/fs/nfs/file.c	2004-10-25 15:31:13.000000000 -0400
+++ linux-2.6.10-rc1-NFS_ALL/fs/nfs/file.c	2004-10-25 19:08:55.000000000 -0=
400
@@ -396,15 +413,6 @@ nfs_lock(struct file *filp, int cmd, str
 	if ((inode->i_mode & (S_ISGID | S_IXGRP)) =3D=3D S_ISGID)
 		return -ENOLCK;
=20
-	if (NFS_PROTO(inode)->version !=3D 4) {
-		/* Fake OK code if mounted without NLM support */
-		if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) {
-			if (IS_GETLK(cmd))
-				return LOCK_USE_CLNT;
-			return 0;
-		}
-	}
-
 	/*
 	 * No BSD flocks over NFS allowed.
 	 * Note: we could try to fake a POSIX lock request here by

Greg.
--=20
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
