Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793848827;
	b=ftBzx9yy++2MlHtLTy1SJbcCVkirXsS3Gkd3S5wU5T7/E0yfcz0S4D674lJk+C9UU0s9
	 DXN/iijVttQr6KspjGdyJiWoEOSkwUPNaO+pp56Qm/bIsza7koudAt/UUGaz2JjQoMbnV
	 iuKPiLhX+LsKuZq+AhXBw6IwEGBLt2jZDFa5E92GhqsaxXKTpRxCpenHYHRbsF/1DEGVb
	 rHzkOiAQHJ2kB8nayF5uyBSiyTzaHvENoxX72HQ8fLExl8zkrV/lxUYtOYp3CpyJCfdf3
	 HgoS4ceaJy0F1gw+UcIZHEPIeFq0n0EAMItYdId+16P0haG+h4+wkHp8o0BPvUEkz9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793848827;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:
	 User-Agent:MIME-Version;
	bh=f1k09c1wR/2ZTf34h9QyJ4bsorM7gCNcAVQZ4O8hKBU=;
	b=NTcbkow6K8phrnWcFQ8C5aOlRx6cyEZ2i74+ZqLFjlEcUcTMp9tfgZ74LwvRGE+MgTZx
	 cM7O2loUj40In0cpTMU4as48iO9UT6bcce/EfIeJ85BjeKZANh224Gs/fWqWNEDuv0Lct
	 CZ/cv+mURV/LVH6KEJlsoesadLrjDLzw1ro6PQv/7nZXzWSHOwHphF/mGVAQrcD25bz/v
	 G9AejFS57/0Ea/bjSGqs30M2CnOifVCHFXOvqcqBsEumFQc8J1CIJBRWafUaei7DzvQr/
	 FK25JIJI3Ia8RBrCfLjAxsWZE6jVhYG2IM7jAb70znKO7+G6cLxadDL6Qra4yzSAOwQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LVufgj4a;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37602606A31B;
	Thu,  5 Nov 2026 03:20:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LVufgj4a
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D555C1F000C1;
	Thu,  5 Nov 2026 03:20:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793848826;
	bh=f1k09c1wR/2ZTf34h9QyJ4bsorM7gCNcAVQZ4O8hKBU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=LVufgj4aKr3Qdju5kzCcj9anfQIgtXx4CcZmT9o4Jh6mt4FDHsKgOvFYwCrnmjO5I
	 pJUBVrQknvnIS4q5g8aH6flzN/GQeIlOMOfJyz2N9JSvOrMPIdHVOjjjEw/wzaO2Zs
	 MN+HLUzlCwssmHgeYLQ/glWpTIogak1Muym77DbfcYNNmsDeMQpZap5JCuAxKYDQI0
	 6wAlCnHiWfpflzpi6WGHJ4fjHBTxUqJ64dr89Zc5oQJFhjemQM/6zUMhXTB/XMlBdV
	 LMGQggTsxG/gn98zNiJrIRkidLWfj1UI5ddCp6PzVcc1IdRd9Dq1QKgWge0DLhKDId
	 PjycxIt62Y5qQ==
Message-ID: <b9ed2a8b5f687d7f581d4867a7867c5c012bb2cc.camel@kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: add request-scoped disconnects when
 cancelling tasks
From: Trond Myklebust <trondmy@kernel.org>
To: tmenninger@purestorage.com, anna@kernel.org
Cc: cel@kernel.org, ebadger@everpuredata.com, jcurley@everpuredata.com, 
	jlayton@kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, 	netdev@vger.kernel.org,
 slingappa@everpuredata.com, Tim Menninger	 <tmenninger@everpuredata.com>
Date: Wed, 04 Nov 2026 22:20:24 -0500
In-Reply-To: <681354cdb85b67410793908d9aa4ee37a06408d2.camel@kernel.org>
References: <20261105020249.2607367-1-tmenninger@purestorage.com>
		 <20261105020249.2607367-2-tmenninger@purestorage.com>
	 <681354cdb85b67410793908d9aa4ee37a06408d2.camel@kernel.org>
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

