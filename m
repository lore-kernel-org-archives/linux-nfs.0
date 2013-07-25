Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53534 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753636Ab3GYBaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jul 2013 21:30:39 -0400
Date: Thu, 25 Jul 2013 11:30:23 +1000
From: NeilBrown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: Ben Myers <bpm@sgi.com>, Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD/sunrpc: avoid deadlock on TCP connection due to memory
 pressure.
Message-ID: <20130725113023.7bcbc347@notabene.brown>
In-Reply-To: <20130724210746.GB5777@fieldses.org>
References: <20130710092255.0240a36d@notabene.brown>
	<20130710022735.GI8281@fieldses.org>
	<20130710143233.77e35721@notabene.brown>
	<20130710190727.GA22305@fieldses.org>
	<20130715143203.51bc583b@notabene.brown>
	<20130716015803.GA5271@fieldses.org>
	<20130716140021.312b5b07@notabene.brown>
	<20130716142430.GA11977@fieldses.org>
	<20130718000319.GL1681@sgi.com>
	<20130724210746.GB5777@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/S0KIBL5u3.drvlb_dEBXK2g"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/S0KIBL5u3.drvlb_dEBXK2g
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Since we enabled auto-tuning for sunrpc TCP connections we do not
guarantee that there is enough write-space on each connection to
queue a reply.

If memory pressure causes the window to shrink too small, the request
throttling in sunrpc/svc will not accept any requests so no more requests
will be handled.  Even when pressure decreases the window will not
grow again until data is sent on the connection.
This means we get a deadlock:  no requests will be handled until there
is more space, and no space will be allocated until a request is
handled.

This can be simulated by modifying svc_tcp_has_wspace to inflate the
number of byte required and removing the 'svc_sock_setbufsize' calls
in svc_setup_socket.

I found that multiplying by 16 was enough to make the requirement
exceed the default allocation.  With this modification in place:
   mount -o vers=3D3,proto=3Dtcp 127.0.0.1:/home /mnt
would block and eventually time out because the nfs server could not
accept any requests.

This patch relaxes the request throttling to always allow at least one
request through per connection.  It does this by checking both
  sk_stream_min_wspace() and xprt->xpt_reserved
are zero.
The first is zero when the TCP transmit queue is empty.
The second is zero when there are no RPC requests being processed.
When both of these are zero the socket is idle and so one more
request can safely be allowed through.

Applying this patch allows the above mount command to succeed cleanly.
Tracing shows that the allocated write buffer space quickly grows and
after a few requests are handled, the extra tests are no longer needed
to permit further requests to be processed.

The main purpose of request throttling is to handle the case when one
client is slow at collecting replies and the send queue gets full of
replies that the client hasn't acknowledged (at the TCP level) yet.
As we only change behaviour when the send queue is empty this main
purpose is still preserved.

Reported-by: Ben Myers <bpm@sgi.com>
Signed-off-by: NeilBrown <neilb@suse.de>

--
As you can see I've changed the patch.  While writing up the above=20
description realised there was a weakness and so added the sk_stream_min_ws=
pace
test.  That allowed me to write the final paragraph.

NeilBrown


diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 305374d..7762b9f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1193,7 +1193,9 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
 		return 1;
 	required =3D atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg;
-	if (sk_stream_wspace(svsk->sk_sk) >=3D required)
+	if (sk_stream_wspace(svsk->sk_sk) >=3D required ||
+	    (sk_stream_min_wspace(svsk->sk_sk) =3D=3D 0 &&
+	     atomic_read(&xprt->xpt_reserved) =3D=3D 0))
 		return 1;
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
 	return 0;

--Sig_/S0KIBL5u3.drvlb_dEBXK2g
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUfB/sDnsnt1WYoG5AQLxiw//RAzKOhCvDVP2fUq3KEIp41wcVbGPZmeW
81pTfkd09T5kt8oWRFc//Nk6E8YOjkQI71T3YqclKyo5uhVa0yH73ArilkPUdyld
YXrzf3z8Gw+itZdxOEoorOjoTxLRVBIGUSqX2SziInpH/JhftizMECbWFHLo6I6C
OgC6rf6MvZtqyrdSiztr9HfCtOxNCi5XoujLBwB4L9fSxMBKqqD1P7F1sdKq7Alx
zLWXcTlmvZzGhCNlYNWF/PLHEhXHjRW1/YG1mW37wXjdaI41ts4UlXE4N80boh4N
sCFUxvG2R2FDpJJ2ypZN2eeylAWkj6SR8jkTC9RlQ8h/TfeMfOuP7RgNIbM/yCwA
MhG1mvIaV8XeYt5EYunuKx7oBRwflZ64k0lwIBz73Aizi4vKYPmVtDX2VppENf9X
O5yHUy/tkS8sWApLUtdOyGyRkQZyTWBj/a4XwDsGYeD/2W7+a0uYZwF7JMSGGumx
VK0krCKhCczfd+vGBsWmCprd2z7m6rOc8moTiEFcPI5HyRMfRuhyFSLVpYJs1f6N
F0PxT9bCGgdpuhYNjc5cj4jpcdJ17GJciFWerF2Wbn4bgbxhakMrfJm+aJpcJQ8n
LwxgvP9NhS+gCBIRvF5aN+aLHl8umRik6RDyWBvkGouhmvYOAFbZ96DWOLYgHdOz
Asp3aYF9EGs=
=Q6x0
-----END PGP SIGNATURE-----

--Sig_/S0KIBL5u3.drvlb_dEBXK2g--
