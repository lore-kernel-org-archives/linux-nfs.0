Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755599AbdKNQps (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Nov 2017 11:45:48 -0500
Date: Tue, 14 Nov 2017 16:45:45 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 06/14] SUNRPC: add AF_VSOCK support to xprtsock.c
Message-ID: <20171114164545.GC16154@stefanha-x1.localdomain>
References: <20170630132352.32133-1-stefanha@redhat.com>
 <20170630132352.32133-7-stefanha@redhat.com>
 <1510062374.4518.20.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="LwW0XdcUbUexiWVK"
In-Reply-To: <1510062374.4518.20.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--LwW0XdcUbUexiWVK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 07, 2017 at 08:46:14AM -0500, Jeff Layton wrote:
> On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> > +/**
> > + * xs_vsock_error_report - callback to handle vsock socket state errors
> > + * @sk: socket
> > + *
> > + * Note: we don't call sock_error() since there may be a rpc_task
> > + * using the socket, and so we don't want to clear sk->sk_err.
> > + */
> > +static void xs_vsock_error_report(struct sock *sk)
> > +{
> > +	struct rpc_xprt *xprt;
> > +	int err;
> > +
> > +	read_lock_bh(&sk->sk_callback_lock);
> > +	if (!(xprt =3D xprt_from_sock(sk)))
> > +		goto out;
> > +
> > +	err =3D -sk->sk_err;
> > +	if (err =3D=3D 0)
> > +		goto out;
> > +	/* Is this a reset event? */
> > +	if (sk->sk_state =3D=3D SS_UNCONNECTED)
> > +		xs_sock_mark_closed(xprt);
> > +	dprintk("RPC:       %s client %p, error=3D%d...\n",
> > +			__func__, xprt, -err);
> > +	trace_rpc_socket_error(xprt, sk->sk_socket, err);
> > +	xprt_wake_pending_tasks(xprt, err);
> > + out:
> > +	read_unlock_bh(&sk->sk_callback_lock);
> > +}
>=20
> Hmm ok...so we have this to avoid some TCP specific stuff in
> xs_error_report, I guess?
>=20
> I wonder if AF_LOCAL transport should be using the function above,
> rather than xs_error_report? If so, maybe we should rename:
>=20
>     xs_error_report -> xs_tcp_error_report
>     xs_vsock_error_report -> xs_stream_error_report
>=20
> Might be good to do that cleanup first as a preparatory patch.

AF_LOCAL's use of xs_error_report() is fine because AF_UNIX uses TCP_*
constants for sk->sk_state.

VSOCK has now switched to TCP_* sk_state constants in Dave Miller's
net-next tree.  I made that change for unrelated reasons, but it means
v4 of this patch series will share the xs_error_report() function with
TCP and AF_LOCAL.

> > +
> > +/**
> > + * xs_vsock_finish_connecting - initialize and connect socket
> > + */
> > +static int xs_vsock_finish_connecting(struct rpc_xprt *xprt, struct so=
cket *sock)
> > +{
> > +	struct sock_xprt *transport =3D container_of(xprt, struct sock_xprt, =
xprt);
> > +	int ret =3D -ENOTCONN;
> > +
> > +	if (!transport->inet) {
> > +		struct sock *sk =3D sock->sk;
> > +
> > +		write_lock_bh(&sk->sk_callback_lock);
> > +
> > +		xs_save_old_callbacks(transport, sk);
> > +
> > +		sk->sk_user_data =3D xprt;
> > +		sk->sk_data_ready =3D xs_data_ready;
> > +		sk->sk_state_change =3D xs_vsock_state_change;
> > +		sk->sk_write_space =3D xs_tcp_write_space;
>=20
> Might should rename xs_tcp_write_space to xs_stream_write_space?

Yes, will fix in v4.

> > +		sk->sk_error_report =3D xs_vsock_error_report;
> > +		sk->sk_allocation =3D GFP_ATOMIC;
>=20
> Why GFP_ATOMIC here? The other finish routines use GFP_NOIO.

I missed the memo on commit c2126157ea3c4f72b315749e0c07a1b162a2fe2b
("SUNRPC: Allow sockets to do GFP_NOIO allocations").  It is now okay to
use GFP_NOIO.

Thank you, will fix in v4.

--LwW0XdcUbUexiWVK
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaCx25AAoJEJykq7OBq3PIPvYIAKsAkxbPg0lk7DLVjP3Bw2D9
9RzIQtH+FJO5Yi/cx5cIdvNQGXc7MxDVat3SJY9dx2jc77rU5ZV5mfH6unpxVM3L
FMeuw42m5MvXeGOnBZ0Yeu2AjPtThvGhUiGa7DPxIt+v9NZhInYrcCVGsoVXhl04
3NAISYk+LrD1kc0ZSRjbWtLemIJO/BveUB9oUqdGZ1bpWdnqaOkZoqwp/AE8Zlq/
QEjDfMtGIY1vybrRJHEQs9SxtJbP8b+wqcdO5+4oCSWKE6BvDsH2LKA+azdRfAnQ
VP1VaMXopusG4mKjYASEtP+ecBKgtt+/opvzVSGDemhjSafpj+WuMnZ52I4iaNo=
=hKmJ
-----END PGP SIGNATURE-----

--LwW0XdcUbUexiWVK--
