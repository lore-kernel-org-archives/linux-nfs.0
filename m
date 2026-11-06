Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793945282;
	b=GxeN762XN7V+bv3SvpJoXE8hPF2CtcuTr+8WPgElqWVm5ZceCVhM1EKMOk4dOpIV5ZJ4
	 XwegXTn7ls0uCgCXuchz2IeKWecBYg8aTbAUmSgUXxWFq2fdXHj199A2+vI6ldY/pBKt6
	 BQRHctjmeqT7XDWKEtfb+etFdkQ4kTgCZz3Aa0wXSNGWu2tLLh+kqqinpS0cvvw6f52ey
	 F2VJAbNQMOcm/tcsaCoP5YAfGQPUJI2tCkbgKXj0SLMKP9f9u/EBT8CDeodpH/Ho9v2aW
	 PgC4MI5EXSb6hrJd4zJM0reLHY9qYMw0mvL5B/QxzubysBdXCsqkgXdG3oWCiBQuPmA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793945282;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist:X-Virus-Scanned:
	 X-Virus-Status;
	bh=YWfrO+3PGngce3vAA+WeVwidWQAaCmbQuGPi06xHNro=;
	b=VhRA7XSyEIyeFPxCP/iP+kyClBznwWgCUHE1Wx3Fv5cCKmu5fbtKZdpmrUgkrmMwzXHu
	 WD345Vl2BQJU+os0A9lbAT20O+8CkPA82GUjoPtHn/K3ngnqMiPVpR5cbVVCwZo51y3gz
	 g8eb6kKV4PbGc15UglKwL8Z/K61Z4/K1ttxU2GUL8oa7T3wY65g+aSg6x6iSozoYScdOI
	 /bO/yUecMDmRQkX1E51AqQ1NCYierZDooXYAQFJAv0TXttv7JiLJ9JckxXMxKkAlkjL4J
	 KBf6z1kSZOZdZnmfoQPTPaOpNRvlFID/fOWhgsx49BmOhOE+YXpAfjbrrxpeTJVZiVw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=huNjMeSE;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2320A606A329;
	Fri,  6 Nov 2026 06:07:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2320A606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=huNjMeSE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1793945273;
	bh=oxQ/XatkM5jxRdXO267bhYI/CjAhkGUFXp033JxNLIA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=huNjMeSExGDy27bXgm9B5b3lZufUTUe4yjSuMqmGCphhmRecJ2JtV/3GUvjjjkXOV
	 nwK7S1bMYhaVmNw1KUGvJO45by9C1fCRwRxUQ+DYcjHP8gWYLH0WJQq94CERFTDgC9
	 JlWR5bg4CV+jaevCDxSh2C+R9i+Ipnq2etvMBr1ReKaqxCFoxkZIo2Sn/F3icILqmy
	 Kf5qclY04nv7YNpTPe8BtH9RCfD9zOaUg9itx9tN9dJ6VgkTh4CderDQPHFLBj3atU
	 S4MFixFNocuBy3SvmcrP4fnU2v5ZGeLMGUyAfYE48Zw7/KtaoiVCfjAp3zOpeKDcXE
	 GqoR3QARhPEXw==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id 3883710924117;
	Fri,  6 Nov 2026 06:07:52 +0000 (UTC)
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1127DF40066;
	Fri,  6 Nov 2026 01:07:51 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 06 Nov 2026 01:07:51 -0500
X-ME-Sender: <xms:t27taooP_xPYjbHlmXZ_RLLDecqBtppVYGKl6w7f890mVJNhXr5vAw>
    <xme:t27tapCu_DEz1i-14dr6JoWPAjxvCBkqpz2C1vhe8upYM_qw2ddxpOjogAN3BlIVi
    OsQU91HbRti0WHFh3J_m2uQwSikSXeFu3GzHCwEpgjdigjsLuB25G8O>
