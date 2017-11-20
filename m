Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39964 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751506AbdKTQbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Nov 2017 11:31:35 -0500
Date: Mon, 20 Nov 2017 16:31:33 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Bruce Fields <bfields@fieldses.org>
Subject: Re: [PATCH v3 08/14] SUNRPC: add AF_VSOCK support to svc_xprt.c
Message-ID: <20171120163133.GL4516@stefanha-x1.localdomain>
References: <20170630132352.32133-1-stefanha@redhat.com>
 <20170630132352.32133-9-stefanha@redhat.com>
 <1509459038.4553.26.camel@redhat.com>
 <20171107133111.GK6809@stefanha-x1.localdomain>
 <1510063286.4518.34.camel@redhat.com>
 <20171116152502.GG29106@stefanha-x1.localdomain>
 <A8EC5B49-872F-4D60-835C-5D1C2C04E362@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Z1OTrj3C7qypP14j"
In-Reply-To: <A8EC5B49-872F-4D60-835C-5D1C2C04E362@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Z1OTrj3C7qypP14j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 16, 2017 at 03:53:04PM -0500, Chuck Lever wrote:
>=20
> > On Nov 16, 2017, at 10:25 AM, Stefan Hajnoczi <stefanha@redhat.com> wro=
te:
> >=20
> > On Tue, Nov 07, 2017 at 09:01:26AM -0500, Jeff Layton wrote:
> >> On Tue, 2017-11-07 at 13:31 +0000, Stefan Hajnoczi wrote:
> >>> On Tue, Oct 31, 2017 at 10:10:38AM -0400, Jeff Layton wrote:
> >>>> On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> >>>>> @@ -595,6 +609,10 @@ int svc_port_is_privileged(struct sockaddr *si=
n)
> >>>>> 	case AF_INET6:
> >>>>> 		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
> >>>>> 			< PROT_SOCK;
> >>>>> +	case AF_VSOCK:
> >>>>> +		return ((struct sockaddr_vm *)sin)->svm_port <=3D
> >>>>> +			LAST_RESERVED_PORT;
> >>>>> +
> >>>>> 	default:
> >>>>> 		return 0;
> >>>>> 	}
> >>>>=20
> >>>> Does vsock even have the concept of a privileged port? I would imagi=
ne
> >>>> that root in a guest VM would carry no particular significance from =
an
> >>>> export security standpoint
> >>>>=20
> >>>> Since you're defining a new transport here, it might be nice write t=
he
> >>>> RFCs to avoid that distinction, if possible.
> >>>>=20
> >>>> Note that RDMA just has svc_port_is_privileged always return 1.
> >>>=20
> >>> AF_VSOCK has the same 0-1023 privileged port range as TCP.
> >>>=20
> >>=20
> >> But why? And, given that you have 32-bits for a port with AF_VSOCK vs
> >> the 16 bits on an AF_INET/AF_INET6, why is the range so pitifully smal=
l?
> >>=20
> >> Reserved ports are a bit of a dinosaur holdover from when being root on
> >> a machine on the Internet meant something. With v4.1 it's much less of
> >> an issue, but in the "olden days", reserved port exhaustion could be a
> >> real problem.
> >>=20
> >> Mandating low ports can also be a problem in other way. Some well known
> >> services use ports in the ephemeral range, and if your service starts
> >> late and someone else has taken the port for an ephemeral one, you're
> >> out of luck.
> >>=20
> >> I think we have to ask ourselves:
> >>=20
> >> Should the ability to open a low port inside of a VM carry any
> >> significance at all to an RPC server? I'd suggest not, and I think it'd
> >> be good to word the RFC to make that explicitly clear.
> >=20
> > AF_VSOCK has had the reserved port range since it was first merged in
> > 2013.  That's before my time but I do see some use for identifying
> > connections coming from privileged processes.
> >=20
> > Given that TCP has the same privileged port range, is there any reason
> > why AF_VSOCK would be any worse off than TCP for having it?
>=20
> I agree with Jeff that we need to think carefully about this.
>=20
> I don't especially care for the privileged port check, but:
>=20
> In this case, you are inventing an RPC transport that makes
> it impossible to use strong security (ie, RPCSEC_GSS). We
> should be careful about removing the check because only
> AUTH_NULL and AUTH_UNIX security can be used in this kind
> of deployment.
>=20
> Privileged ports are easy to spoof if there is an opportunity
> for a MitM attack to alter the port number of RPCs in transit.
> With VSOCK there may be no such opportunity, thus privileged
> ports might provide an adequate level of security here. I
> make that claim with no deep experience of VSOCK environments.
>=20
> When writing the VSOCK-related RFCs, you will need to provide
> a very clear and concise rationale to the IESG for purposely
> not supporting the use of RPCSEC_GSS. It will start with "well,
> these RPCs do not flow on open networks and are thus not
> subject to MitM attacks"; then proceed to careful discussion of
> how the server will guard against rogue users on guests, and
> assumptions about the trust relationship between the guests
> and the host. You will have to make AUTH_UNIX into a defensible
> deployment choice, and port privilege might be a part of that.
>=20
> Note also that the NFSv4 standards require that implementations
> can support RPCSEC_GSS. NFSv4 on VSOCK cannot. Something will
> have to be done about that.

Thanks!  I will cover it in the draft RFC.

Stefan

--Z1OTrj3C7qypP14j
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaEwNlAAoJEJykq7OBq3PI94AH/0vX96nKQpJ2EUYoQP1VC5Zc
uoAihIlbhJYXxRIDIJ83FGUczrnV7GNnCjIF+D6T3RtjahDx5/akLoPDCdOvr7tM
lHShcT6MurcGvHNO/RiGI03sxDry5933+jvhplYJWrR4ZkpPXE6vt4p1AjXQk8Pw
JYHJxs/Pe7cFRA4i5YKscAiOXmQOZ20VUAXQ6b8mfJ83bnrMT4KMv2BugMzojhsd
Jd9LFTbvSbhMVYbx8HsrLXmlpqQh1QopjcIm9MKhszdfQqoAi8uzSJT2zRiMVpaR
bDsNyEWt1xz1y2QTeuJr3vUNKUnUKoYWWB6Mb+iwkW/tWfpxCxt+IilgHCU9NGA=
=oeEO
-----END PGP SIGNATURE-----

--Z1OTrj3C7qypP14j--
