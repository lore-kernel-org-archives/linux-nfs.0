Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795056466;
	b=RtK/edkU9ArKqA0CA7lCagpkl8Jr+0Dg6ypKw/wtzcAMGhud37+av5EPKioicqsRuHai
	 okaXyy5FSm7ocrk1WvoH7dNajCI/4KbCmTKdMvI7jBOBGv+jXHJsXeNqBYk/vZBbQOXy6
	 8NyGxkCq4DBgti9yLoixPAk9+TVpKlTy5Dle9p15Xk/oRfMg1U7RrBdfIBZD1xOPb1Q0U
	 XdCkwXf493STHf2dVkHTiMcDGRFBrsWy+8rC/6DMuybcpkHIPulD0nbqs6K5+l7/eD81S
	 aIzL0/nj0ozx/QvWbP3dPmvYWO++wJNAWvKPEC+TePEHMP/kCpMnhem+0J06HIloSnw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795056466;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist;
	bh=p4Z9WbzzmZJhK5jv1RyFsS4DwQd0bEisA79+Aj7AlYs=;
	b=JVg9jA/74IApon54Y86IbAE1NOtz+cD6da7rwL8SPZvZzCdlr0pGgsrJgZLMIYTHEWXy
	 86nlWvB7N+UsBmwvaYOD4AcsarqPbD0/3YWuo00U6u3hsrnafWgDb0bOHY4Y1zgkFBe7y
	 8OI5VbjfLkvcLdwjO8etPFlOeMBOXBmKf9piQK801xUKj63dITtwhje6NdW558MEcUItP
	 rxVutsTVMtYHBn4JHz6h6RHhPyTjQdhyNRR3TWr7QuQKLbW1Tg7odbflmi1EoqpQE9Qr2
	 8/iLt2rPRD+Fhm0y2svBTiDjIK9dqNSK0tUagl4DCbd8csyR2kNbTS4v4lrS1jf2WyA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=ceU9Izkj;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 126C7606A320;
	Thu, 19 Nov 2026 02:47:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 126C7606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=ceU9Izkj
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1795056458;
	bh=2YpDlOgrc842bzP864eVaerni2/1dhmgszVgFLOXZ+g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ceU9Izkj6DKnMatv0+VvoaBs4H4g3AUNSv+jQ38twvplhA6wV26V+z6SN1qYZS/La
	 eP6vXAOz1um1GXnXJ7gk22G6i5BWRXWYVBRIFDNoyotEOxR3NX/AGMndFkLVA/YEKa
	 KG75ZA4mqUHzki6qPbNji67qzI3OkxfG1pbC0W36enu/je5qqEwy9knwRIWZS+HZIH
	 bFQtHPCrTSkGdSXf+Aanfff7h0+DnzIyYHSxMDhih5R3jlzJLou45U2YITLni+JmcS
	 sinVfH66tZZCaJkkkYBwoHHEVtxEutqseE9h+eTXJ+jB1Ex1R7ax2dUX+82A0ko8+f
	 PQpB+RqqxSqIw==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id C092C10A47D14;
	Thu, 19 Nov 2026 02:47:36 +0000 (UTC)
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfauth.phl.internal (Postfix) with ESMTP id 92721F40066;
	Wed, 18 Nov 2026 21:47:35 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Wed, 18 Nov 2026 21:47:35 -0500
X-ME-Sender: <xms:R2P-akCq8V7wislUW9xEKo95hOfxFUOKBKHWEal8R8h5Db1gGwkI6g>
    <xme:R2P-auHMbFVYrIUghrkqRRAWkpql_Q0gn1wSnY4xH0jrN3IiQZukhX3M-aS9vuPZs
    HhO1xS5Wx3ooNVHq7vI2FyRN2FOuFy8nPtegCStp_6fqLVAFpS1Qi4y>
