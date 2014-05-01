Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54679 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749AbaEAClw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2014 22:41:52 -0400
Date: Thu, 1 May 2014 12:41:43 +1000
From: NeilBrown <neilb@suse.de>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH] SCHED: allow wait_on_bit_action functions to support a
 timeout.
Message-ID: <20140501124143.5712eb96@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/jYE.mqUWI+CGoBDAmi15Q10"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/jYE.mqUWI+CGoBDAmi15Q10
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


[[ This patch depends on the previously posted:
    [PATCH] SCHED: remove proliferation of wait_on_bit action functions.

   This version is much smaller then the previous and better tested.

   I'm hoping it too will go though the scheduler tree and the the
   NFS changes won't cause too many conflicts...

]]

It is currently not possible for various wait_on_bit functions to
implement a timeout.
While the "action" function that is called to do the waiting could
certainly use schedule_timeout(), there is no way to carry forward the
remaining timeout after a false wake-up.
As false-wakeups a clearly possible at least due to possible
hash collisions in bit_waitqueue(), this is a real problem.

The 'action' function is currently passed a pointer to the word
containing the bit being waited on.  No current action functions use
this pointer.  So changing it to something else will be a little noisy
but will have no immediate effect.

This patch changes the 'action' function to take a pointer to the
"struct wait_bit_key", which contains a pointer to the word
containing the bit so nothing is really lost.

It also adds a 'private' field to "struct wait_bit_key", which is
initialized to zero.

An action function can now implement a timeout with something like

static int timed_out_waiter(struct wait_bit_key *key)
{
	unsigned long waited;
	if (key->private =3D=3D 0) {
		key->private =3D jiffies;
		if (key->private =3D=3D 0)
			key->private -=3D 1;
	}
	waited =3D jiffies - key->private;
	if (waited > 10 * HZ)
		return -EAGAIN;
	schedule_timeout(waited - 10 * HZ);
	return 0;
}

If any other need for context in a waiter were found it would be easy
to use ->private for some other purpose, or even extend "struct
wait_bit_key".

My particular need is to support timeouts in nfs_release_page() to
avoid deadlocks with loopback mounted NFS.

While wait_on_bit_timeout() would be a cleaner interface, it will not
meet my need.  I need the timeout to be sensitive to the state of
the connection with the server, which could change.  So I need to
use an 'action' interface.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cd6e656d839e..5c19408c8345 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -75,7 +75,7 @@ nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
  * nfs_wait_bit_killable - helper for functions that are sleeping on bit l=
ocks
  * @word: long word containing the bit lock
  */
-int nfs_wait_bit_killable(void *word)
+int nfs_wait_bit_killable(struct wait_bit_key *key)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dd8bfc2e2464..9bafea8ecc54 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -342,7 +342,7 @@ extern int nfs_drop_inode(struct inode *);
 extern void nfs_clear_inode(struct inode *);
 extern void nfs_evict_inode(struct inode *);
 void nfs_zap_acl_cache(struct inode *inode);
-extern int nfs_wait_bit_killable(void *word);
+extern int nfs_wait_bit_killable(struct wait_bit_key *key);
=20
 /* super.c */
 extern const struct super_operations nfs_sops;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f369a74f2b31..3f7c25736659 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -112,7 +112,7 @@ __nfs_iocounter_wait(struct nfs_io_counter *c)
 		set_bit(NFS_IO_INPROGRESS, &c->flags);
 		if (atomic_read(&c->io_count) =3D=3D 0)
 			break;
-		ret =3D nfs_wait_bit_killable(&c->flags);
+		ret =3D nfs_wait_bit_killable(&q.key);
 	} while (atomic_read(&c->io_count) !=3D 0);
 	finish_wait(wq, &q.wait);
 	return ret;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 3a847de83fab..592be588ce62 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -236,7 +236,7 @@ void *		rpc_malloc(struct rpc_task *, size_t);
 void		rpc_free(void *);
 int		rpciod_up(void);
 void		rpciod_down(void);
-int		__rpc_wait_for_completion_task(struct rpc_task *task, int (*)(void *)=
);
+int		__rpc_wait_for_completion_task(struct rpc_task *task, int (*)(struct =
wait_bit_key *));
 #ifdef RPC_DEBUG
 struct net;
 void		rpc_show_tasks(struct net *);
