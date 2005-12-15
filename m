From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH]: NFS: fix inadvertent reversion of mode bits during chown
Date: Thu, 15 Dec 2005 08:09:39 -0500
Message-ID: <20051215130939.GA8111@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmsvT-0005rF-KP
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 05:13:39 -0800
Received: from ra.tuxdriver.com ([24.172.12.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmsvI-0005om-Av
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 05:13:30 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey all-
	This problem was reported to me recently that when a process is attempting
to change ownership (chown) on a file on a NFS share, it is possible that
permissions bits will be reverted to a previous state on the server, even i=
f an
exclusive lock is held on the file.  I verified this, and came to find that=
 this
occurs if the SUID bit is set on the file.  Basically when a file is chown-=
ed,
the chown_call forcibly strips the SUID/SGID bits from the mode (ostensibly=
 for
security purposes).  The VFS then implements this stripping (if the SUID/SG=
ID
bits are currently set on the inode in question) by updating the iattr stru=
cture
in notify_change to not only change the UID/GID of the inode, but also the =
MODE,
using the mode bits in the inode.  This works fine on locally mounted file
systems, in which the inodes in ram are only modified by one system, and ar=
e in
sync with disk contents.  However on NFS, its possible for the a files
attributes to be out of sync with the cached inode on a given system sharin=
g the
NFS mount.  As such, if system A changes the mode bits on a file on the ser=
ver,
system B preforming a chown on an inode cached locally can inadvertantly re=
vert
permissions on the inode to whatever was most recently cached.

I don't think this hole can be 100% closed, as we can guarantee the order of
arival of packets to the server between nodes, but we can be sure that the
filesystem bits aren't reverted if the accessing programs participate in a
locking protocol.  The patch below refreshes the inode and strips the SUID/=
SGID
bits from the latest server side inode->i_mode bits.  This has been tested =
and
prevents the described problem from occuring.

An alternate solution (and one that generates less traffic) may be to simply
disallow the setting of ATTR_MODE and (ATTR_UID|ATTR_GID) at the same time =
in
nfs_setattr, but I haven't thought through what all the implications are th=
ere.

Thanks & Regards
Neil=20

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 inode.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+)


diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -845,6 +845,23 @@ nfs_setattr(struct dentry *dentry, struc
 	if (attr->ia_valid =3D=3D 0)
 		return 0;
=20
+	/*
+	 * If we are changing UID/GID, lets be sure that we
+	 * have the latest mode attribute.  Conducting a chown,
+	 * causes the suid bits to get dropped, and that in turn=20
+	 * can accidentally revert file permissions.
+	 */
+	if ((attr->ia_valid & (ATTR_UID|ATTR_GID)) &&
+	    (attr->ia_valid & ATTR_MODE)) {
+		/*
+		 * We're changing U/GIDS and the MODE.  lets be sure
+		 * we have the most up-to-date mode from the server
+		 * minus the SUID/SGID bits
+		 */
+		__nfs_revalidate_inode(NFS_SERVER(inode),inode);
+		attr->ia_mode =3D inode->i_mode & ~(S_ISUID|S_ISGID);
+	}
+
 	lock_kernel();
 	nfs_begin_data_update(inode);
 	/* Write all dirty data if we're changing file permissions or size */
--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFDoWsTM+bEoZKnT6ERAkxwAJ9VcgTQJgH8kDX6YB90qukNTdl1YgCfVKle
tr+k7TzSkkaVxTnR19whOTQ=
=pgHm
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
