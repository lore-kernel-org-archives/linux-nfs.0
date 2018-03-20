Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:32954 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750828AbeCTOOh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 10:14:37 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "neilb@suse.com" <neilb@suse.com>,
        "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>
CC: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
Date: Tue, 20 Mar 2018 14:14:25 +0000
Message-ID: <1521555252.13631.10.camel@primarydata.com>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name>
         <878tasc3ag.fsf@notabene.neil.brown.name>
         <584484878.12780264.1521192712528.JavaMail.zimbra@desy.de>
         <1521202233.3008.16.camel@primarydata.com>
         <87o9jja8ny.fsf@notabene.neil.brown.name>
In-Reply-To: <87o9jja8ny.fsf@notabene.neil.brown.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="=-hY5pym3uPSG/k0Vz+XBx"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-hY5pym3uPSG/k0Vz+XBx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2018-03-20 at 11:32 +1100, NeilBrown wrote:
> On Fri, Mar 16 2018, Trond Myklebust wrote:
>=20
> > On Fri, 2018-03-16 at 10:31 +0100, Mkrtchyan, Tigran wrote:
> > > Hi Neil,
> > >=20
> > > according to rfc5661, NFS4ERR_INVAL is returned by the server if
> > > it
> > > thinks that client sends an invalid request (e.g. points to a
> > > client
> > > bug)
> > > or server misinterpret it (broken server).
> > >=20
> > > With your change instead of failing the mount, client will
> > > silently
> > > go for
> > > v4.0, even v4.1 mount was requested and produce undesirable
> > > behavior,
> > > e.g.
> > > proxy-io instead of pnfs. I fill prefer fail-fast instead of long
> > > debug
> > > sessions.
> > >=20
> > > On the other hand, I understand, that it's not always possible to
> > > fix
> > > server
> > > or clients in production environment and time-to-time workarounds
> > > are
> > > necessary.
> > >=20
> > >=20
> >=20
> > I'd tend to agree with Tigran. Hiding server bugs, should not be a
> > priority and particularly not in this case, where the workaround is
> > simple: either turn off version negotiation altogether, or edit
> > /etc/nfsmount.conf to negotiate a different set of versions.
>=20
> Yes, it could be worked-around in nfsmount.conf, but manual
> configuration should be seen as an optimization or a last
> resort.   If
> we can make things work without configuration, that provides the best
> experience.
> In this case, the kernel has strong evidence that the server
> isn't responding as expected, but it gives an unhelpful error
> message.

Server do not spontaneously break their ability to process NFSv4
operations and so this is not an issue that we need to worry about in
ordinary operation. It should only ever be an issue when

1) An insufficiently tested and broken upgrade is applied to an
existing server, in which case the main workaround should be to revert
the upgrade until it can be fixed.
2) A completely new broken server is introduced to the system.

> At the very least, nfs4_discover_server_trunking() should not treat
> -NFS4ERR_INVAL as unexpect (because there is code in
> nfs4_check_cl_exchange_flags which explicitly generates it).
> If it just let this error through, instead of translating it to EIO,
> then the problem would go away.

The code in nfs4_check_cl_exchange_flags is there to check for
explicit NFSv4.1 protocol violations. Is it broken?