diff --git a/include/linux/wait.h b/include/linux/wait.h
index 438dc6044587..162cbcde9dae 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -25,6 +25,7 @@ struct wait_bit_key {
 	void			*flags;
 	int			bit_nr;
 #define WAIT_ATOMIC_T_BIT_NR	-1
+	unsigned long		private;
 };
=20
 struct wait_bit_queue {
@@ -147,12 +148,12 @@ void __wake_up_sync_key(wait_queue_head_t *q, unsigne=
d int mode, int nr, void *k
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_bit(wait_queue_head_t *, void *, int);
-int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(vo=
id *), unsigned);
-int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (=
*)(void *), unsigned);
+int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(st=
ruct wait_bit_key *), unsigned);
+int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (=
*)(struct wait_bit_key *), unsigned);
 void wake_up_bit(void *, int);
 void wake_up_atomic_t(atomic_t *);
-int out_of_line_wait_on_bit(void *, int, int (*)(void *), unsigned);
-int out_of_line_wait_on_bit_lock(void *, int, int (*)(void *), unsigned);
+int out_of_line_wait_on_bit(void *, int, int (*)(struct wait_bit_key *), u=
nsigned);
+int out_of_line_wait_on_bit_lock(void *, int, int (*)(struct wait_bit_key =
*), unsigned);
 int out_of_line_wait_on_atomic_t(atomic_t *, int (*)(atomic_t *), unsigned=
);
 wait_queue_head_t *bit_waitqueue(void *, int);
=20
@@ -855,8 +856,8 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode=
, int sync, void *key);
 	} while (0)
=20
=20
-extern int bit_wait(void *);
-extern int bit_wait_io(void *);
+extern int bit_wait(struct wait_bit_key *);
+extern int bit_wait_io(struct wait_bit_key *);
=20
 /**
  * wait_on_bit - wait for a bit to be cleared
@@ -925,7 +926,7 @@ wait_on_bit_io(void *word, int bit, unsigned mode)
  * on that signal.
  */
 static inline int
