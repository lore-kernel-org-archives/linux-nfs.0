Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58324 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199AbaEAJfh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2014 05:35:37 -0400
Date: Thu, 1 May 2014 19:35:27 +1000
From: NeilBrown <neilb@suse.de>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SCHED: allow wait_on_bit_action functions to support a
 timeout.
Message-ID: <20140501193527.72284b3d@notabene.brown>
In-Reply-To: <20140501080430.GL11096@twins.programming.kicks-ass.net>
References: <20140501124143.5712eb96@notabene.brown>
	<20140501080430.GL11096@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/3KL7M.wa+sRW8u2t/.OgMis"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/3KL7M.wa+sRW8u2t/.OgMis
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 1 May 2014 10:04:30 +0200 Peter Zijlstra <peterz@infradead.org> wro=
te:

> On Thu, May 01, 2014 at 12:41:43PM +1000, NeilBrown wrote:
> > diff --git a/include/linux/wait.h b/include/linux/wait.h
> > index 438dc6044587..162cbcde9dae 100644
> > --- a/include/linux/wait.h
> > +++ b/include/linux/wait.h
> > @@ -25,6 +25,7 @@ struct wait_bit_key {
> >  	void			*flags;
> >  	int			bit_nr;
> >  #define WAIT_ATOMIC_T_BIT_NR	-1
> > +	unsigned long		private;
> >  };
> > =20
> >  struct wait_bit_queue {
> > @@ -147,12 +148,12 @@ void __wake_up_sync_key(wait_queue_head_t *q, uns=
igned int mode, int nr, void *k
> >  void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
> >  void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
> >  void __wake_up_bit(wait_queue_head_t *, void *, int);
> > -int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*=
)(void *), unsigned);
> > -int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, i=
nt (*)(void *), unsigned);
> > +int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*=
)(struct wait_bit_key *), unsigned);
> > +int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, i=
nt (*)(struct wait_bit_key *), unsigned);
>=20
>=20
> Would something like:
>=20
> typedef int (*wait_bit_action_f)(struct wait_bit_key *);
>=20
> make sense?

Maybe ... it would be used 12 times.
I usually steer clear of typedefs, but this looks like a reasonably use-cas=
e.

This is what the incremental diff would look like.  I change the typedef a
little because I like pointers to look like they are pointers.

NeilBrown

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 592be588ce62..b8703ac18956 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -236,7 +236,7 @@ void *		rpc_malloc(struct rpc_task *, size_t);
 void		rpc_free(void *);
 int		rpciod_up(void);
 void		rpciod_down(void);
-int		__rpc_wait_for_completion_task(struct rpc_task *task, int (*)(struct =
wait_bit_key *));
+int		__rpc_wait_for_completion_task(struct rpc_task *task, wait_bit_action=
_f *);
 #ifdef RPC_DEBUG
 struct net;
 void		rpc_show_tasks(struct net *);
diff --git a/include/linux/wait.h b/include/linux/wait.h
index 4cee2b2dc26c..39b6aa4cd636 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -142,18 +142,19 @@ __remove_wait_queue(wait_queue_head_t *head, wait_que=
ue_t *old)
 	list_del(&old->task_list);
 }
=20
+typedef int wait_bit_action_f(struct wait_bit_key *);
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
 void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *k=
ey);
 void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, v=
oid *key);
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_bit(wait_queue_head_t *, void *, int);
-int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(st=
ruct wait_bit_key *), unsigned);
-int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (=
*)(struct wait_bit_key *), unsigned);
+int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, wait_bit_a=
ction_f *, unsigned);
+int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, wait_=
bit_action_f *, unsigned);
 void wake_up_bit(void *, int);
 void wake_up_atomic_t(atomic_t *);
-int out_of_line_wait_on_bit(void *, int, int (*)(struct wait_bit_key *), u=
nsigned);
-int out_of_line_wait_on_bit_lock(void *, int, int (*)(struct wait_bit_key =
*), unsigned);
+int out_of_line_wait_on_bit(void *, int, wait_bit_action_f *, unsigned);
+int out_of_line_wait_on_bit_lock(void *, int, wait_bit_action_f *, unsigne=
d);
 int out_of_line_wait_on_atomic_t(atomic_t *, int (*)(atomic_t *), unsigned=
);
 wait_queue_head_t *bit_waitqueue(void *, int);
=20
@@ -926,7 +927,7 @@ wait_on_bit_io(void *word, int bit, unsigned mode)
  * on that signal.
  */
 static inline int