> >=20
> > What we might want to do, is make it easier to allow the user to
> > detect
> > that this is indeed a server bug and is not a problem with the
> > arguments supplied to the "mount" utility. Perhaps we might have
> > the
> > kernel log something in the syslogs?
>=20
> Yes, logging a message might be useful.  Most of the messages logged
> about bad servers are currently going through dprintk(), so they
> won't
> often be seen.  Is that what we want??  Don't know...
>=20
> Anyway, you point that it "is not a problem with the arguments" is
> stop-on.  If the client gets EINVAL from the server, then it
> shouldn't
> blindly report that back to the user as EINVAL means "Invalid
> argument" and the argements given to the server are probably not the
> argument given by the user.
>=20
> Following that line of reasoning, I think
> nfs4_check_cl_exchange_flag()
> should *not* return -NFS4ERR_INVAL, and _nfs4_proc_exchange_id()
> shouldn't pass NFS4ERR_INVAL through unchanged.
>=20
> So I propose the following version.
>=20
> Thanks,
> NeilBrown
>=20
> ------------------------8<---------------------------
> From: NeilBrown <neilb@suse.com>
> Date: Tue, 20 Mar 2018 11:31:33 +1100
> Subject: [PATCH] NFSv4: handle EINVAL from EXCHANGE_ID better.
>=20
> nfs4_proc_exchange_id() can return -EINVAL if the server
> reported NFS4INVAL (which I have seen in a packet trace),
> or nfs4_check_cl_exchange_flags() exchange flags detects
> a problem.
> Each of these mean that NFSv4.1 and later cannot be used,
> but they should not prevent fallback to NFSv4.0.  Currently
> they do.
>=20
> Currently this EINVAL error is returned by
> nfs4_proc_exchange_id() to nfs41_discover_server_trunking(),
> and thence to nfs4_discover_server_trunking().
> nfs4_discover_server_trunking() doesn't understand EINVAL,
> so converts it to EIO which causes mount.nfs to think
> something is horribly wrong and to give up.
>=20
> EINVAL is never a sensible error code here.  It means "Invalid
> argument", but is being used when the problem is "Invalid response
> from the server".  If we change these two circumstances to report
> EPROTONOSUPPORT to the caller (which seems a reasonable assessment
> when the server gives confusing responses), and if we enhance
> nfs4_discover_server_trunking() to treat -EPROTONOSUPPORT as an
> expected error to pass through, then the error reported to user-space
> will be more representative of the actual fault.
>=20
> A failure to negotiate a client ID clearly shows that NFSv4.1 cannot
> be supported, but isn't as general a failure as EIO.
>=20
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/nfs4proc.c  | 18 +++++++++++++++---
>  fs/nfs/nfs4state.c |  1 +
>  2 files changed, 16 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 47f3c273245e..97757f646f13 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7364,7 +7364,8 @@ static int nfs4_check_cl_exchange_flags(u32
> flags)
>  		goto out_inval;
>  	return NFS_OK;
>  out_inval:
> -	return -NFS4ERR_INVAL;
> +	dprintk("NFS: server returns invalid flags for
> EXCHANGE_ID\n");
> +	return -EPROTONOSUPPORT;
>  }
> =20
>  static bool
> @@ -7741,8 +7742,19 @@ static int _nfs4_proc_exchange_id(struct
> nfs_client *clp, struct rpc_cred *cred,
>  	int status;
> =20
>  	task =3D nfs4_run_exchange_id(clp, cred, sp4_how, NULL);
> -	if (IS_ERR(task))
> -		return PTR_ERR(task);
> +	if (IS_ERR(task)) {
> +		status =3D PTR_ERR(task);
> +		if (status =3D=3D -NFS4ERR_INVAL) {
> +			/* If the server think we did something
> invalid, it is certainly
> +			 * not the fault of our caller, so it would
> wrong to report
> +			 * this error back up.  So in that case
> simply acknowledge that
> +			 * we don't seem able to support this
> protocol.
> +			 */
> +			dprintk("NFS: server return NFS4ERR_INVAL to
> EXCHANGE_ID\n");
> +			status =3D -EPROTONOSUPPORT;
> +		}
> +		return status;
> +	}
> =20
>  	argp =3D task->tk_msg.rpc_argp;
>  	resp =3D task->tk_msg.rpc_resp;
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 91a4d4eeb235..273c032089c4 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2219,6 +2219,7 @@ int nfs4_discover_server_trunking(struct
> nfs_client *clp,
>  		clnt =3D clp->cl_rpcclient;
>  		goto again;
> =20
> +	case -EPROTONOSUPPORT:
>  	case -NFS4ERR_MINOR_VERS_MISMATCH:
>  		status =3D -EPROTONOSUPPORT;
>  		break;
--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

--=-hY5pym3uPSG/k0Vz+XBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlqxFzUACgkQZwvnipYK
APJ5UBAApWSHcYtN2rqVLLBysC6Rg8YC8m3S+kv1qnRioKsIeq22swd3cXTHf1j0
1zurCfXVgbeq//aui0wPdep+2SdKi5MYRUujY5M0lfLQtJkTd08QEQtZvUxT8vZC
yzm+/8Hd0Q1jWh2HWL4iZsTVy2ZFP+dJcOWpse0TfE+ygbMhZChrgqBwEW5VK+aP
OiC5P/h2wf1i0Sfk3ObyFLDpZvl4dIkuPT19kp8dVNUx77BNfdlOF17hGW9ZF/QI
8UVA6WVo2cv+gwRVaJOVePvL9aUh8M6f0bCVSmzW/RZtdTkjRsODhSYdKXBzv5Ek
K5H6uaRNigQNiizHDJBQmtGDggMlstugRD3UNbBfWSJS3ZCML21+2lHRAc5CMAIr
4Q9SewrdjadfK/rJ9XCrDH7nyOO07AhULvUlnithOG9l+3pgbgEpbFi+jqD2LQtM
J6POnSATF8g+66Y6/I89tfCKIif3de/FHWYJrSRWqZ0MfBzw+2CEWvhTKb4dBcmx
lcEyBXXKl3f8AeuvfjaFtcw2IuZ99UFTIIaTPA5TZ4n9NUYj+ynGgIdcr9k6v7Wk
0VI35vdFN3WTkS3OTYG5EJhzUPBwYi4zMUs9hsLuQZhAYuYSZPzrJD5qtuRMbiOW
lRNIO2wPL+eNTPqHWtp3W0VtPXvbYI6L50Ce5VFKIxqb4ffINuc=
=5a1y
-----END PGP SIGNATURE-----

--=-hY5pym3uPSG/k0Vz+XBx--