-wait_on_bit_action(void *word, int bit, int (*action)(void *), unsigned mo=
de)
+wait_on_bit_action(void *word, int bit, int (*action)(struct wait_bit_key =
*), unsigned mode)
 {
 	if (!test_bit(bit, word))
 		return 0;
@@ -1000,7 +1001,7 @@ wait_on_bit_lock_io(void *word, int bit, unsigned mod=
e)
  * the @mode allows that signal to wake the process.
  */
 static inline int
-wait_on_bit_lock_action(void *word, int bit, int (*action)(void *), unsign=
ed mode)
+wait_on_bit_lock_action(void *word, int bit, int (*action)(struct wait_bit=
_key *), unsigned mode)
 {
 	if (!test_and_set_bit(bit, word))
 		return 0;
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 0c0795002f56..738fa685fd3d 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -319,14 +319,14 @@ EXPORT_SYMBOL(wake_bit_function);
  */
 int __sched
 __wait_on_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
-			int (*action)(void *), unsigned mode)
+			int (*action)(struct wait_bit_key *), unsigned mode)
 {
 	int ret =3D 0;
=20
 	do {
 		prepare_to_wait(wq, &q->wait, mode);
 		if (test_bit(q->key.bit_nr, q->key.flags))
-			ret =3D (*action)(q->key.flags);
+			ret =3D (*action)(&q->key);
 	} while (test_bit(q->key.bit_nr, q->key.flags) && !ret);
 	finish_wait(wq, &q->wait);
 	return ret;
@@ -334,7 +334,7 @@ __wait_on_bit(wait_queue_head_t *wq, struct wait_bit_qu=
eue *q,
 EXPORT_SYMBOL(__wait_on_bit);
=20
 int __sched out_of_line_wait_on_bit(void *word, int bit,
-					int (*action)(void *), unsigned mode)
+					int (*action)(struct wait_bit_key *), unsigned mode)
 {
 	wait_queue_head_t *wq =3D bit_waitqueue(word, bit);
 	DEFINE_WAIT_BIT(wait, word, bit);
@@ -345,7 +345,7 @@ EXPORT_SYMBOL(out_of_line_wait_on_bit);
=20
 int __sched
 __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
-			int (*action)(void *), unsigned mode)
+			int (*action)(struct wait_bit_key *), unsigned mode)
 {
 	do {
 		int ret;
@@ -353,7 +353,7 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_b=
it_queue *q,
 		prepare_to_wait_exclusive(wq, &q->wait, mode);
 		if (!test_bit(q->key.bit_nr, q->key.flags))
 			continue;
-		ret =3D action(q->key.flags);
+		ret =3D action(&q->key);
 		if (!ret)
 			continue;
 		abort_exclusive_wait(wq, &q->wait, mode, &q->key);
@@ -365,7 +365,7 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_b=
it_queue *q,
 EXPORT_SYMBOL(__wait_on_bit_lock);
=20
 int __sched out_of_line_wait_on_bit_lock(void *word, int bit,
-					int (*action)(void *), unsigned mode)
+					int (*action)(struct wait_bit_key *), unsigned mode)
 {
 	wait_queue_head_t *wq =3D bit_waitqueue(word, bit);
 	DEFINE_WAIT_BIT(wait, word, bit);
@@ -503,7 +503,7 @@ void wake_up_atomic_t(atomic_t *p)
 }
 EXPORT_SYMBOL(wake_up_atomic_t);
=20
-__sched int bit_wait(void *word)
+__sched int bit_wait(struct wait_bit_key *word)
 {
 	if (signal_pending_state(current->state, current))
 		return 1;
@@ -512,7 +512,7 @@ __sched int bit_wait(void *word)
 }
 EXPORT_SYMBOL(bit_wait);
=20
-__sched int bit_wait_io(void *word)
+__sched int bit_wait_io(struct wait_bit_key *word)
 {
 	if (signal_pending_state(current->state, current))
 		return 1;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 25578afe1548..7b9a673c6adb 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -250,7 +250,7 @@ void rpc_destroy_wait_queue(struct rpc_wait_queue *queu=
e)
 }
 EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
=20
-static int rpc_wait_bit_killable(void *word)
+static int rpc_wait_bit_killable(struct wait_bit_key *key)
 {
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
@@ -309,7 +309,7 @@ static int rpc_complete_task(struct rpc_task *task)
  * to enforce taking of the wq->lock and hence avoid races with
  * rpc_complete_task().
  */
-int __rpc_wait_for_completion_task(struct rpc_task *task, int (*action)(vo=
id *))
+int __rpc_wait_for_completion_task(struct rpc_task *task, int (*action)(st=
ruct wait_bit_key *))
 {
 	if (action =3D=3D NULL)
 		action =3D rpc_wait_bit_killable;

--Sig_/jYE.mqUWI+CGoBDAmi15Q10
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU2G0Zznsnt1WYoG5AQINtg//Vs9U9/U9oSXs0P+mrJAIai5Lv34AZbMW
Bs7ZvP1H66ZVdn6xh/eonGbso/nGb0NZ2tEwoVQ9vrRfuc+rFrgBPkxvrXpU0U43
x9kx/bXIY6B94y4tKqNDBXWaKMRSvbwpofoq9MH/u58RFoTIx59AClxSAcEpl+gm
aWcr8EGQFs/gKK3/vhVDLpO5G4CvRzQaX3C6mHirylyonixLGbLRQ9aXZXK35/ZD
HA9zuXl10O2GncdmuwKWkumvJd314Yzv1JKUnuRaXz8xw/D/u4cWgeNSheBZEWwT
2EDmKjVnQbZNaiwhSk20YYdEIuNwsmkFQo0139gfZnpR+ovmxsp5nST1ki5qCca2
NU8AlUXVTbTBBNEkOVheE/3ebIwHgcF4r09ag2wpnDIFd/cuyclawIfJy+sTEHZ8
k1GvcwLVjwl4OgN5Wn0AdpE41fEgKuH1elwIZp6QPKknrSgZPLq+AwbOxNSx0gG7
bKqyuVms/QkCIYRRxTm0+Eeg1tERikgPuZxmiP8SSjQNLBpHUirTu1MdYKBewLuG
dQsQ6ObqWrFJPUE8JL1l7WxKMgDx5CbFEwXT+PMqEmqKIo4fd/oQ1jcNHgIYbthj
dNgIGsamtJS2PfCnTibMHJKA7iSopckorHJDEg74DBJOxnJWBzjaX+vv1JPXvea4
MT3LzbQmeLo=
=ViR0
-----END PGP SIGNATURE-----

--Sig_/jYE.mqUWI+CGoBDAmi15Q10--
