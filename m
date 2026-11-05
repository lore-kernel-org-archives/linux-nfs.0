Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840004;
	b=aR3SNToywPpu+dRrtrs2Sb6eFByBUsK+7o6m1EjxEN9IZkRyAyX4IDrHeOrBh73VXAEZ
	 4+rPlGB/ko2scaxy+XONNmXs5yyMnCALxFn5zFEombUOvhnMpUMHdagj8c3kyWtb++tYV
	 s4pNVC+sidNEHxqG+buP5nun6HDKlh6Lw/LySz0WCuIV3k7WjfZLTpvOPwF8M+x3vSC1c
	 t49rxeiqXfVZpdNVCTV+tEyQLYdvZRJc93YNJHyHO5nUg+Jq4P4txJUoiOZq1DYVhEPwX
	 HQHnOmm6oSsiAXgUxxCY5aHc9x0Wlh0BSKSOdm3pmOce23nyEhQco5XAi9Tf9K/4Pzg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840004;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=INED4MMgZrZwufn0swCTjWvWb3dcmH2/0DSknrA89G0=;
	b=OdHn/FQ/3JxcXlmrlUBbppO6gPQ9BDf1xlapmL8CqJeacaz0Y+1LI8u605Cz+1t4NklT
	 uT9A9bsf/su5oM0jHvG96IBDK7WbsTJollYU/iV1jUaF/oVQju4Vv3s+jeGiW/VpEzAaH
	 0UAzH2/CppKcmfR0Bu7DU21H7O2itqDR//tj4ahKKDj2G+d8opwY8m95fUmReooLhxQm2
	 CnaJrT9Fzeve20noinVytdsnQ5RwM+vSvl+zs+lATuN1OdZ5tZpPtBL3F8OF053eroRYL
	 IMiofV30bqVUD8gdemUWcqgXWePDHJtaoMC6hRMR6DTSgELMtno5jBH8HaDcyi4UbpA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Mii+wzo2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 0E8E3606A330;
	Thu,  5 Nov 2026 00:53:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Mii+wzo2
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id F16691F00A16;
	Thu,  5 Nov 2026 00:53:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793840003;
	bh=INED4MMgZrZwufn0swCTjWvWb3dcmH2/0DSknrA89G0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Mii+wzo2/rerto/JBSeFPMQndeo0ek3k/cm0U4priwQ5d3HDuhYm+3b3XPeMtYwRh
	 C2zYUwmCCLB66+lg6DBrFlzp3MTGwy7XzNL+w8rM0uQw+m1eiGS/C3YLW+rwPyXdVM
	 WvWIq3FZx8BhstJT4U3hgcLsi7E2vZWbt5SHJN+Wpsp3IwiokcrtNneGQol1ZUH3jP
	 QaAZfYEZE7HAVAbhuXyRU6z6K3HvStJuVfrU126xx5Zdg6q0yKTaeKq4d9nQ+yn/mu
	 OsczNayQosk7VO8ryg08ZiH21v45Xijo5VoVcvbaCZ+mKHqa3yzrhMw/KQFZMU/4B1
	 VhyjXc53/PywA==
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
	samba-technical@lists.samba.org,
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
Subject: [RFC PATCH v3 01/11] KEYS: Add key_gc_flush() for draining RCU callbacks
Date: Thu,  5 Nov 2026 02:53:00 +0200
Message-ID: <20261105005311.804098-2-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261105005311.804098-1-jarkko@kernel.org>
References: <20261105005311.804098-1-jarkko@kernel.org>
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

keyring_clear() and key_invalidate() release keyring links via call_rcu(),
and key_put() defers final key destruction to key_gc_work.

Once keys pin their type, callers that clear an internal cache before
module unload need a synchronous barrier so module references can be
dropped before delete_module() checks the refcount.

Add key_gc_flush() for flushing the remaining key_gc_work passes.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 include/linux/key.h |  2 ++
 security/keys/gc.c  | 11 +++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/key.h b/include/linux/key.h
index 420412aab926..0f408255f740 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -439,6 +439,7 @@ extern int restrict_link_reject(struct key *keyring,
 				struct key *restriction_key);
 
 extern int keyring_clear(struct key *keyring);
+void key_gc_flush(void);
 
 extern key_ref_t keyring_search(key_ref_t keyring,
 				struct key_type *type,
@@ -526,6 +527,7 @@ extern void key_init(void);
 #define key_free_user_ns(ns)		do { } while(0)
 #define key_remove_domain(d)		do { } while(0)
 #define key_lookup(k)			NULL
+#define key_gc_flush()			do { } while (0)
 
 #endif /* CONFIG_KEYS */
 #endif /* __KERNEL__ */
diff --git a/security/keys/gc.c b/security/keys/gc.c
index eda445f815d4..2c3eddc0443a 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -21,6 +21,17 @@ unsigned key_gc_delay = 5 * 60;
 static void key_garbage_collector(struct work_struct *work);
 DECLARE_WORK(key_gc_work, key_garbage_collector);
 
+/**
+ * key_gc_flush - Drain the garbage collector RCU callbacks
+ */
+void key_gc_flush(void)
+{
+	do {
+		rcu_barrier();
+	} while (flush_work(&key_gc_work));
+}
+EXPORT_SYMBOL_GPL(key_gc_flush);
+
 /*
  * Reaper for links from keyrings to dead keys.
  */
-- 
2.47.3

