From: "Lever, Charles" <cel@netapp.com>
Subject: RE: [RFC]: ESTALE is not a permanent error
Date: Thu, 23 Sep 2004 10:17:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07E30@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAXE1-0007Tb-NU
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 10:17:45 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CAXDz-0001uH-Q0
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 10:17:45 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> P=E5 to , 23/09/2004 klokka 00:27, skreiv Trond Myklebust:
>=20
> > Honestly, if the server returns ESTALE, then we do *NOT TRUST* that=20
> > the inode resulting from the "temporary" situation is the=20
> same as the=20
> > inode that existed before.
>=20
> To clarify (once again!) what I mean here:
>=20
>  If the client receives an ESTALE error, then it will drop=20
> all pending reads/writes like a stone, so it is not as if=20
> this is an error that the kernel can recover from=20
> automatically. Better that the customer be told right up=20
> front that something stupid has happened on the server, and=20
> it is up to them to fix the problem manually.

ok, i think you misunderstood me.

i understand that ESTALE means you can't trust a file handle.  the =
problem is the Linux NFS client is completely inconsistent about how it =
deals with an ESTALE result.

here's one example path (2.6):  suppose the attribute cache for a =
directory is good, but we want to do a permission check.  =
nfs_revalidate_inode is a no-op because the cache hasn't expired, but =
suppose the ACCESS operation returns ESTALE.  the inode is not marked =
ESTALE at that point, so if the ESTALE condition goes away on the =
server, operation on the client continues normally.

if, on the other hand, the cache had actually timed out and the =
nfs_revalidate_inode resulted in a GETATTR operation, the inode would =
have been marked permanently stale.  thus, in most cases, the behavior =
of the client and the treatment of the ESTALE error is based on whether =
the client's cache has timed out or not. =20

__nfs_revalidate_inode is allowed to clear NFS_INO_STALE.  in what cases =
is this a good idea if "we can't ever trust the file handle anymore?"  =
if __nfs_revalidate_inode is allowed to clear NFS_INO_STALE, why can't =
nfs_lookup_revalidate?

how is it OK to trust a file handle after a umount/mount, but not OK to =
trust a successful LOOKUP result?  why is it OK to trust a file handle =
after an unexport/export if the client didn't see any ESTALE result =
during that period?

if we're dealing with the root directory, it will never go stale, but =
anything else in the mounted file system can go stale.  (yes, i know =
there are technical reasons for this).

so there's no real architecture about how the current Linux NFS client =
treats ESTALE.  sometimes the client trusts a temporarily stale file =
handle, sometimes it doesn't.  if ESTALE means the client *truly* can't =
trust a file handle anymore, then the current client implementation is =
seriously deficient.

so the question is:  what are we going to do to make the client behave =
consistently and usefully in the face of most typical scenarios when a =
stale file handle is reported?


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
