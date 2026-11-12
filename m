Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794456202;
	b=v2D3qWSunZIvjCD0Tqn05K3gNmI7CdLwTq2jnc80pVNbo1ibR8OCwlDHILoF3rJx/JVV
	 5bGOSVHi2p6Ue5c2t1l34qspRcn9vxmPjtbJOgEP9Ac6J2CvkDpSG6qlaza3nNnCDzBbp
	 SJ3s6WqBO22w5KyNHpA3q5rJLNnOQTYR9hsYddrBno5EgEjfQTTwJNBOisUuZdBpmDbG1
	 59Dr5iHt0bn89sh7mh6eBbIdjO7MUtw07iCt94FG7Dj8D8NVrA6Q8v1Z3mnOVI7twBuYH
	 XnsCnQ8LzA1v3jr7UriwRDGOaZyzYMvgs9Pqi8sILHhyUvHONf1eVOV065+l8Mxr4NQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794456202;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=4IKEyNNVMbtlH/YtAA2tKyWfWnOYgIJubMPziZyywq8=;
	b=uj6CaVp1PzYsHSNV/tCUJLCS9+1/kTApHWA2XCEwoAIaRjIJ7uMktP2NdZlM4WQcP+mf
	 4qCZ416awKJgLTFpY5o58a+S90/vpbnv5/3vjZsNJvx8qq3tTooP5Di7ffwnJxXQxVmc+
	 u/hkSdbRcRsk+Z/rlmwHlr+3wsOpKwj4eUXleFYi8tbKic8kFibwWAIYCqZg3hE/WtQUy
	 2giQsz9jvAIFk9uR0azsJlR+vXrQWFz/EYgz4mT0BjD/yTXnipkj0YifZP3QQ2hMgbUFb
	 bdOIqGgzhchH/lHdncVdatvIzihINpzKyL1COOUFSNTC0F+4whKH6G1UcQS3tZIfabw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Aen44voi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id A226C606A898;
	Thu, 12 Nov 2026 04:03:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Aen44voi
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 981B91F00A05;
	Thu, 12 Nov 2026 04:03:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794456202;
	bh=4IKEyNNVMbtlH/YtAA2tKyWfWnOYgIJubMPziZyywq8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Aen44voiHzkLnMRajZaIVxtwbM4o1dlqKyvrTGOAmx1f/axsRAZLC7tJH2r40DK3Y
	 lckzJcSkOV9GYwbZpKExeRVtCTBpMRa1IqDcuwhibBlRvBGw4eirJ4t67mGdx3giLm
	 /pGM+lgXlntX1lR4zE+6CFHGIE1nDC0url2pEr4b/Q1+jpQeSTDm6+T7ZeVTxzqE+1
	 xXILZ1Nbm9SM63fD4klsLL0RfnHutOPU7o+nC5wEjeYJHODS3Rq4may3SlAhaiTaG7
	 1mf2KuF4w9zApa2+BKXLJQmrbbnB/91jB0pu9YJJGCNxTfKr9aKVEwXFF7ikmhaBu9
	 j946nZzw5O+NA==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Jarkko Sakkinen <jarkko@kernel.org>,
	keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>,
	Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: [PATCH v6 09/13] rxrpc: Release conn->key when init_connection_security() fails
Date: Thu, 12 Nov 2026 06:02:38 +0200
Message-ID: <20261112040242.247168-10-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261112040242.247168-1-jarkko@kernel.org>
References: <20261112040242.247168-1-jarkko@kernel.org>
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

Clear conn->key before calling key_put() when init_connection_security()
fails, and pair with READ_ONCE() in rxrpc_connection_seq_show().

Fixes: 17926a79320a ("[AF_RXRPC]: Provide secure RxRPC sockets for use by userspace and kernel both")
Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 net/rxrpc/conn_event.c | 7 ++++++-
 net/rxrpc/proc.c       | 2 +-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 611c790bc6d0..096807f13354 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -298,8 +298,13 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 
 		ret = conn->security->init_connection_security(
 			conn, conn->key->payload.data[0]);
-		if (ret < 0)
+		if (ret < 0) {
+			struct key *key = conn->key;
+
+			WRITE_ONCE(conn->key, NULL);
+			key_put(key);
 			return ret;
+		}
 
 		spin_lock_irq(&conn->state_lock);
 		if (conn->state == RXRPC_CONN_SERVICE_CHALLENGING) {
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index e9a27fa7b25d..2bf34b85c2f9 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -182,7 +182,7 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		   refcount_read(&conn->ref),
 		   atomic_read(&conn->active),
 		   state,
-		   key_serial(conn->key),
+		   key_serial(READ_ONCE(conn->key)),
 		   conn->tx_serial,
 		   conn->hi_serial,
 		   conn->channels[0].call_id,
-- 
2.47.3

