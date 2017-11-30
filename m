Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51187 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750842AbdK3U4t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Nov 2017 15:56:49 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna.Schumaker@Netapp.com
To: Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 01 Dec 2017 07:56:38 +1100
Cc: lkml <linux-kernel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Cc: Lennart Poettering <lennart@poettering.net>
Subject: [PATCH] NFS: allow name_to_handle_at() to work for Amazon EFS.
Message-ID: <87po7zv62h.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Amazon EFS provides an NFSv4.1 filesystem which appears to use
(close to) full length (128 byte) file handles.
This causes the handle reported by name_to_handle_at() to exceed
MAX_HANDLE_SZ, resulting in
  EOVERFLOW if 128 bytes were requested, or
  EINVAL if the size reported by the previous call was requested.

To fix this, increase MAX_HANDLE_SIZE a little, and add a BUILD_BUG
so that this sort of inconsistent error reporting won't happen again.

Link: https://github.com/systemd/systemd/issues/7082#issuecomment-347380436
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Sorry for the scatter-gun To: list.  This is really more of a VFS patch
than an NFS patch and sending patches in either direction has been a bit
hit-and-miss lately, so I'm hoping Andrew will take it unless someone
else objects or beats him to it...

Thanks,
NeilBrown

 fs/nfs/export.c          | 2 ++
 include/linux/exportfs.h | 7 +++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 83fd09fc8f77..23b2fc3ab2bb 100644
=2D-- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -39,6 +39,8 @@ nfs_encode_fh(struct inode *inode, __u32 *p, int *max_len=
, struct inode *parent)
 	size_t fh_size =3D offsetof(struct nfs_fh, data) + server_fh->size;
 	int len =3D EMBED_FH_OFF + XDR_QUADLEN(fh_size);
=20
+	BUILD_BUG_ON_MSG(EMBED_FH_OFF + NFS_MAXFHSIZE > MAX_HANDLE_SZ,
+		"MAX_HANDLE_SZ is too small");
 	dprintk("%s: max fh len %d inode %p parent %p",
 		__func__, *max_len, inode, parent);
=20
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 0d3037419bc7..e7ab1b071c5e 100644
=2D-- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -11,8 +11,11 @@ struct iomap;
 struct super_block;
 struct vfsmount;
=20
=2D/* limit the handle size to NFSv4 handle size now */
=2D#define MAX_HANDLE_SZ 128
+/* Must be larger than NFSv4 file handle, but small
+ * enough for an on-stack allocation. overlayfs doesn't
+ * want this too close to 255.
+ */
+#define MAX_HANDLE_SZ 200
=20
 /*
  * The fileid_type identifies how the file within the filesystem is encode=
d.
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlogcIcACgkQOeye3VZi
gbk4zg//RZ7alzuyHhZDvox25RqW423U10wLXsLvlRt4KHCXN5IbivpGW5oIWG3O
yRTyGwiaT5/0lvZfT35b27Wen+6HAq5WFKn91bbKyBtQlusl5MLVJNGnDQVDHx6x
KEqF9NvdsMGkMLbs5B2Zuw4zvtch3Hd0tSwu9RhTbHTtPksPYvrf+rJaKECzHsf2
L4oQGwLXl/6Gm8/yu8yJj9ijDIucv8kK1y5e8xrvmsbOkFsbdsnTicO4IRHnZ3O5
4NQeVp3fRxGzurljbR77a9btqO3Kyb9v2XbQIxudzC+C02Bfl+deU6tVAz8Yti3j
4hryC/fkVzwLjbObst1JHWmbsz9GRRPMRd7yE7eeiCF0X+i5WyJCld94T0mGqZQ+
Ayn2tvhXWG2/Uy20z1Gdy0FXhTRuO2/QsCjb1bAboeSGb73ahQH+JT/czq+vx9pT
mMyKeSHMO1DBoQAijYKyhoMT5uVYJ80aKAPQtI0CXMdiX2wTCq43NzZvDug6V/8Z
2qogCOxyfGuKwOnwSRTUH1lzhDuauZphmSxbb7EeELu+aUINclPkJlzF/RcjHQCn
qd81yAZP6qfE/Zqe7OpglYfVtKLWpDpD+zL9nKMxYZ+Phqr7tDzOTQXGnzNsJCqg
epZK4OqBIH0c2xT1uSO78Op0w7KJ+zl25BzHEKDaKnWM6PPc2ng=
=IFiD
-----END PGP SIGNATURE-----
--=-=-=--
