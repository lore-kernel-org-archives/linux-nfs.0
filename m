Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42280 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754332AbbLOXoU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Dec 2015 18:44:20 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Wed, 16 Dec 2015 10:44:01 +1100
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] SUNRPC: restore fair scheduling to priority queues.
Message-ID: <87twnjb7lq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Commit: c05eecf63610 ("SUNRPC: Don't allow low priority tasks to pre-empt h=
igher priority ones")

removed the 'fair scheduling' feature from SUNRPC priority queues.
This feature caused problems for some queues (send queue and session slot q=
ueue)
but is still needed for others, particularly the tcp slot queue.

Without fairness, reads (priority 1) can starve background writes
(priority 0) so a streaming read can cause writeback to block
indefinitely.  This is not easy to measure with default settings as
the current slot table size is much larger than the read-ahead size.
However if the slot-table size is reduced (seen when backporting to
older kernels with a limited size) the problem is easily demonstrated.

This patch conditionally restores fair scheduling.  It is now the
default unless rpc_sleep_on_priority() is called directly.  Then the
queue switches to strict priority observance.

As that function is called for both the send queue and the session
slot queue and not for any others, this has exactly the desired
effect.

The "count" field that was removed by the previous patch is restored.
A value for '255' means "strict priority queuing, no fair queuing".
Any other value is a could of owners to be processed before switching
to a different priority level, just like before.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

It is quite possible that you won't like the overloading of
rpc_sleep_on_priority() to disable fair-scheduling and would prefer an
extra arg to rpc_init_priority_wait_queue().  I can do it that way if
you like.
NeilBrown


 include/linux/sunrpc/sched.h |  1 +
 net/sunrpc/sched.c           | 12 +++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index d703f0ef37d8..985efe8d7e26 100644
=2D-- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -184,6 +184,7 @@ struct rpc_wait_queue {
 	pid_t			owner;			/* process id of last task serviced */
 	unsigned char		maxpriority;		/* maximum priority (0 if queue is not a pri=
ority queue) */
 	unsigned char		priority;		/* current priority */
+	unsigned char		count;			/* # task groups remaining to be serviced */
 	unsigned char		nr;			/* # tasks remaining for cookie */
 	unsigned short		qlen;			/* total # tasks waiting in queue */
 	struct rpc_timer	timer_list;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 73ad57a59989..e8fcd4f098bb 100644
=2D-- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -117,6 +117,8 @@ static void rpc_set_waitqueue_priority(struct rpc_wait_=
queue *queue, int priorit
 		rpc_rotate_queue_owner(queue);
 		queue->priority =3D priority;
 	}
+	if (queue->count !=3D 255)
+		queue->count =3D 1 << (priority * 2);
 }
=20
 static void rpc_set_waitqueue_owner(struct rpc_wait_queue *queue, pid_t pi=
d)
@@ -144,8 +146,10 @@ static void __rpc_add_wait_queue_priority(struct rpc_w=
ait_queue *queue,
 	INIT_LIST_HEAD(&task->u.tk_wait.links);
 	if (unlikely(queue_priority > queue->maxpriority))
 		queue_priority =3D queue->maxpriority;
=2D	if (queue_priority > queue->priority)
=2D		rpc_set_waitqueue_priority(queue, queue_priority);
+	if (queue->count =3D=3D 255) {
+		if (queue_priority > queue->priority)
+			rpc_set_waitqueue_priority(queue, queue_priority);
+	}
 	q =3D &queue->tasks[queue_priority];
 	list_for_each_entry(t, q, u.tk_wait.list) {
 		if (t->tk_owner =3D=3D task->tk_owner) {
@@ -401,6 +405,7 @@ void rpc_sleep_on_priority(struct rpc_wait_queue *q, st=
ruct rpc_task *task,
 	 * Protect the queue operations.
 	 */
 	spin_lock_bh(&q->lock);
+	q->count =3D 255;
 	__rpc_sleep_on_priority(q, task, action, priority - RPC_PRIORITY_LOW);
 	spin_unlock_bh(&q->lock);
 }
@@ -478,7 +483,8 @@ static struct rpc_task *__rpc_find_next_queued_priority=
(struct rpc_wait_queue *q
 		/*
 		 * Check if we need to switch queues.
 		 */
=2D		goto new_owner;
+		if (queue->count =3D=3D 255 || --queue->count)
+			goto new_owner;
 	}
=20
 	/*
=2D-=20
2.6.3


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWcKXBAAoJEDnsnt1WYoG5X+EP+wd9w5r/QNsqcDrGRilwoPDm
PVWibwq1OhH3+kcHl32Mef5mNZ4sSYepX3tAEv3kNJwjyCMohTxMITgik88Wd8nF
do/r5boVns+2RgNGpz907ahdS3OFkv/cvBH+zzHgbH71TDycs6RFijfAjLTzSsq7
sdbBIbYAxngKTV4EYFCZTROy5W+jn9/wCDQHH1wYThqVv+K9qR2hJsBfT6y/d/FS
VUlSg8qjGzorjFIgPIoIa7LYNJkzknHy1hGacFAEy6Ne7FvNLID2jvTxT6r8PqE1
aFz1+G7rTiJR84gx2MV3K3rJV7tsDTry4HOMtJL43iIc7Ct/nI/bdRAoTwpL/PaB
7eE+OTEe1rxm2TtRZqSi1L+smXLhwF53brnF4ogj9WL1ImgrkOTbbT/zvBj4VDZT
fbtsNNZOQpmy/0cAdlDIWqc3qXk1BKnQq2lzJ8qrb+XOqvEESTnBzS2B4WUnLeKX
K4ZxSaPjJkfpi+hi4EIP9esC+Lz+fsn0P7LgLHgzRyXVTtmFcTQClNNfzv1UyKyq
ALB1GXGTAEPZ796BzN/xl+HbX/Hv7U65PJIh2GXjJ3IIPrmS8CuaIfjKTJSPpxK2
yVxhmTGbG3pWRj2X+Cz3mZC2BgQq6ZLxI5KB3sNtpeSDv52VpF0v3KGYxCVu5kMr
EwAWhgVu5wm7uzz8EHB8
=H/tj
-----END PGP SIGNATURE-----
--=-=-=--
