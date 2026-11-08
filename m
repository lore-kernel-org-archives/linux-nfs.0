Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794176878;
	b=5sg4oBYPMNMrLvb990Vm/Umeen/ZiWOy+08hzH7zKvyvhEKEp9SBgNvz6jGlmYu9r4/o
	 fyFgWKwU7f+mm83xqIHNmTk3To+rI4XGsMVlMu3dITeEzQINcVzTu+fXKA4vvmy937HA0
	 jpm65MuNmS9djm/TSOeXXuQXuS93fqUrmANm+i0XJYBYoodmSN8Fw3zUphGpp2+FaJeEx
	 88Dn/pPioNKRG7Yw18KdYbgXwOFIj97VlUtO/HjcGZ/6PGfppFnUVnphIg0KtPi1uPZ6w
	 /oBGJcoapBwKythvfMu5dU9MSM6vIg9itqE3HSm6mZSUL6u3OvrjMiiH9IHAW2XrWgA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794176878;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=4IKEyNNVMbtlH/YtAA2tKyWfWnOYgIJubMPziZyywq8=;
	b=Ts4fw4imjA0TwARk1zLjWZ8olsZTAGOoRuYtZ4EGqHrK3g4HXbJ+0heMgfwF5hlDBgU7
	 3mU5YpX4Vly73Nde4gIvlpobyg1FR/sEU9ZpHUHSKsba8u/QEM8mOQ9orUYEEckPh2CAw
	 eRQHNy1rXaIvtnxprIX7iVw/71RaJFaMvZmPVyrmnMuRePr0szA35JdScEKz8twynqgqo
	 VSpqj6VKohCQBdyQGX9wWAt8/lTdL73VKoMGbhXxnWBL3Cs7v9LuwDAbtHV3Uzh7Rq8SB
	 Sde+2r5CbVvjifho8Iu9CAJgG2iCy9S3M+Eghv2TAVVAwfKlqgU2XI64lC4p7+ijSgg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wdz8J4g0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 73F58606EE85;
	Sun,  8 Nov 2026 22:27:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wdz8J4g0
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 6053F1F008A7;
	Sun,  8 Nov 2026 22:27:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794176878;
	bh=4IKEyNNVMbtlH/YtAA2tKyWfWnOYgIJubMPziZyywq8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Wdz8J4g0bCy5/NMiYmiXLZEcK/qa4mel5KA7dJrd8tffkLSNG4nTfsy+tUud6n96D
	 Oep2KRKcpj2qhHBRybpakcdAxPYttSAgI+RlPRdXhaFNAzYbsUlBJ7aHjXRHxrQaPq
	 up6TwtBpMMZez0cEPxlEdFLrSHXR1zcdaGa6edNOAhDbzIowLYX8zrsMalfCLnOdh0
	 AV1Nz92M8PG5intxsbRTRhr/stS166lY/nk2sIISEV+xFww6Loh8GjmCTAlk9oTokV
	 cv/29jRI3sBgpLmBie9AIk84wQ73VlQhxemKPq8HSOYy7Bcw/gMp5VcwDundLNG0/o
	 UWGH3KuLDX/vg==
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
Subject: [PATCH v5 08/12] rxrpc: Release conn->key when init_connection_security() fails
Date: Mon,  9 Nov 2026 00:27:14 +0200
Message-ID: <20261108222719.304712-9-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261108222719.304712-1-jarkko@kernel.org>
References: <20261108222719.304712-1-jarkko@kernel.org>
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