On Wed, 2026-11-04 at 22:14 -0500, Trond Myklebust wrote:
> On Thu, 2026-11-05 at 02:02 +0000, tmenninger@purestorage.com=C2=A0wrote:
> > From: Tim Menninger <tmenninger@everpuredata.com>
> >=20
> > rpc_cancel_tasks() allows callers to cancel a selected set of RPC
> > tasks,
> > but callers that also need to tear down the connection currently
> > have
> > to
> > disconnect at the rpc_clnt level.
> >=20
> > That is broader than necessary for clients with multiple
> > transports.
> > A
> > cancelled request is associated with a specific rpc_xprt and
> > records
> > the
> > connection generation on which it was transmitted in
> > rq_connect_cookie.
> >=20
> > Add rpc_cancel_tasks_and_disconnect() to cancel matching tasks and
> > mark
> > matching requests that remain on the transport transmit or receive
> > queues
> > for conditional transport disconnect when the request is released.
> >=20
> > Store the disconnect indication in struct rpc_rqst rather than
> > struct
> > rpc_task. An RPC task can release one request and later acquire
> > another,
> > so task-scoped state could otherwise be consumed by a successor
> > request
> > and disconnect the wrong transport generation.
> >=20
> > After cancelling matching tasks, walk the client's transports and
> > mark
> > matching requests belonging to that client that remain on the
> > transmit
> > or receive queues. An rpc_xprt may be shared by multiple rpc_clnt
> > instances, so requests belonging to other clients are left
> > untouched.
> >=20
> > When a marked request is released, use
> > xprt_conditional_disconnect()
> > with
> > its saved rq_connect_cookie. This disconnects the transport only if
> > it is
> > still using the same connection generation on which the request was
> > sent,
> > and leaves a replacement connection untouched.
> >=20
> > Requests that were never transmitted do not require a disconnect.
> >=20
>=20
> I'm all for optimising where it makes sense, however this is adding
> another spinlock protected section in xprt_release() for something
> that
> is clearly a rare corner case.
>=20
> So how about something like the following change instead?
>=20
Sorry, I oversimplified. Something like this:

8<------------------------------------------------------
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
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 0dbdf3722537..28f5bacb59f9 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -219,8 +219,8 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
 =09=09struct rpc_timeout *timeout);
 void=09=09rpc_put_task(struct rpc_task *);
 void=09=09rpc_put_task_async(struct rpc_task *);
-bool=09=09rpc_task_set_rpc_status(struct rpc_task *task, int rpc_status);
-void=09=09rpc_task_try_cancel(struct rpc_task *task, int error);
+bool =09=09rpc_task_set_rpc_status(struct rpc_task *task, int rpc_status);
+bool=09=09rpc_task_try_cancel(struct rpc_task *task, int error);
 void=09=09rpc_signal_task(struct rpc_task *);
 void=09=09rpc_exit_task(struct rpc_task *);
 void=09=09rpc_exit(struct rpc_task *, int);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf82..503e95647270 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -930,7 +930,8 @@ unsigned long rpc_cancel_tasks(struct rpc_clnt *clnt, i=
nt error,
 =09=09=09continue;
 =09=09if (!fnmatch(task, data))
 =09=09=09continue;
-=09=09rpc_task_try_cancel(task, error);
+=09=09if (!rpc_task_try_cancel(task, error))
+=09=09=09continue;
 =09=09count++;
 =09}
 =09spin_unlock(&clnt->cl_lock);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 016f16ca5779..97727732400b 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -869,15 +869,16 @@ void rpc_signal_task(struct rpc_task *task)
 =09=09rpc_wake_up_queued_task(queue, task);
 }
=20
-void rpc_task_try_cancel(struct rpc_task *task, int error)
+bool rpc_task_try_cancel(struct rpc_task *task, int error)
 {
 =09struct rpc_wait_queue *queue;
=20
 =09if (!rpc_task_set_rpc_status(task, error))
-=09=09return;
+=09=09return false;
 =09queue =3D READ_ONCE(task->tk_waitqueue);
 =09if (queue)
 =09=09rpc_wake_up_queued_task(queue, task);
+=09return true;
 }
=20
 void rpc_exit(struct rpc_task *task, int status)

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
