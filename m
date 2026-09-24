Received: from fhigh-a2-smtp.messagingengine.com (fhigh-a2-smtp.messagingengine.com [103.168.172.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6C613D8122
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 21:46:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790286380; cv=none; b=ZIOh2UoYRMGrAlDv+1rDf0uQisSMTxbI+LIKED0gOlnvOGxKpw2fsOeUPc7Pz/4EzNDjeF66fmRDvtruKjfqsVIVEpOUJfX3m+BrIkNaChjESc4PNDJ26CXvlfEnCJ/vn8XXi4AD2+BeZZnmg1lo+Le6o1p3KYYI9soLSslMUGA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790286380; c=relaxed/simple;
	bh=GnSEL1txoKIYpf5uXnj1XykF0S/76A/DyQwa/BBC5DQ=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=PL+lqcUTJdlp0ZsdeO7bjTlzIrCTkhe57OJODHzQCC/RiSoiHCbyTjzBzosvyOJs58+GNUUiRTcjYxsrt4c87lOD1Q7mGtYAD1pgdghT3f/8qPTqiXQzyDjiPsPe/y21MLqU2rXGcpO/zMvtBPacdYc2U1KZygW7FpVXOlwGSdk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=SVxan1MH; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=JQ4K8t7X; arc=none smtp.client-ip=103.168.172.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="SVxan1MH";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="JQ4K8t7X"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.phl.internal (Postfix) with ESMTP id B96FE140003E;
	Thu, 24 Sep 2026 17:46:17 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Thu, 24 Sep 2026 17:46:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790286377; x=1790372777; bh=93bP10PL/G0euSUP/WE7ZFyNiMOfHzYcrt0
	fES3wKlc=; b=SVxan1MHqTzdZjQCMYhBXw+q/sPeqUC0wqwnl0a41/fa8bSGOrD
	UM9TwoQ4xhGA2T0NMcuCM4iadbFIyFXwMD4NImzeZJixYLCHlKmFORkufmbLQmtQ
	otaNxfqKgA1335NqIYP3h/LeMyt/zTrpMvu1OCBMrdmBeItmyXTlQNTPIs80Qfk3
	cgrU9k21nUo9CXcwYbXsWIpsOPDAeKBq6SJYwz+yEFjuhFF+HG5lnjslCClKO1ka
	mlEBb+YLQlZ6L12RAarDwoZzydN3hIkX49QjZf1VReSFBCT+mI/QmL1s3lPVHNIo
	HfO+fk+rbEarXNpZKLkUPbm3ZIbV62ee4Jw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790286377; x=
	1790372777; bh=93bP10PL/G0euSUP/WE7ZFyNiMOfHzYcrt0fES3wKlc=; b=J
	Q4K8t7Xf9hkVDez81Iku7Sh5DYPcfYVTwLZivFk69C5R1L0+HMmv6jSWBbaZdX7w
	x9FBJB29N7yr3kZJGhgJxdl5iy3IX0FJWn1Mnm35VNmtXmCzWFr2H+gnh2rA0nXa
	V+0v3qBGcrQJ4IL3lx9mQtkVDywAXS803xAPcLupOChxLaO0Qn75sqHAJrihOtTi
	yUrquGEM42Wabt0/FAQwLrvgYS7+vAoLfXWBzE1QTvDmYaytFR8ITMFbt1+eNkPG
	LbtI1pgraM9IQwdEYbWs5mb/PxQapb80Xv04R/ncrOYWjUqWC3c4iSxSFWljj8DU
	mEYUyrgZNb2zaxXvE9KpQ==
X-ME-Sender: <xms:KZq1aqHUSO3SEu-_3EN8rl5QxSXkWzXrnPqHJntLDLIHBSCQvqDFKA>
    <xme:KZq1asCcJqig4ldQwNjSvYlE2lB1-7GxDKHqvGCSfn2wiwdU9Lyw_sGIFeQQcFhIc
    kgOC0eaTQCVFnh9lc3AUTi9JRHgnioxkUsE5wMqUbivL-i_owk>
X-ME-Received: <xmr:KZq1aiUS-pGILu3nI5kBUkhiUDwFeT5bEk27zcjsN_b3qD9BQKOf-hdiivWc-aCWeIQ91q3dr_vrV8skwvJ77RLEGaWnagQ>
X-ME-Proxy-Cause: dmFkZTGkpPvL5PheHZkE2GCXY6aVqtIjkSd3bxGz4pE5ddLCS8x71k3CZemDPaJpgjo5QP
    xou2R82NPRtOqa9U9ug36qChG6G/GJgeRm3xIOVdWH5y7vpHvhDrRZu8cIdAZxx8PnZZx4
    d5OBGkdtdJtx7iwK+BCAmSOTDy52qSdJaWkn8u+SY+zh/lkD3LR2dh9fEOeoasdNctbbj8
    uIIZBPGdVg5PZ4XU4xEujGrAsqLZUF29KhSrvuWQviXwwVjBuFJOjNw6j4HXWZCUU8pthB
    8TUdXvCXhcGWstJje7XYeOIIDsM6Azi6U1RMIJ8BBaBirS6F/lXGLIgVRGDFOZvD407iY4
    iANZw36wfqfIziEeBWUoFIxbGoYj4Egl4h6E1cRI5ejfJVVzSSRdQNcWAarJlZLa0Kk967
    H3WYajAxKWc56GrlwIs+xpSLKKiRvM92sUeFFto0EKoBYI7/6yezeAe+BjiRubXZ9X2uV/
    Na/G3NnYSuim/h6Xe0o1hK/sl/etpwMTyVS0TcI534y+kxhkvKRirf57EARg2YaJ4I/9mK
    JRqQwnV4ZhkEMA0FW7DECge4jAYrDSQ9T9C5uJxki0JduV4z/BXoUeogRE2VSrMjoJapzF
    P0otyGrCifW1zP1TsxYOsn6reoK5CwvpcyDn5M51NvKWkjNl3CTV4pHK5S2A
X-ME-Proxy: <xmx:KZq1aopXMPY783DKyXVfU-RrbTK27Sy9V-eN9VImQhy-W_WiAeh5Dw>
    <xmx:KZq1amSdTRRzR7uMvzZPIgiqRmncv-stM1FVOgn4awlrSS_1X9XpnA>
    <xmx:KZq1aq3WDL87zVdPU7zeRpXhslq6jc82WPobaNGZ0mFMeHHxvaniqw>
    <xmx:KZq1aqCTX2IFv4cOt3nYDm8UvaFrg92s2aBB3vGTV-qpniZPY41-cA>
    <xmx:KZq1ajuX4366JmgjEhvSdS_oOPYdBDjTXUhzdukVrfeuPJUnsunqi-SL>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 24 Sep 2026 17:46:15 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Calum Mackay" <calum.mackay@oracle.com>,
 "Chuck Lever" <chuck.lever@vger.kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Jeff Layton" <jlayton@kernel.org>
Subject: Re: [PATCH pynfs] RPLY14: reconnect before retransmitting the call
In-reply-to: <20260923-rply14-v1-1-f653557909af@kernel.org>
References: <20260923-rply14-v1-1-f653557909af@kernel.org>
Date: Fri, 25 Sep 2026 07:46:10 +1000
Message-id: <179028637100.37859.2606126591365573312@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 24 Sep 2026, Jeff Layton wrote:
> This test recently started failing with a change to the Linux kernel,
> but we believe that the test is wrong. This test replays the same call
> with the same XID over the same socket without reconnecting in between.
>=20
> There is language in RFC1813 that implies that a reconnect is necessary
> on a retransmit on a reliable transport like TCP. Change the test to
> reconnect the socket before retransmitting.

I don't think this is a sufficient fix.

In the test, the client receives the first reply.  This means the server
will have seen a TCP ACK and will have marked the reply a acked, so it
can be cleaned up at any time.

Currently the cleaning of acked replies is minimal.  We need a per-xprt
LRU for that to be effective, and I believe Chuck has plans for that.

Currently the reply is still in cache even though it has been acked.  So
when a new request comes on the same connection, the request is
deliberately dropped because it cannot possibly be useful.  When
a new request comes on a different connection, the cached reply is found
and returned.
But once we have a per-xprt lru, the cached reply will almost certainly
have been cleaned so it won't be found and the request will be repeated.

To properly test the DRC over TCP with the new tcp-ack detection, we
would need to ensure the client doesn't see the first reply, or at least
doesn't send a tcp-ack.  I can only imagine doing this with an iptables
rule which blocks the ack.  This would allow the client to see the
reply, then abort the connection and retry and confirm the same response.

NeilBrown

>=20
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  nfs4.0/lib/rpc/rpc.py           | 25 +++++++++++++++++++++++++
>  nfs4.0/servertests/st_replay.py | 10 ++++++++--
>  2 files changed, 33 insertions(+), 2 deletions(-)
>=20
> diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
> index 7a80241aa127..c530847a46d9 100644
> --- a/nfs4.0/lib/rpc/rpc.py
> +++ b/nfs4.0/lib/rpc/rpc.py
> @@ -315,6 +315,31 @@ class RPCClient(object):
>          out.settimeout(self.timeout)
>          self.lock.release()
>          return out
> +
> +    def reconnect_same_port(self):
> +        """Drop the current connection and reconnect from the same local
> +        port, so the server sees a new transport with an unchanged
> +        (address, port) cache key. Used to test duplicate reply cache
> +        behavior across connections.
> +
> +        The old socket is reset (RST) rather than closed gracefully: a
> +        graceful close leaves the 4-tuple unusable until the server
> +        also closes, while an RST frees the source port immediately.
> +        """
> +        t =3D threading.currentThread()
> +        self.lock.acquire()
> +        old =3D self._socket[t]
> +        saddr =3D old.getsockname()
> +        old.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER,
> +                       struct.pack('ii', 1, 0))
> +        old.close()
> +        out =3D self._socket[t] =3D socket.socket(self.af, socket.SOCK_STR=
EAM)
> +        out.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
> +        out.bind(saddr)
> +        out.connect((self.remotehost, self.remoteport))
> +        out.settimeout(self.timeout)
> +        self.lock.release()
> +        return out
>         =20
>      def send(self, procedure, data=3Db'', program=3DNone, version=3DNone):
>          """Send an RPC call to the server
> diff --git a/nfs4.0/servertests/st_replay.py b/nfs4.0/servertests/st_replay=
.py
> index 48e5363432ec..fc8282151909 100644
> --- a/nfs4.0/servertests/st_replay.py
> +++ b/nfs4.0/servertests/st_replay.py
> @@ -4,7 +4,7 @@ from xdrdef.nfs4_type import *
>  import nfs_ops
>  op =3D nfs_ops.NFS4ops()
> =20
> -def _replay(env, c, ops, error=3DNFS4_OK):
> +def _replay(env, c, ops, error=3DNFS4_OK, newconn=3DFalse):
>      # Can send in an error list, but replays must return same error as orig
>      if type(error) is list:
>          check_funct =3D check
> @@ -18,6 +18,12 @@ def _replay(env, c, ops, error=3DNFS4_OK):
>      try:
>          c.get_new_xid =3D lambda : xid
> =20
> +        if newconn:
> +            # Reconnect from the same source port before replaying:
> +            # servers may drop a retransmit that arrives on the same
> +            # connection as the original call.
> +            c.reconnect_same_port()
> +
>          # note: this is really cheesy: we happen to know the current
>          # Linux server implementation will drop a replay if it comes
>          # "too quickly" (<.02 seconds).
> @@ -260,4 +266,4 @@ def testMkdirReplay(t, env):
>      c =3D env.c1
>      c.init_connection()
>      ops =3D c.go_home() + [op.create(createtype4(NF4DIR), t.word(), {})]
> -    _replay(env, c, ops)
> +    _replay(env, c, ops, newconn=3DTrue)
>=20
> ---
> base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
> change-id: 20260923-rply14-d24b334cd6fa
>=20
> Best regards,
> --=20
> Jeff Layton <jlayton@kernel.org>
>=20
>=20

