From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [RFC]: ESTALE is not a permanent error
Date: Fri, 24 Sep 2004 06:07:03 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1096031223.7240.44.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C611302B07E30@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CApnc-0004rv-Hf
	for nfs@lists.sourceforge.net; Fri, 24 Sep 2004 06:07:44 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CApnb-0004sy-R1
	for nfs@lists.sourceforge.net; Fri, 24 Sep 2004 06:07:44 -0700
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07E30@lavender-fe.eng.netapp.com>
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

P=E5 to , 23/09/2004 klokka 10:17, skreiv Lever, Charles:

> ok, i think you misunderstood me.
>=20
> i understand that ESTALE means you can't trust a file handle.  the proble=
m is the Linux NFS client is completely inconsistent about how it deals wit=
h an ESTALE result.

No. ESTALE means "access to this file has been revoked". Either the file
has been deleted, or your /etc/exports is denying you access.
The point is that the client cannot know which of the two it is dealing
with.

Again, see the whole problem of dealing with unfsd and others servers
that may reuse filehandles because they don't have inode generation
counters etc.

> here's one example path (2.6):  suppose the attribute cache for a directo=
ry is good, but we want to do a permission check.  nfs_revalidate_inode is =
a no-op because the cache hasn't expired, but suppose the ACCESS operation =
returns ESTALE.  the inode is not marked ESTALE at that point, so if the ES=
TALE condition goes away on the server, operation on the client continues n=
ormally.
>=20
> if, on the other hand, the cache had actually timed out and the nfs_reval=
idate_inode resulted in a GETATTR operation, the inode would have been mark=
ed permanently stale.  thus, in most cases, the behavior of the client and =
the treatment of the ESTALE error is based on whether the client's cache ha=
s timed out or not. =20
>=20
> __nfs_revalidate_inode is allowed to clear NFS_INO_STALE.  in what cases =
is this a good idea if "we can't ever trust the file handle anymore?"  if _=
_nfs_revalidate_inode is allowed to clear NFS_INO_STALE,

It is only allowed to clear NFS_INO_STALE if we're talking about the
root filehandle. We do assume the user will not delete that directory.

Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
