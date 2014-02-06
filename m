Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34687 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125AbaBFCpw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Feb 2014 21:45:52 -0500
Date: Thu, 6 Feb 2014 13:45:39 +1100
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20140206134539.53d09434@notabene.brown>
In-Reply-To: <20140129071841.1979a48c@tlielax.poochiereds.net>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
	<CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	<1365090480.10726.22.camel@leira.trondhjem.org>
	<20140129182532.7479eeda@notabene.brown>
	<1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
	<20140129071841.1979a48c@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Uf4r/Ysqv=9hzw5QjA.aEUe"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Uf4r/Ysqv=9hzw5QjA.aEUe
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 29 Jan 2014 07:18:41 -0500 Jeff Layton <jlayton@poochiereds.net>
wrote:

> On Wed, 29 Jan 2014 10:21:43 +0100 (CET)
> "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de> wrote:
>=20
> > (without knowing kernel details)
> >=20
> > What about some stat counter and trigger readdirplus instead of next ge=
tattr if
> > some threshold are reached. Let say directory has more than 8000 entrie=
s and=20
> > getattr was called on 10% of the files. Of course you have to watch thi=
s per
> > process.
> >=20
> > Tigran.
> >=20
>=20
> That might be the only possible solution, but as always with these
> sorts of heuristics, it's bound to help some workloads and hurt others.
>=20
> I'm not sure you'd need to watch that per-process. The pagecache data is
> shared after all. The problem though is that you'd need to keep track
> of which (or how many different) entries in the dir have gotten a
> GETATTR since the last READDIRPLUS.
>=20
> IOW, if someone is repeatedly hammering a single entry in a directory
> with stat() calls that need the atime, you probably don't want to force
> a READDIRPLUS on the next readdir() call. If however, they're stat'ing
> each entry in the directory in turn for a "ls -l" type workload then
> you probably do want to dump the cache and just go for a READDIRPLUS.
>=20
> The real way to fix this is probably for someone to pick up and drive
> the xstat()/readdirplus() work. If 'ls -l' used a readdirplus() syscall
> to do its bidding then you'd have a pretty good idea of what you'd need
> to do. That won't help in the short term though...

I agree that improved syscalls are probably the only way to get perfect
solution.  So I tried thinking of an imperfect solution that is still a net
positive.

The customer issue that started me looking at this involved a directory with
1 million files.  I don't know if this is a genuine use case or just making
sure that it all scales nicely, but it is a case where a partial fix could
make a big difference.

"ls -l" first doest a "getdents" with a 32K buffer, then stats all those
files, then does another getdents.
With 2000 file, that is only one getdents call.  With 1,000,000 it would be
hundreds.
It is not possible to know that the first getdents call should force a
readdirplus.  It is quite easy to know that the second and later ones shoul=
d.
This approach will make no difference to the 2000 file case, but will resto=
re
better than 99% of performance in the 1,000,000 file case.

So I'm suggesting the following patch.  I don't really understand the cache
rules fully so it might be more complicated than needed, and it might even =
be
wrong.  But it seems to work on some simple testing.

The change to nfs_update_inode fixes an issue that had me stumped for a
while.  It was still sending lots of GETATTR requests even after it had
switched to READDIRPLUS instead of using cached info.  So that might be a
genuine bug that should be fixed independently of this patch.

The idea is that the first time we find that we look up a file in a directo=
ry
and will need to do a GETATTR, we flush the cached data in the directory so
READDIRPLUS will be used in future.

Comments very welcome.

Thanks,
NeilBrown


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be38b573495a..b237fd7f2e0e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -845,9 +845,12 @@ static int nfs_readdir(struct file *file, struct dir_c=
ontext *ctx)
 	desc->dir_cookie =3D &dir_ctx->dir_cookie;
 	desc->decode =3D NFS_PROTO(inode)->decode_dirent;
 	desc->plus =3D nfs_use_readdirplus(inode, ctx) ? 1 : 0;
+	if (desc->plus && ctx->pos =3D=3D 0)
+		clear_bit(NFS_INO_DID_FLUSH, &NFS_I(inode)->flags);
=20
 	nfs_block_sillyrename(dentry);
-	if (ctx->pos =3D=3D 0 || nfs_attribute_cache_expired(inode))
+	if (ctx->pos =3D=3D 0 || nfs_attribute_cache_expired(inode) ||
+	    (NFS_I(inode)->cache_validity & NFS_INO_INVALID_DATA))
 		res =3D nfs_revalidate_mapping(inode, file->f_mapping);
 	if (res < 0)
 		goto out;
@@ -1080,6 +1083,16 @@ static int nfs_lookup_revalidate(struct dentry *dent=
ry, unsigned int flags)
=20
 	/* Force a full look up iff the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, flags) && nfs_check_verifier(dir, dentr=
y)) {
+		if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS)
+		    && ((NFS_I(inode)->cache_validity &
+			 (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
+			|| nfs_attribute_cache_expired(inode))
+		    && !test_and_set_bit(NFS_INO_DID_FLUSH, &NFS_I(dir)->flags)
+			) {
+			nfs_advise_use_readdirplus(dir);
+			goto out_zap_parent;
+		}
+
 		if (nfs_lookup_verify_inode(inode, flags))
 			goto out_zap_parent;
 		goto out_valid;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 0ae5807480f4..c282ce3e5349 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -218,6 +218,7 @@ struct nfs_inode {
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
+#define NFS_INO_DID_FLUSH	(11)
=20
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {

--Sig_/Uf4r/Ysqv=9hzw5QjA.aEUe
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvL3Uznsnt1WYoG5AQKF/hAAtS3RETh4uxO/5GgDjGv1D6HkM3eyuYI1
I7TTq5VspVNVUcqopCyeMNDGLfFnX7zEHQnVh8vFXzcRvEOTzsNCIbVMst4YXPOc
MuKDjBPDxhoaUv48B7lhnSalZqe0QZEuGKYCs97uLXX1xyeDIgzeT/K3EPpPP5Vx
nUe4g8wASR7aT9IP/fIbX0x2l4fuz5hrqyd2W2udTevYK3Qr5CCWqGNzYPmag+F0
1TSwpJVHrKKaFU5zTjavS5vyDkSOZJi/OxXHTzQlu7yT1h+QDvwx5rwtou5+r7JL
9F6eiC+QnJNudoqYzG27e6wLX4OPs78BAPnTRVFcwBCrYC2igGKVbePA3+GVsojT
46aFGm/8mFsZ4b8ctrJPjz7zbVup0i0T74modow5bGH3/V7m3ELlfdf1Ac/jDd/n
JrdFkz0mRwTiKCKcqg+mlspg0ILyaRipnlS/P+8RDiP4KZ7Z/K3MBfVpNvvJsamS
3Bf+7dBzRXq3HqW8IA5jw6u42cg7am0mqQFj4XJcS8/YYkL+3gsj3Kb/G6QUhTY0
7i0vxO88ZZ/V28I3a18v2UgLeJ9UAUjKUWXCwriqRwsZQo481wdlAPDVeOZYYY8R
wOY4QX0N5n/CnDNU+dvS09kDY/Bv29+e/U595r2Ti1llVvRQuEHLSZf/blj+IoNj
0YRBenmYcqs=
=8/2n
-----END PGP SIGNATURE-----

--Sig_/Uf4r/Ysqv=9hzw5QjA.aEUe--
