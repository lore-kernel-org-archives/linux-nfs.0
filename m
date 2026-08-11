Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5248363C46;
	Tue, 11 Aug 2026 17:54:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470875; cv=none; b=hLXn2OqajOaPKsrktYKs6M8/gnaqgksaNABUj7JWPM8zJKLAZNhvNgOOD4NTpIsBwli0u2dJext8omeBbcr5iaelM1ryQ18Tqc3Lp52A+AKvDTfm5EglbsePAzXW3yssq9EXLP0PBDTQrtl3At6M+IgmmK+GJmKmPIoK+0PpYjg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470875; c=relaxed/simple;
	bh=jsjzOPXRhYaJq2rSEgIsrW20GZctQWh42g/kY4t0bCk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=PuAPVZhTGgLkI3stTkJqfOOknMdx+tNtyJqIonUUExiVDRMRjuEcze0A2PQ6c6WO6IuMzQJirKbA9mQNDDzMMC/bql2eToXSJFfYyq7i6UqpL5QYCDW/vfMa4SnhtAQhYJd+u+vTocqtBJqg00MfLzym6HcgCK0GuqW5fFtXT7k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=hU63RqXY; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=SPD0YyzA; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="hU63RqXY";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SPD0YyzA"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.stl.internal (Postfix) with ESMTP id D650813003AD;
	Tue, 11 Aug 2026 13:54:31 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Tue, 11 Aug 2026 13:54:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470871;
	 x=1786478071; bh=xAM3Q/HBwmz4JVRL14+ds0PYCfNcU1k9FDcBLO4TEyw=; b=
	hU63RqXYUX7dR3ti5JXHaOPEYLzV7fuN96eKtn8RUYFDvNMfAYH+xRYP8mUkO4Vr
	bJAoEHBb4WkzdXQvxKfgNUa5V+iOXoY/WDKSx8UvHrDz8Nvv9CpbktshEpZwp9RC
	TZ6Okhcxu45Mnblk92hN99ie9UvB6eAUgbIx8f71QKwTCsMRHIjgcAa53XGzZ3OE
	z9D56yxEAng2g2B1NWyGEONfMAkTrinvBSTCVnlO0LER9KqdHu/GXWSRhGrxtRaW
	dUU1BpVP67ufQHSXd4Wfwi8Mk2FtbOwNW1uVZmZR1PfwEHthRYgnK7oZLMBWdXXa
	kQ+X/QJXfM/soI1Ayn6E4A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470871; x=
	1786478071; bh=xAM3Q/HBwmz4JVRL14+ds0PYCfNcU1k9FDcBLO4TEyw=; b=S
	PD0YyzAO3i0iPOSceA/VwD8y9HsrVhqBs81kDs44awp1UE25tBjzrQIjJ2X3hLIp
	UqqsAD4FTBx4AaFBTdOq8UEOPJK2yCc8SKAHcfgUaHW7mjP5lRNMPN24kgBxQ3tD
	pPlnFEKMSiWn1BanUYpHRtsoRaCaGU9eEc3H8tqDCtIPzeCzRk0qdxln/phxzvYH
	1o0rhSNQPxowCccqdfuoj00u3AmmTD9WCN1qNEhSNY3SZl4u8IAUgJd/cDOuVH0g
	1Wryg4mVjyqjY1NgzXhFwnbdF+O6PvwO6EPpKgayWnnl9hrWSUMXBA7wCjoExGY3
	szwyCbvR2yQaY36T81Leg==
X-ME-Sender: <xms:12F7auKHQfrqWZVMa9ODtgV7DOIB9GWd8oQzsULgrnNYN7xiwtdGew>
    <xme:12F7au_1rv4vqQYKlz3p2iIwRPOSVf7FE9DFYTwOLTcRrNXFmASwAYPtHHMnUSErA
    2YO7nPSNYqhi_vBEr_2iDK1GDq0PRUKFh6k3tEGwG0qG1Z4fvXNFw>
