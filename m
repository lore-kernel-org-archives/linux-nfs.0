Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793888133;
	b=wFFXviMPB4GAcbZlvUEOzJCb86q4ZNBB+hBcPZTgGFpX+0cm8p/ygyz3UGPpFnLQYzFZ
	 0PFT4JTCDLozd9MOZ4U9G1ThDtCqC1FSrjV375k5S5t3YKSn5lxJ7kv25WcubdxtRe8id
	 H+OI9HbdBATJXDu2K6q5c0aSQRDAIHfpRNWpkVgKVqyLtskhlDKjtcCtZkQqNG4AsZXod
	 RLlGY8NtrHg1cozd0Ilz6Rq7uylhmWE2BC0+wZ0V2JQNfUzdknZrX1Q+dJjkcEihI9bsM
	 aspYmG0/oEbtOlXhEvMbuLchrBPtRM1qZAfzWvRw3ffBee6ciJVfKnYpUezIUKAcBWg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793888133;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=dWl9qIyyT5GTbz8Zh9XS4FgbJfrczPtjtTFP/gieClM=;
	b=mxhkz8G5PD+a95CBxFFTTZ5Cro7yVvbw837y1U9PY30kA86KxWXsR3pJAmZDKuIC2+xb
	 cGxY3JrqDi9w44wX079SG60IxtlzSQesQBcxmAWB7/vhBQobIpa4qU1XKQx6wWYXd/Rs5
	 Ie4fpZJWraenHsZp8d4y4/Z688rEmUEO/3KGTor1EITGjCshiqo4jao94QFUkHGXQACGX
	 tOtZTCC3ddTSGQjVq15/6R5WyWiWdEqBZeU/TYXsyYHGPXtFLvOZkPeCoAGZAHuObZrJf
	 mQh0bsHio+EMOvsSt7uPQQnnN4QpfhpOLRZEP1C3j/D+RSF/XqxZ6J6kmVlt35bmtBQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mKQcTmkb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 70961606D826
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 14:15:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mKQcTmkb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E88B11F00A20;
	Thu,  5 Nov 2026 14:15:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793888133;
	bh=dWl9qIyyT5GTbz8Zh9XS4FgbJfrczPtjtTFP/gieClM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mKQcTmkbt11MCNwBKVETHsQOgfg/+WDhuA6RUc5+7CzZXwoLI+YexCeQeXmlja1sc
	 iPGzOro5pPuNag61GsAhJe3ytqO8BFFwGP3LGvzursf7f7DNrhnrglihlVCLsVujl3
	 sD0CrDnPJDlNVBN0fgK4lPrA0FQFZkT6bUTtiGyKb6ape1C6ee2CgjpizgU7bIcpPf
	 vFtHqiQmwocADdg4z9F7VUd9083uJFmois5oys08koIOG+5vzEzXWaivQMw8Sc1pA8
	 tlCPYNDoAOLtLDtG1Y4HCijgWY64rSsuS11NEtba5ibdg3Q5R6eYH0w20rSPuBUdUN
	 OP7GTSPwz8uPw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3DA55F40069;
	Thu,  5 Nov 2026 09:15:32 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 05 Nov 2026 09:15:32 -0500
X-ME-Sender: <xms:hI_sansukuYM_t2Qfasbo28ErltExv8dQGMxneb9gDg4TjR_s2hJEQ>
    <xme:hI_sajQg8-BTdgG1ZanLHYzGVtx_v-6RZA6d-AszW_9kbNKVw2iUZbgzIreKsKrA7
    9DPdn4Bpoh3TPhYdjB7djhTD_vwruEpVCHF1MIjz7pTN4F2UYEtbBc>
X-ME-Proxy-Cause: dmFkZTEbqNS91ZW1Hk6vrRrfzyGwFYp0ZDpS1rfXn7DNPUhYK9RmUTVjl7XbEQQY7PbTB6
    k12X0E6UvtpNpw6FkuR+AXnEAJJQ3YOJFHNk/CU6Wy9rda+HQxEWbadEuOtZsU4/kxuwow
    ZrsbFxMuldzYp+IfNFXdr5kYJdOPE7Quoikws9qrwk5YIKv8gl0tqboUQ3IPVUFeotjSE1
    MbGPCLNi6Syat30cUXTJGSC6u8eSeHDeCeL4Y/PwVlZYs/n3vGyohvaaY6Sw2oFrO8hI1Z
    N+vCVdsb2/IEQAnelDC9nsbkDfF8j65ed3Fx9mC0q39JqIprfH9svuVucqNkoJS0VcsHTn
    LHuOwL9FBOQjZFeZVaWPQ0dGLUlfkOjDYLK1ov7ar7iPMbAJ+qCW24Lnj63aayZlsZCB/9
    uTHLzRhnahNhIBd9JXObovybo00SHugK5rWtIpQuog7zhCgOuFUo6Jdq3B/i2c0y67Fkim
    F9/DKXUEI/hA2m2IYPBc0z2Ls32kgNWY01gPO50ikjSVbWpZ/AdCriJCwMdS+5q6T/JSvL
    GM6sZOfoMOJm6Oq6UUfgK4y8H96umFw1gvub7tbgOEVgXMeYjVuyraCEHGPKsyxd6XFv3+
    X8+CIYba23GN1WPV6tfQAyj3bIEk85uvtHsNgdBg7UM9r98cBZp/XZqkLXBg
