Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48322 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754073Ab3CMF7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Mar 2013 01:59:05 -0400
Date: Wed, 13 Mar 2013 16:58:46 +1100
From: NeilBrown <neilb@suse.de>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] sunrpc/cache: remove races with queuing an upcall.
Message-ID: <20130313165846.707392cf@notabene.brown>
In-Reply-To: <61eb00$3g8j4e@dgate20u.abg.fsc.net>
References: <61eb00$3g8j4e@dgate20u.abg.fsc.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/GN75ABruHHLhXrbtF3KIA8G"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/GN75ABruHHLhXrbtF3KIA8G
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 05 Mar 2013 16:07:39 +0100 Bodo Stroesser <bstroesser@ts.fujitsu.com>
wrote:

> Hi,
>=20
> the patch in my previous mail was a bit too optimized,
> in that it gets an cache_request* pointer from each entry
> on the detail->queue, even if it really is a cache_reader.
>=20
> As the resulting pointer is used as a cache_request* after
> checking cache_queue->reader only, this isn't a bug, but
> it is unclean.
>=20
> Thus I changed the patch below once again to keep the sane
> handling as it has been implemented.
>=20
> Bodo
>=20
>=20
> On 04 Mar 2013 07:10:00 +0100 NeilBrown <neilb@suse.de> wrote:
>=20
> > We currently queue an upcall after setting CACHE_PENDING,
> > and dequeue after clearing CACHE_PENDING.
> > So a request should only be present when CACHE_PENDING is set.
> >=20
> > However we don't combine the test and the enqueue/dequeue in
> > a protected region, so it is possible (if unlikely) for a race
> > to result in a request being queued without CACHE_PENDING set,
> > or a request to be absent despite CACHE_PENDING.
> >=20
> > So: include a test for CACHE_PENDING inside the regions of
> > enqueue and dequeue where queue_lock is held, and abort
> > the operation if the value is not as expected.
> >=20
> > Also remove the 'return' from cache_dequeue() to ensure it always
> > removes all entries:  As there is no locking between setting
> > CACHE_PENDING and calling sunrpc_cache_pipe_upcall it is not
> > inconceivable for some other thread to clear CACHE_PENDING and then
> > someone else to set it can call sunrpc_cache_pipe_upcall, both before
> > the original thread completed the call.
> >=20
> > With this, it perfectly safe and correct to:
> >  - call cache_dequeue() if and only if we have just
> >    cleared CACHE_PENDING
> >  - call sunrpc_cache_pipe_upcall() (via cache_make_upcall)
> >    if and only if we have just set CACHE_PENDING.
> >=20
> > Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  net/sunrpc/cache.c |   17 ++++++++++++++---
> >  1 file changed, 14 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> > index 9afa439..0400a92 100644
> > --- a/net/sunrpc/cache.c
> > +++ b/net/sunrpc/cache.c
> > @@ -1022,6 +1022,9 @@ static void cache_dequeue(struct cache_detail *de=
tail, struct cache_head *ch)
> >  			struct cache_request *cr =3D container_of(cq, struct cache_request,=
 q);
