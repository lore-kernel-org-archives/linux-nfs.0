Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55092 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909AbcDMXd3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2016 19:33:29 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 8AF35ABB2
	for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2016 23:33:26 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 14 Apr 2016 09:33:22 +1000
Subject: AUTH_NONE at top of SECINFO_NONAME reply.
Message-ID: <87k2k1jd8d.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Hi,
 I have an NFSv4.1 server (Netapp, don't know about version numbers)
 which responds to
    PUT_ROOTFH
    SECINFO_NONAME

with:

flavor: AUTH_NULL (0)
flavor: RPCSEC_GSS (6)
    service: rpcsec_gss_svc_integrity (2)
flavor: RPCSEC_GSS (6)
    service: rpcsec_gss_svc_none (1)
flavor: AUTH_UNIX (1)

This causes the Linux client to use AUTH_NULL, which doesn't end well
   Opcode: ACCESS (3), [Access Denied: RD LU MD XT DL]

I suspect this is a server bug, because the first flavor is meant to be
the most preferred.  However I wonder if there might be something else
going on.

1/ I note that for NFSv3 AUTH_NULL means something a bit different
  in this context:

	 * AUTH_NULL has a special meaning when it's in the server list - it
	 * means that the server will ignore the rpc creds, so any flavor
	 * can be used.

  Is there any chance that servers might reasonably expect that
  behavior for NFSv4.1 as well??

2/ In the pseudo-root filesystem it might make sense to use AUTH_NULL,
  providing something else is used when crossing in to another
  filesystem.
  Should the client send a new SECINFO when that happens (it may not
  help in this case, I don't know) or is that really only needed when
  NFS4ERR_WRONGSEC is returned?
  It seems a bit asymmetric that SECINFO is use pro-actively at the start
  of a session, but then only re-actively after that.

Any thoughts?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXDtdCAAoJEDnsnt1WYoG5H6gQAJqLbEgxppcKmlwyRUQyB+H0
dqKUHc3QTrRGW11wl3VjTwcxjJA2ODnjG80ZK2l0Ttw9mXFRyY/3JdGLWXfX0FNo
TrMQeQD9ppVTOB9q3/0wp8+mX381BuaM5KejGs/Tp6zAeRFueofPVk15u0xDB5kv
yymhu4K/8EJrMGJe9+nNskU2U4jpgwzbgR8sDGfhCYgoE4LVvMU7pk5kSSWOav9N
UPcyQ+L0xbAyn62rlG4JpI0pImBP8Hm1itT21VXbEOj0Ofry4/adR/P0n+dnj4Bx
MNeqlWNIfsLOU/KUPW/JNPCUe5lSWXfjCMPCN+fv6lP5iIZ0+8ZvGa8P2GNem5Qg
fsUOEUT1jhDeA/Ixu5XYwTECGgxPo2ARp8MrRljyjjOynIy8dZdKihgI1mHgt28q
D3m8JwjXJmzGVjZC9V6nzoMt66H/4j0aJfnU/gxKiZAtb/QeSq9YR5vhEmspd2hB
yAl8u5H/IPFAGLf2P59CNSQC5/fbw6Pw7wBcvop33w45aFzTFnrp5ZnKDL1/+H+L
oZm3P2aJ98NwT3KHGo10l+VELp1IK3QZ5Bs2voDX3cD+x9pt1BiL6fqP/zRPYj7H
ZGZIwnGlfkEJO4mezfO1GFMOPqUdFGcZE4OvYFmGl8YUPQQz/CsTriNXYc7+j6jT
N1+P+q9EcIxMTG2A4IV4
=rfAj
-----END PGP SIGNATURE-----
--=-=-=--
