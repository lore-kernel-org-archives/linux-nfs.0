Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51406 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751967AbdGSPLs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 11:11:48 -0400
Date: Wed, 19 Jul 2017 16:11:46 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
Message-ID: <20170719151146.GE5628@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-6-stefanha@redhat.com>
 <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Ns7jmDPpOpCD+GE/"
In-Reply-To: <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Ns7jmDPpOpCD+GE/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 30, 2017 at 11:52:15AM -0400, Chuck Lever wrote:
> > On Jun 30, 2017, at 9:21 AM, Stefan Hajnoczi <stefanha@redhat.com> wrot=
e:
> >=20
> > Neither libtirpc nor getprotobyname(3) know about AF_VSOCK.
>=20
> Why?
>=20
> Basically you are building a lot of specialized
> awareness in applications and leaving the
> network layer alone. That seems backwards to me.

Yes.  I posted glibc patches but there were concerns that getaddrinfo(3)
is IPv4/IPv6 only and applications need to be ported to AF_VSOCK anyway,
so there's not much to gain by adding it:
https://cygwin.com/ml/libc-alpha/2016-10/msg00126.html

> > For similar
> > reasons as for "rdma"/"rmda6", translate "vsock" manually in getport.c.
>=20
> rdma/rdma6 are specified by standards, and appear
> in the IANA Network Identifiers database:
>=20
> https://www.iana.org/assignments/rpc-netids/rpc-netids.xhtml
>=20
> Is there a standard netid for vsock? If not,
> there needs to be some discussion with the nfsv4
> Working Group to get this worked out.
>
> Because AF_VSOCK is an address family and the RPC
> framing is the same as TCP, the netid should be
> something like "tcpv" and not "vsock". I've
> complained about this before and there has been
> no response of any kind.
>=20
> I'll note that rdma/rdma6 do not use alternate
> address families: an IP address is specified and
> mapped to a GUID by the underlying transport.
> We purposely did not expose GUIDs to NFS, which
> is based on AF_INET/AF_INET6.
>=20
> rdma co-exists with IP. vsock doesn't have this
> fallback.

Thanks for explaining the tcp + rdma relationship, that makes sense.

There is no standard netid for vsock yet.

Sorry I didn't ask about "tcpv" when you originally proposed it, I lost
track of that discussion.  You said:

  If this really is just TCP on a new address family, then "tcpv"
  is more in line with previous work, and you can get away with
  just an IANA action for a new netid, since RPC-over-TCP is
  already specified.

Does "just TCP" mean a "connection-oriented, stream-oriented transport
using RFC 1831 Record Marking"?  Or does "TCP" have any other
attributes?

NFS over AF_VSOCK definitely is "connection-oriented, stream-oriented
transport using RFC 1831 Record Marking".  I'm just not sure whether
there are any other assumptions beyond this that AF_VSOCK might not meet
because it isn't IP and has 32-bit port numbers.

> It might be a better approach to use well-known
> (say, link-local or loopback) addresses and let
> the underlying network layer figure it out.
>=20
> Then hide all this stuff with DNS and let the
> client mount the server by hostname and use
> normal sockaddr's and "proto=3Dtcp". Then you don't
> need _any_ application layer changes.
>=20
> Without hostnames, how does a client pick a
> Kerberos service principal for the server?

I'm not sure Kerberos would be used with AF_VSOCK.  The hypervisor knows
about the VMs, addresses cannot be spoofed, and VMs can only communicate
with the hypervisor.  This leads to a simple trust relationship.

> Does rpcbind implement "vsock" netids?

I have not modified rpcbind.  My understanding is that rpcbind isn't
required for NFSv4.  Since this is a new transport there is no plan for
it to run old protocol versions.

> Does the NFSv4.0 client advertise "vsock" in
> SETCLIENTID, and provide a "vsock" callback
> service?

The kernel patches implement backchannel support although I haven't
exercised it.

> > It is now possible to mount a file system from the host (hypervisor)
> > over AF_VSOCK like this:
> >=20
> >  (guest)$ mount.nfs 2:/export /mnt -v -o clientaddr=3D3,proto=3Dvsock
> >=20
> > The VM's cid address is 3 and the hypervisor is 2.
>=20
> The mount command is supposed to supply "clientaddr"
> automatically. This mount option is exposed only for
> debugging purposes or very special cases (like
> disabling NFSv4 callback operations).
>=20
> I mean the whole point of this exercise is to get
> rid of network configuration, but here you're
> adding the need to additionally specify both the
> proto option and the clientaddr option to get this
> to work. Seems like that isn't zero-configuration
> at all.

Thanks for pointing this out.  Will fix in v2, there should be no need
to manually specify the client address, this is a remnant from early
development.

> Wouldn't it be nicer if it worked like this:
>=20
> (guest)$ cat /etc/hosts
> 129.0.0.2  localhyper
> (guest)$ mount.nfs localhyper:/export /mnt
>=20
> And the result was a working NFS mount of the
> local hypervisor, using whatever NFS version the
> two both support, with no changes needed to the
> NFS implementation or the understanding of the
> system administrator?

This is an interesting idea, thanks!  It would be neat to have AF_INET
access over the loopback interface on both guest and host.

--Ns7jmDPpOpCD+GE/
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZb3ayAAoJEJykq7OBq3PIRggH/jvYnvVoG4/NEkojuD9O288B
o+lg2ZPiK5l15Al4C97hp4TwPfpDH7LAKM+2bWcHIOGoFLmUtd7sUvxn3yg7kjJc
xjVvH+tgk4VHpV1Nrz7X+QFGTUm6yYFFMD1CId/Np0EYlPo2Ap0f+jpAfx6dw/AE
0myCKBcH5LqW0GpiXC11DtaDt9hV514NtG9qK78M5ZBBWHQ/jqFyE5XbnLkLuYpH
4tO1sEsOOkvCK56k9T79e2uMKT8l5K5rkyoLoko6gn1XD8VFm06tagPZbk8y6hA9
fY9P0/WToaom/mSrzopVmOwfixrjfMCqZOFyL+7N3+WbmQQrkidWyu3HcPc1H24=
=/yl4
-----END PGP SIGNATURE-----

--Ns7jmDPpOpCD+GE/--