> >  			if (cr->item !=3D ch)
> >  				continue;
> > +			if (test_bit(CACHE_PENDING, &ch->flags))
> > +				/* Lost a race and it is pending again */
> > +				break;
> >  			if (cr->readers !=3D 0)
> >  				continue;
> >  			list_del(&cr->q.list);
> > @@ -1029,7 +1032,6 @@ static void cache_dequeue(struct cache_detail *de=
tail, struct cache_head *ch)
> >  			cache_put(cr->item, detail);
> >  			kfree(cr->buf);
> >  			kfree(cr);
> > -			return;
>=20
> Just removing "return" is not enough. If the loop no longer stops
> after dequeueing the first entry found, some other changes are
> necessary also:
>=20
> 1) use list_for_each_entry_safe() instead of list_for_each_entry()
>=20
> 2) don't call spin_unlock() in the loop.
>=20
> Thus, at the end of this mail I added a revised patch. With this
> patch cache_dequeue() no longer frees the requests in the loop,
> but moves them to a temporary queue.
> After the loop it calls spin_unlock() and does the kfree() and
> cache_put() in a second loop.
>=20
> The patch is not tested on a mainline kernel. Instead, I
> ported it to SLES11 SP1 2.6.32.59-0.7.1. On SLES 11 the test
> is still running fine.
>=20
> Best Regards,
> Bodo
>=20
> >  		}
> >  	spin_unlock(&queue_lock);
> >  }
> > @@ -1151,6 +1153,7 @@ int sunrpc_cache_pipe_upcall(struct cache_detail =
*detail, struct cache_head *h,
> >  	struct cache_request *crq;
> >  	char *bp;
> >  	int len;
> > +	int ret =3D 0;
> > =20
> >  	if (!cache_listeners_exist(detail)) {
> >  		warn_no_listener(detail);
> > @@ -1182,10 +1185,18 @@ int sunrpc_cache_pipe_upcall(struct cache_detai=
l *detail, struct cache_head *h,
> >  	crq->len =3D PAGE_SIZE - len;
> >  	crq->readers =3D 0;
> >  	spin_lock(&queue_lock);
> > -	list_add_tail(&crq->q.list, &detail->queue);
> > +	if (test_bit(CACHE_PENDING, &h->flags))
> > +		list_add_tail(&crq->q.list, &detail->queue);
> > +	else
> > +		/* Lost a race, no longer PENDING, so don't enqueue */
> > +		ret =3D -EAGAIN;
> >  	spin_unlock(&queue_lock);
> >  	wake_up(&queue_wait);
> > -	return 0;
> > +	if (ret =3D=3D -EAGAIN) {
> > +		kfree(buf);
> > +		kfree(crq);
> > +	}
> > +	return ret;
> >  }
> >  EXPORT_SYMBOL_GPL(sunrpc_cache_pipe_upcall);
> > =20
> >=20
>=20
>=20
> .....
>=20
> Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Signed-off-by: NeilBrown <neilb@suse.de>
> Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> ---
>=20
> --- a/net/sunrpc/cache.c	2013-02-20 14:05:08.000000000 +0100
> +++ b/net/sunrpc/cache.c	2013-03-05 13:30:13.000000000 +0100
> @@ -1015,23 +1015,33 @@
> =20
>  static void cache_dequeue(struct cache_detail *detail, struct cache_head=
 *ch)
>  {
> -	struct cache_queue *cq;
> +	struct cache_queue *cq, *tmp;
> +	struct cache_request *cr;
> +	struct list_head dequeued;
> +
> +	INIT_LIST_HEAD(&dequeued);
>  	spin_lock(&queue_lock);
> -	list_for_each_entry(cq, &detail->queue, list)
> +	list_for_each_entry_safe(cq, tmp, &detail->queue, list)
>  		if (!cq->reader) {
> -			struct cache_request *cr =3D container_of(cq, struct cache_request, q=
);
> +			cr =3D container_of(cq, struct cache_request, q);
>  			if (cr->item !=3D ch)
>  				continue;
> +			if (test_bit(CACHE_PENDING, &ch->flags))
> +				/* Lost a race and it is pending again */
> +				break;
>  			if (cr->readers !=3D 0)
>  				continue;
> -			list_del(&cr->q.list);
> -			spin_unlock(&queue_lock);
> -			cache_put(cr->item, detail);
> -			kfree(cr->buf);
> -			kfree(cr);
> -			return;
> +			list_move(&cr->q.list, &dequeued);
>  		}
>  	spin_unlock(&queue_lock);
> +
> +	while (!list_empty(&dequeued)) {
> +		cr =3D list_entry(dequeued.next, struct cache_request, q.list);
> +		list_del(&cr->q.list);
> +		cache_put(cr->item, detail);
> +		kfree(cr->buf);
> +		kfree(cr);
> +	}
>  }
> =20
>  /*
> @@ -1151,6 +1161,7 @@
>  	struct cache_request *crq;
>  	char *bp;
>  	int len;
> +	int ret =3D 0;
> =20
>  	if (!cache_listeners_exist(detail)) {
>  		warn_no_listener(detail);
> @@ -1182,10 +1193,18 @@
>  	crq->len =3D PAGE_SIZE - len;
>  	crq->readers =3D 0;
>  	spin_lock(&queue_lock);
> -	list_add_tail(&crq->q.list, &detail->queue);
> +	if (test_bit(CACHE_PENDING, &h->flags))
> +		list_add_tail(&crq->q.list, &detail->queue);
> +	else
> +		/* Lost a race, no longer PENDING, so don't enqueue */
> +		ret =3D -EAGAIN;
>  	spin_unlock(&queue_lock);
>  	wake_up(&queue_wait);
> -	return 0;
> +	if (ret =3D=3D -EAGAIN) {
> +		kfree(buf);
> +		kfree(crq);
> +	}
> +	return ret;
>  }
>  EXPORT_SYMBOL_GPL(sunrpc_cache_pipe_upcall);
> =20


Thanks for this - that was careless of me.  sorry.

Your patch looks good.  I'll forward the two to Bruce again shortly, then
look at submitting a backport for SLES.

Thanks,
NeilBrown


--Sig_/GN75ABruHHLhXrbtF3KIA8G
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUUAVlznsnt1WYoG5AQIHog/9EFbsIbclh8fwmb19aM9whb+Ip4aE6QHx
cYso8MgveaR5olTQqMhzJTfwPNnZkF+3hsDBNAu/V0+kGTV/DE7NHtsXsvynmHqj
C9YSRaAm+r3ZavZhDGlCfAqdspsZBUo/4dO/dQ6kJT7nznm5TDElqj0Tj3V5fTys
8opyr1n6Qp9ueEKLjKTf/O6AzlZEx3miNvW9y4mBzzWTObkslIPh5aOXRL60PMBE
+SnNZnK33udCOct+qpXdUBW36R5gAo7i6WoumVD+SdYoWXB+egYkgqJcb2uwNi3q
anyQqLie3uo5Tr+v0uLrXIfUrfqRjwl6HDiRPkeSibk6IEUOtbk+gJSZ0gia/7dB
NUJgQ6c232Y5Ewjk8Mcbq0dkF4qqjOkMTN0vfb/dtokrM4pOK+GIdD2HADUFJtwO
TpNi3ksaRHhnwIHeckTjNmcBS59j6q1Qr1C8bqwuRd8GBeJ5u6nf5W3IePY5BRmM
DRw67MAt/UC9fcPiQLG8dHGpQSMLKvi14jZlaODLBr0O1wegdCDyVZfswVX4tEwJ
RZLseEl74/GkP6Ltm1V4KhzNy3FO/2mIecfXx3L5aBxIhDJK2wh7L8vm28qJR1v8
jsjmB2cfoLBKuIMsnNuF5wxx2S40XFmaavPC9T10XpAa1ErPw3qeK1cee1djKoH0
D5OhVtZAcXg=
=914J
-----END PGP SIGNATURE-----

--Sig_/GN75ABruHHLhXrbtF3KIA8G--
