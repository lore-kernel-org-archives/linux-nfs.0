Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966334AbbFJQnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:18 -0400
Date: Wed, 10 Jun 2015 17:43:15 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 00/10] NFS: add AF_VSOCK support to NFS client
Message-ID: <20150610164315.GD17294@stefanha-thinkpad.redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
 <20150608210247.GB27887@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HWvPVVuAAfuRc6SZ"
In-Reply-To: <20150608210247.GB27887@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--HWvPVVuAAfuRc6SZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 08, 2015 at 05:02:47PM -0400, J. Bruce Fields wrote:
> On Thu, Jun 04, 2015 at 05:45:43PM +0100, Stefan Hajnoczi wrote:
> > The approach in this series
> > ---------------------------
> > AF_VSOCK stream sockets can be used for NFSv4.1 much in the same way as=
 TCP.
> > RFC 1831 record fragments divide messages since SOCK_STREAM semantics a=
re
> > present.  The backchannel shares the connection just like the default T=
CP
> > configuration.
>=20
> So the NFSv4 backchannel isn't handled for now, I assume.

Right, I did not touch nfs4_callback_up_net(), only
nfs41_callback_up_net().

If I'm reading the code right NFSv4 uses a separate listen port for the
backchannel instead of sharing the client's socket?

This is possible to implement with AF_VSOCK but I have only tested
NFSv4.1 so far.  Should I go ahead and do this?

> And I guess
> NFSv2/v3 is out too thanks to rpcbind?  Which maybe is fine.

Yes, I ignored rpcbind and didn't test NFSv2/v3.

> Do we need an IETF draft or similar to document how NFS should work over
> AF_VSOCK?

I am not familiar with the standards process but I came across a few
places where it makes sense to have a standard:

 * SUNRPC netid for AF_VSOCK (currently "tcp", "udp", and others exist)
 * The uaddr string format ("vsock:...")
 * Use of RFC 1831 record fragments (just like TCP) over AF_VSOCK
   SOCK_STREAM sockets

These are all at the SUNRPC level rather than at the NFS protocol level.

Any idea who I need to talk to?

> NFS developers rely heavily on wireshark (and similar tools) for
> debugging.  Is that still possible over AF_VSOCK?

No, this will require kernel and libpcap patches.  Something like
drivers/net/nlmon.c is needed for AF_VSOCK.  Basically a dummy network
interface and code that clones skbs when monitoring is enabled.

It's on the TODO list and will be very useful.

> > The next step is tackling NFS server.  In the meantime, I have tested t=
he
> > patches using the nc-vsock netcat-like utility that is available in my =
Linux
> > kernel repo below.
>=20
> So by a netcat-like utility, you mean it's proxying between client and a
> server so the client thinks the server is communicating over AF_VSOCK
> and the server thinks the client is using TCP?  (Sorry, I haven't looked
> at the code.)

Yes, exactly.  It works since the TCP and AF_VSOCK streams are almost
bit-compatible.  I think the difference between the streams occurs when
network addresses are transmitted (e.g. SUNRPC netids), but I haven't
encountered that with NFSv4.1 and no pnfs or fancy features in use.

> Once we have a server and client, how will you recommend testing them?
> (Will the server side need to run on real hardware?)

I have been testing nfsd on the host and nfs client in a virtual
machine.  Vice versa should work in the same way.

It's also possible to run nfsd in VM #1 and nfs client in VM #2 and use
the netcat-like utility on the host to forward the traffic.  That way
any kernel panic happens in a VM and doesn't bring down the machine.
I'll probably begin using this approach when I start nfsd work.

> I guess if it works then the main question is whether it's worth
> supporting another transport type in order to get the zero-configuration
> host<->guest NFS setup.  Or whether there's another way to get the same
> gains.

Thanks!  If anyone has suggestions to avoid adding the AF_VSOCK
transport I'd be interested to learn about that.

Stefan

--HWvPVVuAAfuRc6SZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVeGkjAAoJEJykq7OBq3PIy2wH+gJBTKWNl7Nw7qUYG7Vo4wb5
oQxSkOwhaA9UDZ2rwoLuMfmxshDRdlRuYZWvhkRjYXUtKOHyvMZ8GSXGM7cSP40/
gDFAP5kISKM6x2DOAKK47ggt/oe8D6kwaTLCHKceFt9yyeyLsWQ+nLD6bOdy10Rr
07TAEXH+G1HUQLy9GU5V3EIswL27MobaWdDK+s/gjVJap45bP0gRWdeZVeQLAB9u
fsAPzX7j2S/jg6evcWHrqQMciFaS/gjpYvTjNyk1TVspx9GNpF/K4rsKXCGd7aQZ
MqY37vkZsTonPRNtOG5UaKW+iuWQOoHAGWSacfOGZvBBCtJhMp/EvmAU12d+sEY=
=4pp/
-----END PGP SIGNATURE-----

--HWvPVVuAAfuRc6SZ--
