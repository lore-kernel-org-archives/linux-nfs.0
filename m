Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43991 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbcA2ARx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2016 19:17:53 -0500
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>, Dave Chinner <dchinner@redhat.com>
Date: Fri, 29 Jan 2016 11:17:43 +1100
Cc: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH/RFC] VFS: Improve fairness when locking the per-superblock s_anon list
Message-ID: <87fuxh1bo8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


bit-spin-locks, as used for dcache hash chains, are not fair.
This is not a problem for the dcache hash table as different CPUs are
likely to access different entries in the hash table so high contention
is not expected.
However anonymous dentryies (created by NFSD) all live on a single hash
chain "s_anon" and the bitlock on this can be highly contended, resulting
in soft-lockup warnings.

So introduce a global (fair) spinlock and take it before grabing the
bitlock on s_anon.  This provides fairness and makes the warnings go away.

We could alternately use s_inode_list_lock, or add another spinlock
to struct super_block.  Suggestions?

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Dave: I'd guess you would be against using the new s_inode_list_lock
for this because it is already highly contended - yes?
Is it worth adding another spinlock to 'struct super_block' ?

Thanks,
NeilBrown


 fs/dcache.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 92d5140de851..e83f1ac1540c 100644
=2D-- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -104,6 +104,8 @@ static unsigned int d_hash_shift __read_mostly;
=20
 static struct hlist_bl_head *dentry_hashtable __read_mostly;
=20
+static DEFINE_SPINLOCK(s_anon_lock);
+
 static inline struct hlist_bl_head *d_hash(const struct dentry *parent,
 					unsigned int hash)
 {
@@ -490,10 +492,14 @@ void __d_drop(struct dentry *dentry)
 		else
 			b =3D d_hash(dentry->d_parent, dentry->d_name.hash);
=20
+		if (b =3D=3D &dentry->d_sb->s_anon)
+			spin_lock(&s_anon_lock);
 		hlist_bl_lock(b);
 		__hlist_bl_del(&dentry->d_hash);
 		dentry->d_hash.pprev =3D NULL;
 		hlist_bl_unlock(b);
+		if (b =3D=3D &dentry->d_sb->s_anon)
+			spin_unlock(&s_anon_lock);
 		dentry_rcuwalk_invalidate(dentry);
 	}
 }
@@ -1978,9 +1984,11 @@ static struct dentry *__d_obtain_alias(struct inode =
*inode, int disconnected)
 	spin_lock(&tmp->d_lock);
 	__d_set_inode_and_type(tmp, inode, add_flags);
 	hlist_add_head(&tmp->d_u.d_alias, &inode->i_dentry);
+	spin_lock(&s_anon_lock);
 	hlist_bl_lock(&tmp->d_sb->s_anon);
 	hlist_bl_add_head(&tmp->d_hash, &tmp->d_sb->s_anon);
 	hlist_bl_unlock(&tmp->d_sb->s_anon);
+	spin_unlock(&s_anon_lock);
 	spin_unlock(&tmp->d_lock);
 	spin_unlock(&inode->i_lock);
 	security_d_instantiate(tmp, inode);
=2D-=20
2.7.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWqq+nAAoJEDnsnt1WYoG5ZbQP/izIjB3WxO+OPSZIRu/Q0hui
UbFQGfCwfXPpsdqPa7lMxGWB0gOaPy5pK3/rIY0gdCT0Z8sszbmPleEsTgG07MJA
si0f3NEqpudvO/6e7ywulvBR/M2NGqjDcR6dqc6/e8YihwWf9OXQPn0qZu1lLwm0
eyHd9svWRqPcGF3WCWD5msYLstN5QvtRaGI4zUloUQoNxLDhubnCzgWtcOZbjjI0
fonpiIeHm6T5Dywt0OhJ6tuZQToHlCJ7XjF08HSqWNTLatb4PRmaMlxt5qzfiQzv
lJy4UFQw9ve1YukeAfRYuYJFfTfPNpbbujfpY4yFaSyaDkFNBlFX2ZnfMebBUd0e
ZZmWOCJ4rVmB1lSy8RRe7LNx1Y64dvSVpr6nN/B1QU5IavIdgf6KSJkbSoH0vG2U
KCASWQzhPWNNFCI0UIfzzvMPevxP9KkcPH2VYXt5ccYSCJVpVCfMYQf9rvCmkn6n
o+g9Zh0Iwsq0Nyk2XworQgYpYtC8R23WzhgNq5VgISfyhjCgopk7rR6xqkU1PRo1
OXjHJpEiHSmraS/bnht5HjPoEKKlPLhS0wQId/9UgKAaBYJTbDg/BPAjFViKhU6T
F1Kcyv+xNwHfUA+TWQJFq3CGtgU9adLqdaagCvX5+Zrk3txQ6wcbDlfPLA8V/U3H
dQLIMs+y8STUNhpDltBF
=Dmvx
-----END PGP SIGNATURE-----
--=-=-=--
