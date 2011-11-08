Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53066 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816Ab1KHAN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Nov 2011 19:13:56 -0500
Date: Tue, 8 Nov 2011 11:13:44 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: wake up SOFTCONN tasks when a connection error
 happens.
Message-ID: <20111108111344.140d7dcf@notabene.brown>
In-Reply-To: <1320695343.7987.7.camel@lade.trondhjem.org>
References: <20111107150654.1c045aad@notabene.brown>
	<1320695343.7987.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/kjjiFqtv7yB0rWsk0Hz1D.A"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/kjjiFqtv7yB0rWsk0Hz1D.A
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 07 Nov 2011 14:49:03 -0500 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> On Sun, 2011-11-06 at 20:06 -0800, NeilBrown wrote:=20
> > hi all,
> >  It being over a year since I last raised this I thought it might be ti=
me to
> >  try again.
> >=20
> >  The problem is that an NFSv4 mount request (the default) to an unroute=
able
> >  server results in a 3 minute timeout instead of an instant failure.
> >=20
> >  This is easy to test by simply removing your default route then trying=
 to
> >  mount something outside your local network.
> >=20
> >  This patch causes any SOFTCONN task to be woken up as soon as a connec=
tion
> >  error occurs so that it can fail promptly.  The failure reasons gets p=
assed
> >  back and as it is not ETIMEDOUT it causes immediate failure.
> >=20
> >  Is this a reasonable approach?
> >=20
> > Thanks,
> > NeilBrown
> >=20
> >=20
> >=20
> >=20
> > From a1aea8fc3977ffa9951c3d7f27dbb1905e5f560f Mon Sep 17 00:00:00 2001
> > From: NeilBrown <neilb@suse.de>
> > Date: Mon, 7 Nov 2011 15:00:17 +1100
> > Subject: [PATCH] sunrpc: wake up SOFTCONN tasks when a connection error
> >  happens.
> >=20
> > A 'SOFTCONN' task should fail if there is an error or a major timeout
> > during connection.
> >=20
> > However errors are currently converted into a timeout (60seconds for
> > TCP) which is treated as a minor timeout and 3 of these are required
> > before failure.
> >=20
> > The result of this is that if you try to mount an NFSv4 filesystem
> > (which doesn't require rpcbind and the failure modes that provides)
> > from a server which you do not have a route to (an so get
> > NETUNREACHABLE), you have an unnecessary 3 minutes timeout.
> >=20
> > So when ENETUNREACH is reported for a connection - or other errors
> > which are fatal, wake up any SOFTCONN tasks with that error - rather
> > than letting them wait 60 seconds and then generate ETIMEDOUT.
> >=20
> > This causes the above mentioned mount attempt to fail instantly.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  include/linux/sunrpc/sched.h |    1 +
> >  net/sunrpc/sched.c           |   29 +++++++++++++++++++++++++++++
> >  net/sunrpc/xprtsock.c        |    6 +++++-
> >  3 files changed, 35 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
> > index e775689..b85451b 100644
> > --- a/include/linux/sunrpc/sched.h
> > +++ b/include/linux/sunrpc/sched.h
> > @@ -236,6 +236,7 @@ void		rpc_wake_up_queued_task(struct rpc_wait_queue=
 *,
> >  void		rpc_wake_up(struct rpc_wait_queue *);
> >  struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
> >  void		rpc_wake_up_status(struct rpc_wait_queue *, int);
> > +void		rpc_wake_up_softconn_status(struct rpc_wait_queue *, int);
> >  int		rpc_queue_empty(struct rpc_wait_queue *);
> >  void		rpc_delay(struct rpc_task *, unsigned long);
> >  void *		rpc_malloc(struct rpc_task *, size_t);
> > diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> > index d12ffa5..d92000a 100644
> > --- a/net/sunrpc/sched.c
> > +++ b/net/sunrpc/sched.c
> > @@ -543,6 +543,35 @@ void rpc_wake_up_status(struct rpc_wait_queue *que=
ue, int status)
> >  }
> >  EXPORT_SYMBOL_GPL(rpc_wake_up_status);
> > =20
> > +/**
> > + * rpc_wake_up_softconn_status - wake up all SOFTCONN rpc_tasks and se=
t their
> > + * status value.
> > + * @queue: rpc_wait_queue on which the tasks are sleeping
> > + * @status: status value to set
> > + *
> > + * Grabs queue->lock
> > + */
> > +void rpc_wake_up_softconn_status(struct rpc_wait_queue *queue, int sta=
tus)
> > +{
> > +	struct rpc_task *task, *next;
> > +	struct list_head *head;
> > +
> > +	spin_lock_bh(&queue->lock);
> > +	head =3D &queue->tasks[queue->maxpriority];
> > +	for (;;) {
> > +		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
> > +			if (RPC_IS_SOFTCONN(task)) {
> > +				task->tk_status =3D status;
> > +				rpc_wake_up_task_queue_locked(queue, task);
> > +			}
>=20
> This is basically rpc_wake_up_status() with an extra conditional test
> (which again is just rpc_wake_up() with an extra status argument).
> Should we consider merging these functions?

I wondered a bit about this, but felt it safest to leave  the code structur=
ed
as it was.
You could possibly combine them all into one function with:

 if ((task->tk_flags & flags) =3D=3D flags) {
    if (status < 0)
        task->tk_status =3D status;
    rpc_wake_up.....
 }
in the heart of the loop.   Though that would only be right if
rpc_wake_up_status was never called with a zero status (or positive).


>=20
> > +		if (head =3D=3D &queue->tasks[0])
> > +			break;
> > +		head--;
> > +	}
> > +	spin_unlock_bh(&queue->lock);
> > +}
> > +EXPORT_SYMBOL_GPL(rpc_wake_up_softconn_status);
>=20
> Why do we want to export this?
>

We probably don't.  It is just a copy/paste artefact.

If you agree with the approach, and suggest how you would like to handle the
proliferation of rpc_wake_up_* I can respin that patch as a formal submissi=
on.

Thanks,
NeilBrown




--Sig_/kjjiFqtv7yB0rWsk0Hz1D.A
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTrh0ODnsnt1WYoG5AQIf/xAAsQGtBp1isjDPGouIUGF64C+SkflSa6Yj
a9l4NgTFgdCSCj2iHHe9F/jtIAaQkoctTzgVuBGZaUgG11nYlupA9q8T9PT+oNHf
E0mXDg4WF/4FmPtIVcaa/EHbpdwKydojn2VAkOJPJM7E9Lo6nk9mOhwPbtqdAxbe
BCCWq9yJqkjcCgDWgheOB9N9eIN0LtctaiK1CuEpynNg+AdwG0mGoVVWIRibWThx
axKhpJNJvTEHJvCA31e9SzW3i6jmA9aonoM56HEQelq9zGK/xSAIfvn72rR1mDL+
NKFKArnMgZ5e5HUdVdDOVSpPoFqudhxqQiqRNWo3y60PjikyCGucILx1uJTzAs/T
1azkS5ym8HgQ+Id0fu8JpEv3qaQJde4V3eB9ZlYYDczBz4rrzGoLF5AGhIh3UnLR
FLddrd+xpOiutqlWFWGTnVL//axKKWbAO3OymZHN4XhgHo0yCqOp+oUctV84bXWV
1eoyAjQ52seZOpQw4XWYuBnZdodBraXxFMnB8cpNEQmlb7tG1YbWpP6PIjeCD0eg
7WfFHxg1mReW67NdcX3oipmh+wqZmjIIvbZE0aNG4EN+/vWkbLONUSDs76SbMFsu
1bR90yCeXYs0TmxUcVnS40Mtb/r/Geh40cTN8+jZDH73fiAqrgJlAFL66zmvKoMt
tJRtZwVgbh0=
=tmg6
-----END PGP SIGNATURE-----

--Sig_/kjjiFqtv7yB0rWsk0Hz1D.A--
