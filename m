Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39390 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932778Ab0EVBjJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 May 2010 21:39:09 -0400
From: Ben Hutchings <ben@decadent.org.uk>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steven Shiau <steven@nchc.org.tw>, 579397@bugs.debian.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <4BF71C27.7070309@nchc.org.tw>
References: <4BF71C27.7070309@nchc.org.tw>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-UQKNnaA76giZZ8NpeHqJ"
Date: Sat, 22 May 2010 02:38:48 +0100
Message-ID: <1274492328.11828.3.camel@localhost>
Subject: Re: Bug#579397: STAT_FAIL to debian for SM_MON of 192.168.120.254,
 No canonical hostname found for 192.168.120.254
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-UQKNnaA76giZZ8NpeHqJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-05-22 at 07:49 +0800, Steven Shiau wrote:=20
> Same problem here. However, mine is on the client side.
> On sid system, running kernel is 2.6.32-5-686, nfs-common is 1:1.2.2-1.
> When I mount my NFS server 192.168.120.254, it works. However, if I want=20
> to use some tool which need to lock file to save the file on the NFS=20
> server, e.g.
> vgcfgbackup -f $NFS_MNT_POINT/vg.cfg
> I get the message "lockd: cannot monitor 192.168.120.254", and the=20
> message shown on the /var/log/daemon.log:
> May 21 08:52:44 debian rpc.statd[1298]: STAT_FAIL to debian for SM_MON=20
> of 192.168.120.254
> May 21 08:52:44 debian rpc.statd[1298]: No canonical hostname found for=20
> 192.168.120.254
[...]

nfs-utils 1.2.2 includes the change:

commit 8ce130c4c828b9d13d429f22160f992b9c1d45cd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:15 2010 -0500

    statd: Support IPv6 in sm_mon_1_svc()

This appears to have removed support for IPv4 literals.  Was this
intentional?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-UQKNnaA76giZZ8NpeHqJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS/c1n+e/yOyVhhEJAQLmrhAAqQlbFnagBWRaLl7BU0VQ027Ja3Q1Xnl/
cZkWJuXww2zVGM9V1gxvvtbOOjBjLYxij9PWPdu1/qMUMFg9U+r+6XImE4oFjNsf
2YVy+eujT9WAsai8U/XvpJ0Dq1uAhkIOZDcSIPPFtolgxU8vUWBxgKsALumBO3zS
J/nyvfkbOnRQAAXdk6ZLaOp4t9433qvIupPNAzEAbIh8qPT6T9yVlCm7+S25e/Td
OoPLmOQk86hvMyht/fmz8FBP7SRxCKyi3wr3xfVpYq2T4QfjD2FanqGNpFt+g7kM
0JmVM7D2qumRHyVqNesNS+k3ltVg5rEHgKUogHBuT0ystwMGRF2TGvRLwSk8P25+
lCn6vTjYnU8dKZ3HRKu2zfB7qiAiaxkCq++F58pZJe85jCMhOafs7VgFzWs5PDbd
Ac9aJ0HUZqnQdiIih9cVmfbzH8FKsyGsq1uxja1NmWvzVvre/8kGOGRIcB6dQjBp
ExjEh+SYTGi2bO8+AL3c3j225td1ZMhO4NjdO7eLJxhCQe0xTGc78yr32LNnYbOH
EUjtmFlfkeSbnsV90X6MN1qTM1ZeF2M4tTK8baM6hyM3yFBolbqgm+SNBQOasJlW
1lxzOLOET86fq0QrL9M081EOK/Rh+wmGKo4BpRyOu018a9RHe/JhF0i6OjevNZ2v
+LjVBWC6G/0=
=+Job
-----END PGP SIGNATURE-----

--=-UQKNnaA76giZZ8NpeHqJ--
