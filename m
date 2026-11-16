Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834902;
	b=MR1N4IKVYqTaBpSKaag/Od3ciMmE3fDYG0n0xdaMkwfQnm1sP+9OyZWmrS9ivJuRMg0B
	 S8JXyyyUpv+N2f3g+w3e7P3yQiIQbR/NOVihBO1ea2QeIUY4sFlfo2m4ylTcYFBu4Tcvc
	 q6RuytDtTd8v0lXleUGnF8gZaQMSYV3+0wZ4TjZ9/n8Nn77nHoZiV6QA6LXPdcuQAwUeI
	 cThKEKTExb5q0n1nUW5Dl9fVT6lEX55mYQgdOjJIhBmfHxW/0GEB8KTJjuP32gsnJd7Dd
	 fLlVn57yHEOCaU7qteKh7cxHF3tdvQYi6gFPk8sd/NVQFpeI29LklUuAzYjoPLQGvuw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834902;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist:X-Virus-Scanned:
	 X-Virus-Status;
	bh=4tIglgSSDY6WCr/p6Q0gFfKw8rdZk8yF+xh4yUOtXI0=;
	b=c+RToBWPRBBg7ACdux3ziPY3EUP0HCxm/uDO3oVt8NGa7QEReUjetgkb3MT0a/qk+ovt
	 0d1l/qZpFSVuy1jsy5fescKjGXL/mr+nu6Mt9H58DY7euXOQG0EGbs0Y1zoHuukvLsUy0
	 y9cdzWapDiLILufzbsiI8YkeefdAWlWG0JtdQ5qsA1CurNkZOmtJ413DUMCb7jSN4qVbo
	 EU40KhVOirWfUEsfi75HVTLcwyt30SGk049eEvlOnLh0M/wj1K5yoCWyY/AHd/QaMWYUT
	 sAr83+eJqMkAHpFlCJIwGAxUgnHbYaqefK8rT2UmA7yEIbhP/oYQ6Bmb/MqHietJi/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=m6Rcnfi1;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23AA9606A8AB;
	Mon, 16 Nov 2026 13:15:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 23AA9606A8AB
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=m6Rcnfi1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1794834895;
	bh=NaxaaBAtdO+nrBlbvzD4T7eJct9q2+INkFAxrt7Dd4U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=m6Rcnfi1Gw44s14pRrdjSzUcbYAZ5dcWZL26csAT6HgCA8j3YMVaSg4Sxm1E+1uAP
	 Jp84TXFQ6IpY00DzFhIdVH+M64H7RbzNNcelby0hJ8U6d2OQVvWwvV/mkJ6JfvUKla
	 uZ3rX9mkL2TaUbbcjoBMnLkKm6yJCcJiK6gGzSnMDcAvRzr0gOOuywf30LipoVef1d
	 QALoJcsx8xCn7z/dL7DtTLzimkhPnpy5pOMNW5ksFPyBG1/lu9A/zGsNGD+rLCTpEK
	 oZbflVTcJg3F+4vgRGgBeMvRfDgjZaob7oSFWkHNAoXKoHn3nu30xyWD9vUwJpT5by
	 y8Nm7zrJecBDg==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id A7551109F9844;
	Mon, 16 Nov 2026 13:14:53 +0000 (UTC)
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6D9F0F40068;
	Mon, 16 Nov 2026 08:14:52 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-10.internal (MEProxy); Mon, 16 Nov 2026 08:14:52 -0500
X-ME-Sender: <xms:zAH7arKbd8ptJsxCHJtECkIT9ste5DB3n7Caq0Nu4arponC_EBqczQ>
    <xme:zAH7amsGeeVbCQbgYEOkd9yvIIecFaK8lG2KEPI_D3TwYjqfdCBwn2xH6YvONIZXl
    OBx5dpmcckAb7DyeIqrtrFu97_q-AD5x_Mn-Z8-GPSv71JZ31rx6EnH>
X-ME-Received: <xmr:zAH7ajXomj90JLFk1vPtHluaaU_zhiV7GDK6MnLk-R_tJBYKDsBjZJ4O_qk89tBAm7bK3E0QXWQA20b2AJLPfbwh35mISB1z6pVFUD9v7hs>
X-ME-Proxy-Cause: dmFkZTGmvlV8o6tTz5AZYkKQRzteI9TVjKztZwk1AxfWHAAW3IvbWRQid/0DC6DJW1xAx4
    7iI2QWYdqhZi+4AoLoFsqd/NOoCGiIYgpMCmkpRZknF2t5soFxl4LH8DEK1qmg8g76OwNF
    sR9aCniT9pUY7IsYm9746Jk9twf87zV1ynYzHh0riMcBkoVqmNun3FuLNJXWxKbdQWWuSR
    C4ou3faNJ7AR00BCLoqv+p4UNiStkAeTWgi7wyFCJmHAVWNtgapnU0130EVtHKlaIgt+s7
    Jst2loF8582z2Gzc3V04mmNZBiFe8eJT2jfCElCFZn+KMRgoL1IBs+QHKkxUwUen5AyAX4
    G2MbVxnCpA8eQ2LZOaGPo8sdMDZkb0r1q8St7MXvZwaI0UCmfwKPfNQCarDlxH4uzO+F6C
    PjfhkrNRfX2uA/bTZdq2ESHvTONXPILQ71Qycbvc4vdepGzADNS5Y5VXeSQbT7/w9n1D6a
    F+sxLGQxeWpBz9dtitJkMIiymUqsxTuXK3SBdnYiLWcVnnOAo7PRLK9hJbt6tGRPcsfREc
    Vui29Hmzu8Ut5GAYF5Yzu2yoeeDX66Dfi7KKokJI3c66S2L7hECiPtKsA5i034cr7z6Di3
    BlXqB5u28YK4j1RJGvZYbnnHUkgJ7YI18rzqxnED1vDJsoUbkqxwQx1czYng
X-ME-Proxy: <xmx:zAH7ahLcI_xJyua2AQjnIUD75VpfQp3G8bsJy0a3vNLFvXUol0ZSgQ>
    <xmx:zAH7ao9n5iP9pxAHozfKijDHieCEJ8T-cCouIhVbTK50-nPrZDFiOQ>
    <xmx:zAH7avPPfqNOfAty_jLTfkHHYFIDaKo20ckJobXYASjs6jb9iYd04w>
    <xmx:zAH7ak340m8puDNureKDx5u-fmz4H81mNmpuR7c5FLgeR3A6tGFruQ>
    <xmx:zAH7aocyS6ZXW7AAVNS4ZYxiUJXNiI7Ro1YTLMqJcqVawZiDmc0LnoP1>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 08:14:47 -0500 (EST)
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
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 1/3] SUNRPC: freeze rpciod and xprtiod across system sleep
Date: Tue, 17 Nov 2026 00:14:25 +1100
Message-ID: <20261116131428.1024230-2-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261116131428.1024230-1-andrew@sericyb.com.au>
References: <20261116131428.1024230-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Mon, 16 Nov 2026 13:14:55 +0000 (UTC)
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
-- 
2.53.0

