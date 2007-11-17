From: Timo Sirainen <tss@iki.fi>
Subject: Cache flushing
Date: Sat, 17 Nov 2007 02:11:31 +0200
Message-ID: <1195258291.6039.189.camel@hurina>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0913485254=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItBHb-0002BY-Qg
	for nfs@lists.sourceforge.net; Fri, 16 Nov 2007 16:11:35 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItBHg-00012B-CO
	for nfs@lists.sourceforge.net; Fri, 16 Nov 2007 16:11:41 -0800
Received: from [192.168.10.2] (82-203-162-146.dsl.gohome.fi [82.203.162.146])
	by dovecot.org (Postfix) with ESMTP id 312F516473A6
	for <nfs@lists.sourceforge.net>; Sat, 17 Nov 2007 02:11:32 +0200 (EET)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============0913485254==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-eWVCCN8Kq06u3EZggIv2"


--=-eWVCCN8Kq06u3EZggIv2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Solaris and BSDs support flushing attribute cache safely using
fchown(fd, (uid_t)-1, (gid_t)-1). Could Linux be changed to support this
as well? If I'm looking at the sources right, this might work
(completely untested):

--- inode.c.old 2007-11-16 22:18:46.000000000 +0200
+++ inode.c     2007-11-16 22:19:44.000000000 +0200
@@ -322,6 +322,7 @@
 nfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
        struct inode *inode =3D dentry->d_inode;
+       struct nfs_inode *nfsi =3D NFS_I(inode);
        struct nfs_fattr fattr;
        int error;
=20
@@ -334,8 +335,10 @@
=20
        /* Optimization: if the end result is no change, don't RPC */
        attr->ia_valid &=3D NFS_VALID_ATTRS;
-       if (attr->ia_valid =3D=3D 0)
+       if (attr->ia_valid =3D=3D 0) {
+               nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR;
                return 0;
+       }
=20
        lock_kernel();
        nfs_begin_data_update(inode);

Another problem I have is that it's difficult to get a file's data cache
flushed. The only way I found was to successfully fcntl() lock the file.
This is pretty bad from performance point of view since often I don't
want/need to lock the file.

Solaris and BSDs invalidate also a file's data cache when its attribute
cache is invalidated. It would be nicer if there was a separate way, but
I'd settle for fchown(fd, (uid_t)-1, (gid_t)-1) invalidating data cache
as well.

Actually I did also look at posix_fadvise(fd, 0, 0,
POSIX_FADVN_DONTNEED). It appears to work, but I'm a bit worried about
race conditions that causes pages to randomly not get dropped because
invalidate_mapping_pages() doesn't drop locked pages.

--=-eWVCCN8Kq06u3EZggIv2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD4DBQBHPjGzyUhSUUBViskRAq0ZAJ4l2M3sLBkuXJI5L/sk767jL+1AWgCXQc8G
IT00xjQIYHlTXx0h7WARng==
=WG7J
-----END PGP SIGNATURE-----

--=-eWVCCN8Kq06u3EZggIv2--



--===============0913485254==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0913485254==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============0913485254==--
