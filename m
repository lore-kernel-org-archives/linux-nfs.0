Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57214 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbaCMBXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2014 21:23:21 -0400
Date: Thu, 13 Mar 2014 12:23:11 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Dickson Steve <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Lever Charles Edward <chuck.lever@oracle.com>,
        Carsten Ziepke <kieltux@gmail.com>
Subject: Re: [PATCH - v2] mount.nfs: Fix fallback from tcp to udp
Message-ID: <20140313122311.1d6cb500@notabene.brown>
In-Reply-To: <0AC6E29F-B377-4EE0-9599-26A72A8F85DA@primarydata.com>
References: <20140224142349.784345f9@notabene.brown>
	<531E2E3F.2020805@RedHat.com>
	<20140311090124.05409b1b@notabene.brown>
	<531F2334.2030203@RedHat.com>
	<20140312163803.0e911784@notabene.brown>
	<BAE0F586-4E03-43EB-AC7F-81123D757BDE@primarydata.com>
	<53203D97.6090005@RedHat.com>
	<0AC6E29F-B377-4EE0-9599-26A72A8F85DA@primarydata.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Fz_dlXD3bwokpOvlq70lGUA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Fz_dlXD3bwokpOvlq70lGUA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


> >> I would expect the timeouts to have changed due to the NFSv4 trunking =
detection (which is=20
> >> exactly why it is wrong to rely on the kernel timeouts here anyway), b=
ut I would not expect=20
> >> the kernel to never time out at all.
> > It appears it started with 3.13 kernels... The above stack is from a 3.=
14-ish client.=20
> >=20
>=20
> Which patch caused the behaviour to change?

561ec1603171cd9b38dcf6cac53e8710f437a48d is the first bad commit
commit 561ec1603171cd9b38dcf6cac53e8710f437a48d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Sep 26 15:22:45 2013 -0400

    SUNRPC: call_connect_status should recheck bind and connect status on e=
rror
   =20
    Currently, we go directly to call_transmit which sends us to call_status
    on error. If we know that the connect attempt failed, we should rather
    just jump straight back to call_bind and call_connect.
   =20
    Ditto for EAGAIN, except do not delay.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


If I revert that commit from mainline (which may be a completely bogus thing
to do) then mainline works (at least for this specific simple test).
(The revert required some wiggling - I'll include it below).

To be precise, the test is to try to mount
  mount server:/path /mnt
from a server which has run
   rpc.nfsd -T -N4

"success" is getting periodic messages:

mount.nfs: trying text-based options 'retry=3D1,vers=3D4,addr=3D10.0.10.2,c=
lientaddr=3D10.0.10.1'
mount.nfs: mount(2): Connection refused


"failure" is not getting those messages.


There is another change though.
For the commit above I don't not get "Connection refused", but after 2
minutes I get=20

mount.nfs: mount(2): Connection timed out

With mainline, it waits forever.
I did a second git bisect for this change and found

2118071d3b0d57a03fad77885f4fdc364798aa87 is the first bad commit
commit 2118071d3b0d57a03fad77885f4fdc364798aa87
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Tue Dec 31 13:22:59 2013 -0500

    SUNRPC: Report connection error values to rpc_tasks on the pending queue
   =20
    Currently we only report EAGAIN, which is not descriptive enough for
    softconn tasks.
   =20
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>


=46rom this commit, a mount attempt which is getting connections denied will
block indefinitely.

Hope that is helpful.

NeilBrown



This is the revert that I mentioned - just for completeness.


=46rom 9c1462ff54fcc2adc79c825b867c32c19e30a9a7 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Thu, 13 Mar 2014 11:38:54 +1100
Subject: [PATCH] Revert "SUNRPC: call_connect_status should recheck bind and
 connect status on error"

This reverts commit 561ec1603171cd9b38dcf6cac53e8710f437a48d.

Conflicts:
	net/sunrpc/clnt.c

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0edada973434..ba0cd114f0e1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1796,7 +1796,6 @@ call_connect_status(struct rpc_task *task)
 	dprint_status(task);
=20
 	trace_rpc_connect_status(task, status);
-	task->tk_status =3D 0;
 	switch (status) {
 		/* if soft mounted, test if we've timed out */
 	case -ETIMEDOUT:
@@ -1805,16 +1804,14 @@ call_connect_status(struct rpc_task *task)
 	case -ECONNREFUSED:
 	case -ECONNRESET:
 	case -ECONNABORTED:
-	case -ENETUNREACH:
 	case -EHOSTUNREACH:
-		/* retry with existing socket, after a delay */
-		rpc_delay(task, 3*HZ);
+	case -ENETUNREACH:
 		if (RPC_IS_SOFTCONN(task))
 			break;
-	case -EAGAIN:
-		task->tk_action =3D call_bind;
-		return;
+		/* retry with existing socket, after a delay */
 	case 0:
+	case -EAGAIN:
+		task->tk_status =3D 0;
 		clnt->cl_stats->netreconn++;
 		task->tk_action =3D call_transmit;
 		return;

--Sig_/Fz_dlXD3bwokpOvlq70lGUA
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUyEIfznsnt1WYoG5AQJfPg/+P+Ko1GkedKRniX9EC24M9hPYibuS0NMr
FrZPHemE4qkZYmn/F+g6bgMWVsO/rOuU6fs7VSD4K4hkqdMDU9WN4IL43BtNfInC
wtLCTERE8Hct7iicNn1UGu29cWyw0ISdgiQXKjWOzn0Y+KQkn6QcAJZcRo+oj6OZ
+yKpKrnQfzlAmqzZzuy1ElW5E1uGE4Kc/nU8mGAcJHNUFcxtNlUxcOlWPOr76du5
fKB9R73FLmFWjFFx496p9TIgBGQcTYQ8SF38ycMXVv/NWY7bttBK02YV2x5+iUw8
yZNK88fKzO+kp9hxQNapNujcovGgfF7aD7dngadcK6TlCqcsn2stDx0absFcc82F
i7jKDX5PoFcKogfH1fKztQPOJByq7kbRwepMSEYxyfmEYzhENuiD9CJhOACGBlnT
B731WWg1B9XKP7RMUrXFNFcd3KF3HzKBnmWOmo8h+6u/AVUhJVzZAkF3QfIYhO8W
BUwcPipHQiTS+RVZJP0jNCxnT6nrgnkUHQKJRwBnvp1qdapswIbB1VN3lFkyjVo0
EzxxnwYFHgOrsZ+fa7G+MRHgZuSwDohliQNWI2WNW0oDQHSseuIDa02SNtJtQqJ0
6z4YFMVGzHsyAfmhRZGkMpy6Lfk8j/RUnVsIdZaLgQIHPQXVGQdkLuMU91u2513x
od/YJcXRBes=
=P6C0
-----END PGP SIGNATURE-----

--Sig_/Fz_dlXD3bwokpOvlq70lGUA--
