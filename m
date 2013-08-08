Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53534 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757555Ab3HHC7t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 22:59:49 -0400
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id E7380A4EB7
	for <linux-nfs@vger.kernel.org>; Thu,  8 Aug 2013 04:59:47 +0200 (CEST)
Date: Thu, 8 Aug 2013 12:59:37 +1000
From: NeilBrown <neilb@suse.de>
To: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH/RFC] remove incorrect "Lock reclaim failed" warning when
 delegation is in force.
Message-ID: <20130808125937.126d8ef1@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/CRbzZH_t+=t=MPe4SlrFZ96"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/CRbzZH_t+=t=MPe4SlrFZ96
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi,
 I'm trying to track down a strange problem with state ids going bad
 (possibly linked to ntp changing the system time on the non-Linux server)
 and am still learning about how the state management works.

 But I've come across an error where I don't think there should be one.

 For whatever reason the client gets a BAD_STATEID on a file that it has a
 lock on.  The open gets a write delegation so that when it runs
 nfs4_reclaim_locks(), nfs4_lock_reclaim aborts early without doing anything
 (it doesn't need to because there is a delegation).
 But the code below then checks that NFS_LOCK_INITIALIZED is set on all lock
 states.  But it isn't because nfs4_clear_open_state cleared it and
 nfs4_lock_reclaim didn't bother setting it.

 So I think the error should only be printed if there is no delegated state,
 hence this patch.

 Does it look right, or have I misunderstood something?

Thanks,
NeilBrown


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1fab140..1876ee7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1444,14 +1444,16 @@ restart:
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

--Sig_/CRbzZH_t+=t=MPe4SlrFZ96
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUgMJmTnsnt1WYoG5AQL2/A/+OhxFVlPPn/X8eM7UHPSJEFs+JKHtARQq
P322lRNtgNv8GWJh/Mnc+qaLa+rwG7rr8+oXks5eLvh7ZjAjl13VHP9nihvcF6jS
+c2ggTb8bAfCatEJdjLGTmG6bCi85cYQMSKd8h3E4R9f/tUhJ+x5PW+zb++va/HP
zzEy2paKH0P1Gv51uM6qKXp0HW3iRsx2Xo6/MfRCx9H0hnTTBF+wcpoaGb24QA6v
ZRpSueWpFbqT+ErRhCLu24e3kM2zhw0OmrdqAJI3FAkZ21DDgBu3vhbDIGYaYd13
tz9945TTYBNHudDxk1CqL1XLFjxnzaMBR34xBXxpEdiz1uUOpKvOogtr6lwlexjs
PWNJZjd908IcTUv8x+OAiKBOkHDAm4NosjKRR/CKg0/hiBf2//6VJg5p+VV190SX
HM4Nu/q8nkL/iO4D8BNQpqtOyNigXAIFhHcM1vn8RjnV2EZEQBTzL7O0tYX5WLNd
OoIhGuVY9cEKJ30ZXBjTVEUVcJZBhQchuvKPYCdpAqXqoNzU6cwWG0kw6X1lrJv7
shEuCcgniLzlWtcSs3ATn0c4ao76KBtNu10o1buc6ctuF1Iw2mhKuq41EIACmjDG
41tc5tSQb+f/av9uix9F1cGQ9+66ciRwy3o7wPgJkT5xnErcKNvYrulLUC1tFZpf
rPIxVk4EZaM=
=zB9k
-----END PGP SIGNATURE-----

--Sig_/CRbzZH_t+=t=MPe4SlrFZ96--