-wait_on_bit_action(void *word, int bit, int (*action)(struct wait_bit_key =
*), unsigned mode)
+wait_on_bit_action(void *word, int bit, wait_bit_action_f *action, unsigne=
d mode)
 {
 	if (!test_bit(bit, word))
 		return 0;
@@ -1001,7 +1002,7 @@ wait_on_bit_lock_io(void *word, int bit, unsigned mod=
e)
  * the @mode allows that signal to wake the process.
  */
 static inline int
-wait_on_bit_lock_action(void *word, int bit, int (*action)(struct wait_bit=
_key *), unsigned mode)
+wait_on_bit_lock_action(void *word, int bit, wait_bit_action_f *action, un=
signed mode)
 {
 	if (!test_and_set_bit(bit, word))
 		return 0;
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 738fa685fd3d..e4f90ba7b4b2 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -319,7 +319,7 @@ EXPORT_SYMBOL(wake_bit_function);
  */
 int __sched
 __wait_on_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
-			int (*action)(struct wait_bit_key *), unsigned mode)
+	      wait_bit_action_f *action, unsigned mode)
 {
 	int ret =3D 0;
=20
@@ -334,7 +334,7 @@ __wait_on_bit(wait_queue_head_t *wq, struct wait_bit_qu=
eue *q,
 EXPORT_SYMBOL(__wait_on_bit);
=20
 int __sched out_of_line_wait_on_bit(void *word, int bit,
-					int (*action)(struct wait_bit_key *), unsigned mode)
+				    wait_bit_action_f *action, unsigned mode)
 {
 	wait_queue_head_t *wq =3D bit_waitqueue(word, bit);
 	DEFINE_WAIT_BIT(wait, word, bit);
@@ -345,7 +345,7 @@ EXPORT_SYMBOL(out_of_line_wait_on_bit);
=20
 int __sched
 __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
-			int (*action)(struct wait_bit_key *), unsigned mode)
+			wait_bit_action_f *action, unsigned mode)
 {
 	do {
 		int ret;
@@ -365,7 +365,7 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_b=
it_queue *q,
 EXPORT_SYMBOL(__wait_on_bit_lock);
=20
 int __sched out_of_line_wait_on_bit_lock(void *word, int bit,
-					int (*action)(struct wait_bit_key *), unsigned mode)
+					 wait_bit_action_f *action, unsigned mode)
 {
 	wait_queue_head_t *wq =3D bit_waitqueue(word, bit);
 	DEFINE_WAIT_BIT(wait, word, bit);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 7b9a673c6adb..9919b94c525a 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -309,7 +309,7 @@ static int rpc_complete_task(struct rpc_task *task)
  * to enforce taking of the wq->lock and hence avoid races with
  * rpc_complete_task().
  */
-int __rpc_wait_for_completion_task(struct rpc_task *task, int (*action)(st=
ruct wait_bit_key *))
+int __rpc_wait_for_completion_task(struct rpc_task *task, wait_bit_action_=
f *action)
 {
 	if (action =3D=3D NULL)
 		action =3D rpc_wait_bit_killable;

--Sig_/3KL7M.wa+sRW8u2t/.OgMis
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU2IVXznsnt1WYoG5AQL7Cg//ZP6cHJdr74NLHGgKd1Ayo+IB+RAjCVCP
rkl5Yg8M9XGWvJfASDQPlN6HG6VFELpgeJ3N1dtjZd51zb9Uz33G6YP+APb6EnT+
cK4H6qnACHirV2kFX13u2siNZLudZ14aM78guOxHub1I8cFlVVkOJBazmUxHxMVN
PM6zcSQEwurrWJQeMObnUpSjjWZ7gajIVS15oAow7S+78PgWeStxb4agzmkNSEor
dpQRvJCIPOaxQdAVdnGE8U86TmMLOARumJ+uli7wYLs9WK0oTimUrDDUTTblf6Qd
dog+6A57dPgIhW/k1mZ2TVp2WUOF/X82NBzS4q4WlRiYLW6lol3GLloPxO/BJCbV
kfGfgBjWzBs9SJTkPSX3qX23Iwva+fVgjNljrmqOI/X9iGHavAPofSXQKbIfv2EM
cQnlZIfuLVRfRC/spq6sRIfInOjuOkvqeElPUQWcAoCOjgocCEljES/jTOn3lQtn
5sC62btBmkX2kqKfdBm/3Jc3X1xgHx3NoSNN5/x63q4PQ4X4O0ra1ckhJ3vP1IeH
hrkuLjaYuHccDSFxGTs5m3Zq/9FIhUqyr3/NkVYLWitlMK4XTrMZp7l7zkK6o10y
zmM77IitDso989WbTHqzu1LzHe62gB396fX7qkgKoBEwiHLsSw7o/6VwV10cn86Q
bhl33KAtWpw=
=9gMC
-----END PGP SIGNATURE-----

--Sig_/3KL7M.wa+sRW8u2t/.OgMis--
