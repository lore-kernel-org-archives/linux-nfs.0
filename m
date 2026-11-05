Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793848490;
	b=SArVxdUlmlpGUb0BqO5KTCLkC4x1xslWcfbQfGJACl65pi/ydpjPSZerS8Bq6WFaQfHL
	 bSD3SJE/LQcCLUXl3gCwTdYEqNdxEAMoj/Gpx9H9V6uDQ8Bt1hjmxArsnz+IbIOxFOLy2
	 ul77skfpxwZrU5FiEIp18nUjo4/+AwYOx9Si7mdcSOzAFKhBorchPnYWZTG6612wg+VnV
	 OlN+6KPKyK5Kd5TsOE3DpFR21qWsG5Fb93InsndSFL+ytM/ZLmDd39WBe0WyI8YF3K92b
	 9Rgs7gxZxK9orzqajHm5a0XO7XzjaRdbEDG2OCxneKHSkwJ6XUktmwcAUyI52WOW2dw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793848490;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:
	 User-Agent:MIME-Version;
	bh=e+ufwWTqe/yOyThkZLCwuXirSaPEZ6SPf/o4r9Bdnd0=;
	b=0yljwcw6gMd/EytNlhWC3RtXVQtrc3YHT5xcyqLTI86vupghqFrP86K7XTTIofOyLKsP
	 I9ika3uCOxvamZwU//t68nryc4XOoHzyPJTzv4+vbOoFEMUcIMRuW4bmAMejtrN+lwWKT
	 lQmdp/gzXt8trmjVFp9O5Aih6zYd1w0Zua7t5eoDYfLohp1YXtxgLrdevpfbeM9gHKEaK
	 Uh+ONHeaXbtJA7CvbzpdfQ4e46+Qa5mzHYdAGM1Wud7KSLbeRkmE3HckjlYVsT8WXTxYV
	 7I89+DP0gxth7R55gM6Rj3grwCD0W58LJ+1rR72YCcy5BUV4dC36jwnlCunvPZ5+CjQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M7InAYm7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD149606A332;
	Thu,  5 Nov 2026 03:14:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M7InAYm7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8A7391F00919;
	Thu,  5 Nov 2026 03:14:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793848489;
	bh=e+ufwWTqe/yOyThkZLCwuXirSaPEZ6SPf/o4r9Bdnd0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=M7InAYm77dKIVcWYkI0QwI4a5poNlKZD2yypYJkz0tsN5gwC5SnYQgy/LJqVD8aIN
	 GLSCxtg85siA7dVYl/qNRIGtD33W7voYPdNSEOvBFNT4LCIwWjLYDiL5p9nOodqvkA
	 2/2ci4WaYUb/yOdSDQI3wvp2EWHuHtD/UtAr8KMzx18dzp/GxLZcoHexHDpW4ODP0G
	 uqUQNpXvLLLE/1/tylT2hmErAqzHSuu7PQ0dTaRwcvixj2tVSPIPl9p5I40qZPurzt
	 V6TDYJKDTpi55vIxqkcIjB6MGWztQfryfjy8VD/v1fHAqaUYXMv11kOTTzLuQH8DBU
	 u4+aZ5cFclBtw==
Message-ID: <681354cdb85b67410793908d9aa4ee37a06408d2.camel@kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: add request-scoped disconnects when
 cancelling tasks
From: Trond Myklebust <trondmy@kernel.org>
To: tmenninger@purestorage.com, anna@kernel.org
Cc: cel@kernel.org, ebadger@everpuredata.com, jcurley@everpuredata.com, 
	jlayton@kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, 	netdev@vger.kernel.org,
 slingappa@everpuredata.com, Tim Menninger	 <tmenninger@everpuredata.com>
Date: Wed, 04 Nov 2026 22:14:47 -0500
In-Reply-To: <20261105020249.2607367-2-tmenninger@purestorage.com>
References: <20261105020249.2607367-1-tmenninger@purestorage.com>
	 <20261105020249.2607367-2-tmenninger@purestorage.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.62.1 (3.62.1-1.fc45) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Thu, 2026-11-05 at 02:02 +0000, tmenninger@purestorage.com wrote:
> From: Tim Menninger <tmenninger@everpuredata.com>
>=20
> rpc_cancel_tasks() allows callers to cancel a selected set of RPC
> tasks,
> but callers that also need to tear down the connection currently have
> to
> disconnect at the rpc_clnt level.
>=20
> That is broader than necessary for clients with multiple transports.
> A
> cancelled request is associated with a specific rpc_xprt and records
> the
> connection generation on which it was transmitted in
> rq_connect_cookie.
>=20
> Add rpc_cancel_tasks_and_disconnect() to cancel matching tasks and
> mark
> matching requests that remain on the transport transmit or receive
> queues
> for conditional transport disconnect when the request is released.
>=20
> Store the disconnect indication in struct rpc_rqst rather than struct
> rpc_task. An RPC task can release one request and later acquire
> another,
> so task-scoped state could otherwise be consumed by a successor
> request
> and disconnect the wrong transport generation.
>=20
> After cancelling matching tasks, walk the client's transports and
> mark
> matching requests belonging to that client that remain on the
> transmit
> or receive queues. An rpc_xprt may be shared by multiple rpc_clnt
> instances, so requests belonging to other clients are left untouched.
>=20
> When a marked request is released, use xprt_conditional_disconnect()
> with
> its saved rq_connect_cookie. This disconnects the transport only if
> it is
> still using the same connection generation on which the request was
> sent,
> and leaves a replacement connection untouched.
>=20
> Requests that were never transmitted do not require a disconnect.
>=20

I'm all for optimising where it makes sense, however this is adding
another spinlock protected section in xprt_release() for something that
is clearly a rare corner case.

So how about something like the following change instead?

8<---------------------------------------------------------------
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout=
/flexfilelayout.c
index 7fe8b91fa47c..42b0b04de659 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2459,6 +2459,12 @@ static bool ff_layout_match_io(const struct rpc_task=
 *task, const void *data)
 =09return false;
 }
=20
+static bool ff_layout_match_untransmitted_io(const struct rpc_task *task,
+=09=09=09=09=09     const void *data)
+{
+=09return !RPC_WAS_SENT(task) && ff_layout_match_io(task, data);
+}
+
 static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
 {
 =09struct nfs4_ff_layout_segment *flseg =3D FF_LAYOUT_LSEG(lseg);
@@ -2484,6 +2490,9 @@ static void ff_layout_cancel_io(struct pnfs_layout_se=
gment *lseg)
 =09=09=09clnt =3D ds_clp->cl_rpcclient;
 =09=09=09if (!clnt)
 =09=09=09=09continue;
+=09=09=09rpc_cancel_tasks(clnt, -ECANCELED,
+=09=09=09=09=09 ff_layout_match_untransmitted_io,
+=09=09=09=09=09 lseg);
 =09=09=09if (!rpc_cancel_tasks(clnt, -ECANCELED,
 =09=09=09=09=09      ff_layout_match_io, lseg))
 =09=09=09=09continue;

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