X-ME-Received: <xmr:t27tajVT8sbmtTvvrJOe42AIwhmyyR11DVAj7LnlvVqqVMiN8r8fYQriKoX7PwDy9sSOOjrlIqrJ7wJ7F676PpAnXIQ4nK2kqEwywT3ObfY>
X-ME-Proxy-Cause: dmFkZTGJt3n1PQXC/FQG1+B4dDYdd7jzhZlyl3cBdgxPjc5MzKuIVzENiuR0E8tXhVCYot
    oOxwUXQVpp6VAEFUg+Uag3+jV3NxxQBqkuwqHRpa3avIMsMf5rLSrLvoU9/YiPtVmmw1Nh
    zLPLiGNoLWEom9MXOxTuny0wuIwJj+YnwLd3gmlT78BD8tHIS3uMrtPiOeTkzb/BpfqHcJ
    ZJYCN1MdLe92Bp5QjUXsKpkDjC+xSg0gfYGGYkLbuDh5Mj+BFcqCO2KyQpU99GhnUhksCQ
    Jqp321gTZQ359Pfjg6F4oa2enLz7ZLclUfrma4OACrOvjp2Zeu6dpHGkjEpDMo+QrHIVq0
    fPMM9bXKM6l+BG/yuRuKG111J+oroUSvT0iSmY9cALE5HIH87U21thWpHH6wHEgGQBiEtH
    LntpzjCg88yRAeWhDp473vOfvzyI4VtD+LMyUNtFTBHpmgR//cy5duykjZy7NrqE3s7Atk
    AeN4QILVnj7M7xU3FkkYEZUX4caYa8SC+PtRogk8XdWDnn+tIsSOGxNXeN1Sp87gpeQl5v
    XLX8Lr8Lp+n85qJLkCNKagr4EhXLwYsx+CezzZQtxLXLmeKQ/wrO6ds6Z652jMUllzX/aa
    ouFblC5kIhlM0jv2lkvZEMsqqSF4F5rjD6ey5P1IqGUybJe32nr0mCmQv7dA
X-ME-Proxy: <xmx:t27tarAvMjJFfCKoMk1rogDHG53bwn-UI4vZMQA4lXh_SqEdgPcOnQ>
    <xmx:t27tagdzoaA6rSFNBn5sN8c6lOJEW0eOFJNDUaZvCSm4-XdXYB_tgQ>
    <xmx:t27taiq3NMLIoCTEcAMR_FsMIOf3xnBZLQGl_yHJ8map53LKJbICjQ>
    <xmx:t27tahQpnbT_FgOeD1YdYjmmXJE_XpHFlYoATuDbFgVLZAKj-WcqgQ>
    <xmx:t27taiVF1KYKvI0pyzH7ahYn11b_RUKhOiPUrIS1k0TzJHRreVnGe9lC>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 6 Nov 2026 01:07:46 -0500 (EST)
From: Andrew Pam <andrew@sericyb.com.au>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Andrew Pam <andrew@sericyb.com.au>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] SUNRPC: freeze rpciod and xprtiod across system sleep
Date: Fri,  6 Nov 2026 17:07:29 +1100
Message-ID: <20261106060735.637295-2-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261106060735.637295-1-andrew@sericyb.com.au>
References: <20261106060735.637295-1-andrew@sericyb.com.au>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Fri, 06 Nov 2026 06:07:53 +0000 (UTC)
X-Virus-Scanned: clamav-milter 1.4.6 at shining
X-Virus-Status: Clean

After hibernation takes its snapshot, the kernel thaws devices to write
the image, and the NIC with them. Freezable kernel threads and
workqueues stay frozen until the image is restored, but rpciod and
xprtiod are not freezable, so RPCs continue to be transmitted, and
transports reconnected, until power-off. The server acts on them; the
restored image knows nothing of them.