X-ME-Proxy: <xmx:hI_saneRUGvh7UmYi0YmCIPSYBZfh6mjEwrQkrCl-zEXWtvJSEzeOQ>
    <xmx:hI_sanrnSynP0hMTtSKvPPk5QqPf8m7mIMwmbh_t0Q81R7YVmgmKQQ>
    <xmx:hI_saoCpK0q-bCiXMAhxkmGXubBFu1MB1I9jM1oe6GZ7aWA-lVOY5w>
    <xmx:hI_sagdN0I10iJuAdGdrVG89ugUiN4XVayVTYJD-vQ6MLnP-L9AVZA>
    <xmx:hI_saou1xgB1RiVu-m2hk8zgrmsfU2mlPAG3Okpun14aDq9eOFECmZ0l>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1E75578273E; Thu,  5 Nov 2026 09:15:32 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AZw_cbuSOhNR
Date: Thu, 05 Nov 2026 09:15:11 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <1c6254c3-6b90-4a2f-b797-5d8b1ec9ca34@slotpi15m67>
In-Reply-To: <20261105030710.2652306-1-tmenninger@everpuredata.com>
References: <20261105030710.2652306-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH 0/2] SUNRPC: let cancelled RPC/RDMA requests drain before release
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 11/5/26 3:07 AM, Tim Menninger wrote:
> Cancelling an RPC task does not establish that the server has finished
> accessing its advertised Read or Write chunks. Releasing the request can
> invalidate those registrations before the server finishes using them. A
> subsequent remote access can fault the QP, disrupting other RPCs and
> driving further layout cancellation and transport recovery.
>
> This series lets eligible cancelled RPC/RDMA requests remain available
> for normal Reply-driven cleanup instead of immediately releasing them.

Apologies in advance for the length of this response.

My first concern on reading the cover was the client's memory
protection model. An RPC/RDMA Requester invalidates the MRs a request
registered before it releases the request, so that the Responder can
never see the contents of memory that has moved on to another use. I
wanted to be sure the series avoids the connection drops without
weakening that model.

RFC 8166 attaches the protection obligation to reuse, not to the
upper layer's authorization state. Section 4.4.1 requires that the
Requester protect a region from Responder access before the upper
layer may touch the data. Section 8.1.3 requires invalidation before
a terminated RPC's regions are released for reuse. Section 8.1.5
permits a Requester to invalidate on cancel, and gives the reason as
stopping a late Reply from altering memory after it has been reused.
That section then describes cancel-then-invalidate churn as a
denial-of-service exposure, because the Responder's replies terminate
the connection. That churn is the storm this series is addressing.

One might ask whether a layout revocation obliges the NFS client to
invalidate at once to fence the DS. The pNFS layouts were not written
with RPC/RDMA in mind, but the SCSI and NVMe layouts are the closest
analogue, since the host registers its buffers for the storage
controller much as a Requester advertises Write chunks. RFC 8154
Section 2.4.9 and RFC 9561 Section 2.2.3 put the fence on the MDS,
which preempts the client's reservation at the device, and that fence
covers in-flight I/O. The client learns it was fenced from a
Reservation Conflict on its outstanding commands. No host driver
unmaps a buffer under an outstanding command on a live connection.
The flexfiles layout over RPC/RDMA has no reservation, so the MDS
has no way to abort in-flight DS access, and the only fence the NFS
client has is a disconnect.

When these patches are applied, cancel now means "wait for the Reply
anyway, up to the request timeout". The task holds its slot, its MRs,
and its ULP references, including lsegs, for that whole window. I
expect the held lsegs are why the lseg patch is needed to avoid the
livelock. It looks like the request's RPC/RDMA credit is held for
that period as well. That might introduce a deadlock opportunity.

My other concern is complexity. __rpc_execute() already juggles
tk_rpc_status, the signalled state, queued callbacks, and the wakeup
of tasks that acquired an exit status while asleep, and that loop is
hard enough to reason about as it stands. This series adds a third
exit path, a drain, with its own exemption from the wakeup check, a
drain function that re-derives the request state under queue_lock
through three nested conditions, a special case in xprt_timer(), a new
-ECANCELED result from xprt_request_transmit(), and a condition on the
conditional disconnect in xprt_release(). Each of those is a new place
where a cancellation, a signal, a timeout, and a Reply can interleave,
and the interactions are spread across sched.c, xprt.c, and
transport.c.

A handful of specific complaints:

- xprt_request_release_needs_wait() takes the RPC_TASK_NEED_XMIT
  branch before consulting the transport. It dequeues the transmit
  and returns false, so a request with MRs still on rl_registered from
  an earlier transmission is released without draining. On RDMA a
  retransmit normally follows a disconnect, so the connect cookie
  would not match anyway, but the branch order means the transport is
  never asked. The commit message or a comment should carry that
  argument.

- A request whose marshal registered MRs but whose Send was never
  posted has RPC_TASK_NEED_RECV set and a live connection. It drains
  for a full timeout waiting for a Reply that cannot arrive, then
  xprt_rdma_timer forces a disconnect. The drain turns a cheap local
  failure into a connection drop.

- Widening every rpc_task by an atomic64 and converting the hot-path
  reads of tk_rpc_status is a lot of surface for one abort bit. Is
  there a reason the signalled state cannot live in tk_runstate with
  a documented ordering against tk_rpc_status? The race that
  5bbd6e863b15 fixed was the flag and the errno disagreeing, so the
  argument for the combined word needs to be made against that
  specific race.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