X-ME-Received: <xmr:R2P-anNsfDdFlEDruDAVoD2r_QYqBCBdbCrBD3m24azs6aJowzCmvmdkvw-T9zvP1YOqTVtPgt_RFDM9KcQLfUkg4Y18Ku0recG5dqveL3UWwQ5VHSZ8MME39p3B>
X-ME-Proxy-Cause: dmFkZTEMW7OahI9n0RVWD/hEubSqpcQIBbWb4/r2ccfp0OXDKdxdLkclumBQpPQpsWSFRz
    CyE05zdXdLxHyUOnM8STj+8klDTwibnvrXrxa12jA6qpgCRv+xKm3yFC8OcswY4vGfkYsv
    SKEGdxYytFYwghqrklhTNNMG/B+TOlqN+EunxyzzR2HoEcNSnJBZzfM9YM12kISOaXhkZy
    BstzFQwoevOJ+Neex9Aw7uWNFFB1AAxVP5En+KR/69ZtRNOgfCTLN+egjGK1fsy6P2N9O/
    6xoRVkcHyjNJXQPClJdTeivWGLoKkiKQguqMMO0QUoYTf7YmlnaD+MMjVLmDqtjqvcLrkO
    3TJO0kYlUVgulUlvdZi0OB+ZK75ozMJZ1ln4/nwXQVTRonkd/Z8LtTOlwI9uRPeZdB3LEL
    dF99brKvkmedqY9IUwlrhqbln3kSJwVjFLWREl1Kp//zj/u1+EmSjGjxaWPwHI8bZtdtpb
    pn92ZY8UbeQZ+X7UFGzW8Nq6WksFuheY0VEyc5gXEJ9I9WuJG1WSZ5GY8suE93Qb2lLWoM
    7qoXmmsvw+F9KiJUE/ueXNqqzVDaxMa2RgzWX1/H8qikvGrhtbsFg8g6lb7ZYyfdtI9EW4
    cn64QvzMWF5OgpByJsUv5rpYm+4+dIyL0pUBMgtwjXh+MCMrv6mN/zbr6CGA
X-ME-Proxy: <xmx:R2P-anjeINH4NP6q1U65XQHDqDcF_4mv5PZzNcfgtMPZCTuaOaz0Fg>
    <xmx:R2P-av0Q0M2DAqI0gWaPO8ymDamCxcZVFttcSWLsWEw-P5IBUx4E4Q>
    <xmx:R2P-asnHnH8kVeve6f6jN1H0yOKgrS38n0eHgrho5pdAsQPAn9I5hg>
    <xmx:R2P-amvChyJjua-Jx0fNljDBXxtXDjNW_vfq2AtkCeun9wriG7h2xw>
    <xmx:R2P-ak01hIJgR9j4LFS44D-PNpzPbcYkRl3gAMM5Rh8RX6R1toyTArIn>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 18 Nov 2026 21:47:30 -0500 (EST)
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
Subject: [PATCH v3 1/3] SUNRPC: freeze rpciod and xprtiod across system sleep
Date: Thu, 19 Nov 2026 13:47:16 +1100
Message-ID: <20261119024719.311474-2-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261119024719.311474-1-andrew@sericyb.com.au>
References: <20261119024719.311474-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Thu, 19 Nov 2026 02:47:38 +0000 (UTC)

After hibernation takes its snapshot, the kernel thaws devices to write
the image, and the NIC with them. Freezable kernel threads and
workqueues stay frozen until the image is restored, but rpciod and
xprtiod are not freezable, so RPCs continue to be transmitted, and
transports reconnected, until power-off. The server acts on them; the
restored image knows nothing of them. With NFSv4.1 this wedges the mount
after resume. Restarting the server is the only recovery.

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

Drafted with an AI coding assistant (Claude), which analysed a packet
capture and wrote the change and a draft of this description.

Signed-off-by: Andrew Pam <andrew@sericyb.com.au>
---
 net/sunrpc/sched.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index e81419aa553c..f1669d1b8520 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1273,7 +1273,8 @@ void rpciod_down(void)
  */
 static int rpciod_start(void)
 {
-	const unsigned int wq_flags = WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS;
+	const unsigned int wq_flags = WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS |
+				      WQ_FREEZABLE;
 	struct workqueue_struct *wq;
 
 	/*
-- 
2.53.0