With NFSv4.1 this wedges the mount after resume. Captured between a
client that hibernated and its server (Linux 7.0 client, 6.12 server):

  - 05:06:02 last exchange before the snapshot; client snd_nxt
    2711544997.
  - 05:06:15 hibernation entry.
  - 05:06:44 and 05:07:48, after the snapshot: a lease-renewal
    SEQUENCE on slot 0 (seqid 192219), the next (192220), and
    DELEGRETURNs on slots 1-5. The server executes all of them and
    acknowledges up to TCP sequence 2711546645.
  - 14 hours later, on resume: the client retransmits the slot 0
    SEQUENCE from TCP sequence 2711544997. The server discards it as a
    duplicate and acknowledges 2711546645, which the client ignores as
    acknowledging unsent data. Nothing more crosses the connection.
  - On reconnecting, slot 0 gets NFS4ERR_SEQ_MISORDERED (server at
    192220, client at 192219) every 15 seconds indefinitely; the state
    manager waits in nfs4_begin_drain_session() for that task, and
    every other RPC waits behind it.

Other resumes produced the same rollback with different symptoms:
requests accepted by the server's TCP but never reaching nfsd, or a
partial overlap that left nfsd reading a session ID as a record marker
("svc_tcp_read_marker nfsd RPC fragment too large"). Restarting the
server is the only recovery.

Make both workqueues freezable, as the SMB client already does for all
of its workqueues (WQ_FREEZABLE | WQ_MEM_RECLAIM). Work queued while
frozen runs after thaw_processes(), in the restored kernel, which is
consistent with the server. Memory preallocation for the image happens
before freeze_kernel_threads(), so writeback through rpciod is still
available then, and pm_restrict_gfp_mask() keeps reclaim from issuing
I/O while the image is written.

WQ_FREEZABLE is consulted only when freezing and thawing, not when work
is queued or run, so normal operation is unaffected. Entering system
sleep now waits for in-flight rpciod and xprtiod items to finish; these
are short state-machine steps with non-blocking sends and connects. If
one ever blocked for longer than freeze_timeout_msecs, suspend or
hibernation would fail, naming the busy workqueue, where today it
proceeds. The SMB client and XFS accept the same trade-off for their
reclaim workqueues.

This does not stop the network stack from acknowledging data the
server sends after the snapshot, such as a callback or a reply to a
request still in flight when the snapshot was taken; that remains
a general hibernation and TCP problem.

No Fixes: tag: rpciod has never been freezable, so no single commit
introduced this.

Tested in QEMU/KVM: an NFSv4.2 client hibernating in test_resume mode
(the image is written, then restored at once) against a 7.4-rc2 nfsd
with a 10 second lease, with 1.2 GB of incompressible data in memory and
the swap device throttled so that writing the image takes 81 seconds.
Without this patch the server received 12 SEQUENCE renewals during the
image write, none of which the restored client knew of; after the
restore the client's mountstats show a SEQUENCE error, two extra
connections and 10 seconds of queueing before it recovered. With this
series the server received nothing from the snapshot until the restore,
and the client resumed without errors. The indefinite hang seen on real
hardware was not reproduced in the VM: it also needs a request holding
a session slot across the restore.

Drafted with an AI coding assistant (Claude), which analysed the packet
capture, wrote the change and this description, and ran the test above.

Signed-off-by: Andrew Pam <andrew@sericyb.com.au>
---
 net/sunrpc/sched.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 016f16ca5779..41f25309b8fb 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1276,13 +1276,18 @@ static int rpciod_start(void)
 	struct workqueue_struct *wq;
 
 	/*
-	 * Create the rpciod thread and wait for it to start.
+	 * Both workqueues are freezable so that no RPC is transmitted, and
+	 * no connection is made, between taking a hibernation snapshot and
+	 * powering off. Anything sent then changes the server's state but is
+	 * missing from the image, and is forgotten when the image is restored.
 	 */
-	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
+	wq = alloc_workqueue("rpciod",
+			     WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_FREEZABLE, 0);
 	if (!wq)
 		goto out_failed;
 	rpciod_workqueue = wq;
-	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM, 0);
+	wq = alloc_workqueue("xprtiod",
+			     WQ_UNBOUND | WQ_MEM_RECLAIM | WQ_FREEZABLE, 0);
 	if (!wq)
 		goto free_rpciod;
 	xprtiod_workqueue = wq;

base-commit: f66469d9905b39d2c260a15d7d6db450f4db67c1
-- 
2.53.0