X-ME-Received: <xmr:12F7alRe7itEE3naI48j9z3YSoRaaA9GcJyx6ETVwlHrT1e1AOm0rYAlUfPYOq3tIyi8Wkyue-Ohmurl0GbO8VM>
X-ME-Proxy-Cause: dmFkZTFGa2nY7jnTk2Iw9v4bB0J0yF1ICaJd32/qXm98Bvn0uDADx+C3Kw/Flk6iixyPGu
    72/phBwy47Kg8FJyFrGdC++k215U13L/0xFYZCpTa0z/w1NtK5dvlR08GndYlyZFvTP5gF
    Dlk263KcILQ417hZPN5ksrl0Nvpbmk/SlilTO3h+HTntssEQr1ld/ICv8lLA9/v6l7Z51B
    Ox2NlVVO9b906SW9ppu7yHcQtehxM0oDmo9WAr6dDp967nPaXzwEavIcDXzrIMh6NogcTT
    QJsGa7BorA3mOK9lmdQq3QUA5wm6ullbc5aPHMSxvblIqqAHtDNqCX4Ur6Kq6Hz6embcdc
    vYdRVb13nBNQZMEFR3UDwQKUUNDw/OfDBUUzUeypFz90S2GfV8DZBApkiCuQjPmksk3nWc
    wCsKwOoVmEb4wZSE3HdwY+yNaBF/rm6bOSeuJtLdyT3FY6SAATvIkCdjNh2rdNEkIi+AwH
    s1tX9R58abOkm3pxLdRrMBhxKEKfqdzDrrDOcup8QPmcON/iMcAk8BZWNh9KftZnP6dqXp
    AX30EG1VB3mNP30/5c6IurQTvxF/NyGreDSbmjc+cGCYdq2ypAFzLTKOGh2gE9QHdT/XOF
    4Qyzi+DQRPh2c/zeEebScgmFshMBa9nAjTvnIyZqJn5W80oSWHo8Yc23MYpw
X-ME-Proxy: <xmx:12F7agw3sZqacIIp1XWtBuyhH5uhSkxY5F2qOLVKE1NiUoOA2akNtg>
    <xmx:12F7avEiXN5Nj66bL5Va-K8JasSRGRn0dxVDl3K_ChPQViATU6U51A>
    <xmx:12F7an8sTTo81NNrev7hlmg4qazhhN3Ty75VuPYofsR20GmNn3VMbg>
    <xmx:12F7ajSjke9279DpulhV-A_ITXIM6r21C4cQeDBQwQRhvPzz_L32WQ>
    <xmx:12F7arWmntqMmainny0jjaMu2_j-7GTbEeB5nJqzF9oKJTBsfCHSTosB>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:54:24 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:52:59 +0200
Subject: [PATCH v2 10/13] rxrpc: implement wipe op for rxrpc keys
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-10-9561d13c2340@jaseg.de>
References: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>
In-Reply-To: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>
To: Andrew Morton <akpm@linux-foundation.org>,
  Baoquan He <baoquan.he@linux.dev>, Mike Rapoport <rppt@kernel.org>,
  Pasha Tatashin <pasha.tatashin@soleen.com>,
  Pratyush Yadav <pratyush@kernel.org>,
 Dave Young <ruirui.yang@linux.dev>,
  Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will@kernel.org>,  David Howells <dhowells@redhat.com>,
 Jarkko Sakkinen <jarkko@kernel.org>,  Jonathan Corbet <corbet@lwn.net>,
 Shuah Khan <skhan@linuxfoundation.org>,
  Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>,
  "Serge E. Hallyn" <serge@hallyn.com>, Lukas Wunner <lukas@wunner.de>,
  Ignat Korchagin <ignat@linux.win>,
 Herbert Xu <herbert@gondor.apana.org.au>,
  "David S. Miller" <davem@davemloft.net>,
 Keith Busch <kbusch@kernel.org>,  Jens Axboe <axboe@kernel.dk>,
 Christoph Hellwig <hch@lst.de>,  Sagi Grimberg <sagi@grimberg.me>,
 Trond Myklebust <trondmy@kernel.org>,  Anna Schumaker <anna@kernel.org>,
 Mimi Zohar <zohar@linux.ibm.com>,
  James Bottomley <James.Bottomley@HansenPartnership.com>,
  Marc Dionne <marc.dionne@auristor.com>,
 Eric Dumazet <edumazet@google.com>,  Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>,  Simon Horman <horms@kernel.org>,
 Eric Biggers <ebiggers@kernel.org>,  "Theodore Y. Ts'o" <tytso@mit.edu>,
 Jaegeuk Kim <jaegeuk@kernel.org>,
  Alexander Viro <viro@zeniv.linux.org.uk>,
  Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
  Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@kernel.org>,
  Mikulas Patocka <mpatocka@redhat.com>,
  Benjamin Marzinski <bmarzins@redhat.com>
