Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48927 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288Ab3HLGxD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Aug 2013 02:53:03 -0400
Date: Mon, 12 Aug 2013 16:52:47 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: remove incorrect "Lock reclaim failed!" warning.
Message-ID: <20130812165247.74c66315@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/YxCg8/Z2wiIwu1GVB.h7vUW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/YxCg8/Z2wiIwu1GVB.h7vUW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



After reclaiming state that was lost, the NFS client tries to reclaim
any locks, and then checks that each one has NFS_LOCK_INITIALIZED set
(which means that the server has confirmed the lock).
However if the client holds a delegation, nfs_reclaim_locks() simply aborts
(or more accurately it called nfs_lock_reclaim() and that returns without
doing anything).

This is because when a delegation is held, the server doesn't need to
know about locks.

So if a delegation is held, NFS_LOCK_INITIALIZED is not expected, and
its absence is certainly not an error.

So don't print the warnings if NFS_DELGATED_STATE is set.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e22862f..e4e063f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1443,14 +1443,16 @@ restart:
 		if (status >=3D 0) {
 			status =3D nfs4_reclaim_locks(state, ops);
 			if (status >=3D 0) {
-				spin_lock(&state->state_lock);
-				list_for_each_entry(lock, &state->lock_states, ls_locks) {
-					if (!test_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags))
-						pr_warn_ratelimited("NFS: "
-							"%s: Lock reclaim "
-							"failed!\n", __func__);
+				if (test_bit(NFS_DELEGATED_STATE, &state->flags) !=3D 0) {
+					spin_lock(&state->state_lock);
+					list_for_each_entry(lock, &state->lock_states, ls_locks) {
+						if (!test_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags))
+							pr_warn_ratelimited("NFS: "
+									    "%s: Lock reclaim "
+									    "failed!\n", __func__);
+					}
+					spin_unlock(&state->state_lock);
 				}
-				spin_unlock(&state->state_lock);
 				nfs4_put_open_state(state);
 				spin_lock(&sp->so_lock);
 				goto restart;

--Sig_/YxCg8/Z2wiIwu1GVB.h7vUW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUgiGPznsnt1WYoG5AQIXZhAAh6vwnY8JkokyOp56ZEdszI1eiXUYkMDu
kDsebkZyccDfngGoQ7OYvrpufxwWui2SIfeSkaTp/qw2FomX5T7stdVUoejUgYVk
xf2zR8ZuDWzBo7wEPSAAIVIHiT7zrQTceqUnqW5EW2fnhEPeUdiVQCMSkeR8UcwK
xmw870/zp6ywhnKLiyV5s1G0GflE4UC/30wQCPNC4XfWEB12V24Yd8/O0esW14PP
w9eKmxQiVIKuSMCnHOthjed9xbT5n1FF5SlDMVE3IAN9kxShmx54jgYjreSmQxMS
cP5BJcgF1+ya+2BH+iW9mR+keO5Lwi/6V1vZD1g00wxMVgIoLXTgEDC5tJqvjnLh
2KY42W159+ptBFISTWRq8HCWPartqVQedzvmmcb6L9q5qoKVa7w3IEzIVmDlDG2C
dMZMLESGW6IKoNeDd8D5XiCHZdsPgCoeCkBSHVnZHkjIA9CWrVqpowDu8GJEQN7g
pCm2sL/5MJFpo8RuAWmKJptkFvG13oc3wybMR5IMEK2FVD5S6B9F+y29fD8ZQxfB
Ttu3ACW6gkGJpjp/tnv6CgZYkYal0t8tF4ddOsLIggHJdC3vDZMguuObpfzhMi6a
4sok8wY680lg/0rpK68LDuH5fjQoV99nBVjQ/OmNn5gYd7VOhfmm7Vzd51Cfn4j5
93IjvQ/PWBI=
=kMa1
-----END PGP SIGNATURE-----

--Sig_/YxCg8/Z2wiIwu1GVB.h7vUW--
