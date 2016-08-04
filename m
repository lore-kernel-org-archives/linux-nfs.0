Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49800 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312AbcHDGYl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 02:24:41 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Thu, 04 Aug 2016 16:24:28 +1000
Cc: Linux List <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: disable the use of IPv6 temporary addresses.
Message-ID: <87d1lpnjab.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If the net.ipv6.conf.*.use_temp_addr sysctl is set to '2',
then TCP connections over IPv6 will prefer a 'private' source
address.
These eventually expire and become invalid, typically after a week,
but the time is configurable.

When the local address becomes invalid the client will not be able to
receive replies from the server.  Eventually the connection will timeout
or break and a new connection will be established, but this can take
half an hour (typically TCP connection break time).

RFC 4941, which describes private IPv6 addresses, acknowledges that some
applications might not work well with them and that the application may
explicitly a request non-temporary (i.e. "public") address.

I believe this is correct for SUNRPC clients.  Without this change, a
client will occasionally experience a long delay if private addresses
have been enabled.

The privacy offered by private addresses is of little value for an NFS
server which requires client authentication.

For NFSv3 this will often not be a problem because idle connections are
closed after 5 minutes.  For NFSv4 connections never go idle due to the
period RENEW (or equivalent) request.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/xprtsock.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2a938055e95b..7fc063355c9f 100644
=2D-- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2237,6 +2237,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *=
xprt, struct socket *sock)
 		unsigned int keepcnt =3D xprt->timeout->to_retries + 1;
 		unsigned int opt_on =3D 1;
 		unsigned int timeo;
+		unsigned int addr_pref =3D IPV6_PREFER_SRC_PUBLIC;
=20
 		/* TCP Keepalive options */
 		kernel_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
@@ -2248,6 +2249,16 @@ static int xs_tcp_finish_connecting(struct rpc_xprt =
*xprt, struct socket *sock)
 		kernel_setsockopt(sock, SOL_TCP, TCP_KEEPCNT,
 				(char *)&keepcnt, sizeof(keepcnt));
=20
+		/* Avoid temporary address, they are bad for long-lived
+		 * connections such as NFS mounts.
+		 * RFC4941, section 3.6 suggests that:
+		 *    Individual applications, which have specific
+		 *    knowledge about the normal duration of connections,
+		 *    MAY override this as appropriate.
+		 */
+		kernel_setsockopt(sock, SOL_IPV6, IPV6_ADDR_PREFERENCES,
+				(char *)&addr_pref, sizeof(addr_pref));
+
 		/* TCP user timeout (see RFC5482) */
 		timeo =3D jiffies_to_msecs(xprt->timeout->to_initval) *
 			(xprt->timeout->to_retries + 1);
=2D-=20
2.9.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXot+cAAoJEDnsnt1WYoG5DlcP/3DdloLGv9XIborErFtaXplf
RCD6ajIhYzisaZV4U+55etGRrIqfQt/I1OZZJxQNtKOnhFF+QJoh9dDRVUDvMOT0
JDejM231RCEcmaRrapsOgTrEZHygilKASOdYIPev6QXzWQ8CGWREEQeZiQXzNlhj
S5Ciw41X5l3L/rinAaMd8Crb11KVg3iiF8QwMIEBUS2RJQmT6634wTO+SufJ6r4M
Zt7gNwRvRDPV+fEGpVLUXaV8KxFO5baGjioGs7U1NOO6brFWeMt3UCibjm3Y+RbF
4GPusIW5JKdm9YznbJ5M6svNaApUp7vL3n/GXmIPCX1vFKuU/sBYEFMDYSlN05C0
E9BugYHY3iHrz6M/qUg0XpB8R8amn0pp30PLn+QknAtbwGtV8ieq0t6hogi/Xv9P
p3hZX2CywpCZ9dzUrZ/0+6uP84HjpK55nYdoAKfYcrwbx4w8GCmnGFE1UVaam91X
ybqXccU17/Whnkl1qOPVaPHSCyvlHHqeP1R1BmYZ42vBgQnQaby2VpneKv7cL1iA
WEv3UHlh3lFsqlo6TBh9/8R2iRMZB+lkhs/b5CevZ/xG0xeq82WY1GGr1fMQ99I0
/xPRN54h9PDnn667Qm1lM2EUQviFw/+XWPSiFn/1Isr2Kk5j91SLYS9LvxbLu0Kx
njJcxB6m7bIGIS6vG4y+
=FbWB
-----END PGP SIGNATURE-----
--=-=-=--