Cc: kexec@lists.infradead.org, linux-kernel@vger.kernel.org, 
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
 keyrings@vger.kernel.org, linux-doc@vger.kernel.org, 
 linux-security-module@vger.kernel.org, linux-crypto@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org, 
 linux-integrity@vger.kernel.org, linux-afs@lists.infradead.org, 
 netdev@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org, dm-devel@lists.linux.dev, 
 =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
X-Mailer: b4 0.15.2

Wipe session keys and tickets of client key tokens, and add a server key
wipe op implemented by rxkad and rxgk.

Used by CONFIG_CRASH_WIPE_SECRETS.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 net/rxrpc/ar-internal.h |  5 +++++
 net/rxrpc/key.c         | 34 ++++++++++++++++++++++++++++++++++
 net/rxrpc/rxgk.c        | 11 +++++++++++
 net/rxrpc/rxkad.c       | 14 ++++++++++++++
 net/rxrpc/server_key.c  | 11 +++++++++++
 5 files changed, 75 insertions(+)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 865f05fe37ab..6466eb5a9929 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -282,6 +282,11 @@ struct rxrpc_security {
 	/* Destroy the payload of a server key */
 	void (*destroy_server_key)(struct key *);
 
+	/* Wipe the payload of a server key without freeing it.  Used by
+	 * CONFIG_CRASH_WIPE_SECRETS from the panic path.
+	 */
+	void (*wipe_server_key)(struct key *);
+
 	/* Describe a server key */
 	void (*describe_server_key)(const struct key *, struct seq_file *);
 
diff --git a/net/rxrpc/key.c b/net/rxrpc/key.c
index a0aa78d89289..e612b7a8df13 100644
--- a/net/rxrpc/key.c
+++ b/net/rxrpc/key.c
@@ -11,6 +11,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
+#include <linux/crash_core.h>
 #include <linux/net.h>
 #include <linux/overflow.h>
 #include <linux/skbuff.h>
@@ -26,6 +27,7 @@
 static int rxrpc_preparse(struct key_preparsed_payload *);
 static void rxrpc_free_preparse(struct key_preparsed_payload *);
 static void rxrpc_destroy(struct key *);
+static void rxrpc_wipe(struct key *);
 static void rxrpc_describe(const struct key *, struct seq_file *);
 static long rxrpc_read(const struct key *, char *, size_t);
 
@@ -40,6 +42,7 @@ struct key_type key_type_rxrpc = {
 	.free_preparse	= rxrpc_free_preparse,
 	.instantiate	= generic_key_instantiate,
 	.destroy	= rxrpc_destroy,
+	.wipe		= rxrpc_wipe,
 	.describe	= rxrpc_describe,
 	.read		= rxrpc_read,
 };
@@ -570,6 +573,31 @@ static void rxrpc_free_token_list(struct rxrpc_key_token *token)
 	}
 }
 
+static void rxrpc_wipe_token_list(struct rxrpc_key_token *token)
+{
+	struct rxrpc_key_token *next;
+
+	for (; token; token = next) {
+		next = token->next;
+		switch (token->security_index) {
+		case RXRPC_SECURITY_RXKAD:
+			crash_wipe_memzero(token->kad->session_key,
+					   sizeof(token->kad->session_key));
+			crash_wipe_memzero(token->kad->ticket,
+					   token->kad->ticket_len);
+			break;
+		case RXRPC_SECURITY_YFS_RXGK:
+			crash_wipe_memzero(token->rxgk->key.data,
+					   token->rxgk->key.len);
+			crash_wipe_memzero(token->rxgk->ticket.data,
+					   token->rxgk->ticket.len);
+			break;
+		default:
+			break;
+		}
+	}
+}
+
 /*
  * Clean up preparse data.
  */
@@ -586,6 +614,12 @@ static void rxrpc_destroy(struct key *key)
 	rxrpc_free_token_list(key->payload.data[0]);
 }
 
+/* wipe the key without freeing. used by CONFIG_CRASH_WIPE_SECRETS. */
+static void rxrpc_wipe(struct key *key)
+{
+	rxrpc_wipe_token_list(key->payload.data[0]);
+}
+
 /*
  * describe the rxrpc key
  */
diff --git a/net/rxrpc/rxgk.c b/net/rxrpc/rxgk.c
index 77a67ace1d24..51c428fb3a60 100644
--- a/net/rxrpc/rxgk.c
+++ b/net/rxrpc/rxgk.c
@@ -8,6 +8,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/net.h>
+#include <linux/crash_core.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/key-type.h>
@@ -68,6 +69,15 @@ static void rxgk_destroy_server_key(struct key *key)
 	rxgk_free_server_key(&key->payload);
 }
 
+/* wipe the key without freeing. used by CONFIG_CRASH_WIPE_SECRETS. */
+static void rxgk_wipe_server_key(struct key *key)
+{
+	struct krb5_buffer *server_key = (void *)&key->payload.data[2];
+
+	if (server_key->data)
+		crash_wipe_memzero(server_key->data, server_key->len);
+}
+
 static void rxgk_describe_server_key(const struct key *key, struct seq_file *m)
 {
 	const struct krb5_enctype *krb5 = key->payload.data[0];
@@ -1338,6 +1348,7 @@ const struct rxrpc_security rxgk_yfs = {
 	.preparse_server_key		= rxgk_preparse_server_key,
 	.free_preparse_server_key	= rxgk_free_preparse_server_key,
 	.destroy_server_key		= rxgk_destroy_server_key,
+	.wipe_server_key		= rxgk_wipe_server_key,
 	.describe_server_key		= rxgk_describe_server_key,
 	.init_connection_security	= rxgk_init_connection_security,
 	.alloc_txbuf			= rxgk_alloc_txbuf,
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index ca9f0e82cb9a..054ab67aca32 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -10,6 +10,7 @@
 #include <crypto/des.h>
 #include <kunit/visibility.h>
 #include <linux/export.h>
+#include <linux/crash_core.h>
 #include <linux/fips.h>
 #include <linux/module.h>
 #include <linux/net.h>
@@ -91,6 +92,18 @@ static void rxkad_destroy_server_key(struct key *key)
 	key->payload.data[0] = NULL;
 }
 
+/* wipe the key without freeing. used by CONFIG_CRASH_WIPE_SECRETS. */
+static void rxkad_wipe_server_key(struct key *key)
+{
+	struct des_ctx *des_key = key->payload.data[0];
+
+	if (des_key)
+		crash_wipe_memzero(des_key, sizeof(*des_key));
+
+	/* the raw 8-byte key is kept inline in the payload union */
+	crash_wipe_memzero(&key->payload.data[2], 8);
+}
+
 /*
  * initialise connection security
  */
@@ -1127,6 +1140,7 @@ const struct rxrpc_security rxkad = {
 	.preparse_server_key		= rxkad_preparse_server_key,
 	.free_preparse_server_key	= rxkad_free_preparse_server_key,
 	.destroy_server_key		= rxkad_destroy_server_key,
+	.wipe_server_key		= rxkad_wipe_server_key,
 	.init_connection_security	= rxkad_init_connection_security,
 	.alloc_txbuf			= rxkad_alloc_txbuf,
 	.secure_packet			= rxkad_secure_packet,
diff --git a/net/rxrpc/server_key.c b/net/rxrpc/server_key.c
index 3efe104b1930..a8e736d58793 100644
--- a/net/rxrpc/server_key.c
+++ b/net/rxrpc/server_key.c
@@ -26,6 +26,7 @@ static int rxrpc_vet_description_s(const char *);
 static int rxrpc_preparse_s(struct key_preparsed_payload *);
 static void rxrpc_free_preparse_s(struct key_preparsed_payload *);
 static void rxrpc_destroy_s(struct key *);
+static void rxrpc_wipe_s(struct key *);
 static void rxrpc_describe_s(const struct key *, struct seq_file *);
 
 /*
@@ -40,6 +41,7 @@ struct key_type key_type_rxrpc_s = {
 	.free_preparse	= rxrpc_free_preparse_s,
 	.instantiate	= generic_key_instantiate,
 	.destroy	= rxrpc_destroy_s,
+	.wipe		= rxrpc_wipe_s,
 	.describe	= rxrpc_describe_s,
 };
 
@@ -105,6 +107,15 @@ static void rxrpc_destroy_s(struct key *key)
 		sec->destroy_server_key(key);
 }
 
+/* wipe the key without freeing. used by CONFIG_CRASH_WIPE_SECRETS. */
+static void rxrpc_wipe_s(struct key *key)
+{
+	const struct rxrpc_security *sec = key->payload.data[1];
+
+	if (sec && sec->wipe_server_key)
+		sec->wipe_server_key(key);
+}
+
 static void rxrpc_describe_s(const struct key *key, struct seq_file *m)
 {
 	const struct rxrpc_security *sec = key->payload.data[1];

-- 
2.53.0

