Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21C883546DC;
	Tue, 11 Aug 2026 17:53:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470840; cv=none; b=Q4bnIjFPJKNeR7LTLKiix/JbUacKoDFPlbPV5zSjxL0h0JABtU4VPo5XcuUiXhgrDaiGPexlX+os6eDOQWd50vYvp6DgZJQY2FYFSAAu2TcdaR0evtcHo2Di04veCnK1DPcz+71ocnFe/WAL7xd4v+M2jx60bZMuodsir5p4DLo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470840; c=relaxed/simple;
	bh=+WO5tcXU5gpFFK/RhD6QSfAv9Wy2LNZra39n6oSqBJE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Cq6WuRUEvBhGsiQB/m+dk31RspyJm8Z++hJeB4LVvL8F7Z1s9bagikXqUGcadaKM+W25cj68VrOU2d/LBK3hgwwvES306oI4hH+sMY1hAxZ6Pk1JCPvl2OeeZkMUUAneUXqfNepFN/6CEmtFPXu2b+m49X/nM+tjELOnPbojn3M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=CZJ+DP1c; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Yto8vG2b; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="CZJ+DP1c";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Yto8vG2b"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailflow.stl.internal (Postfix) with ESMTP id 0645A1300397;
	Tue, 11 Aug 2026 13:53:57 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Tue, 11 Aug 2026 13:53:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470836;
	 x=1786478036; bh=3JSH/iI45wy3MD9zA4sQib4hD7ZbkdXLzpNiNtsaJcE=; b=
	CZJ+DP1ctATAeRR/KJYvTUIM3t8q9GDjhKCZJvatoQooWR6rVWNSly772PQ/TfUy
	ENUwOmU25bKc8x8iO+5/ZiNSoxDpy65ZsBKcuwerOM0xJtAMRQlKbIA2r4+K7cpo
	4bjjS9E5oRvoOp38MPHnL+07j7CKJyZfjvfarLFn9unjoYWs69bl7jCUKKr8Ndsa
	JTNOUd8st5x+6dnD+tzTK+EJVuqdzDYdM5RKFtGLtt2fo6MdxoDxsQEmWWm+1h5h
	9r0ieubu+uMTq53Onf1eIiRRGrIEDqzqRf1iGgAN3ZRTwO/3zZolwRXxQuwQVsSO
	JLp/WAXW/e6HViLutxDuDA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470836; x=
	1786478036; bh=3JSH/iI45wy3MD9zA4sQib4hD7ZbkdXLzpNiNtsaJcE=; b=Y
	to8vG2bwv0UUn+XNWPlW4HltiAZMSeXAls7xJHf405to9maLImvQ9bJiV7xuBJPt
	xUIZWEgivpvjAZ/1QdoIo+b9/FKpN+LOU/6eXGlSokf48mJSnxOdoAhuJl9haavG
	p1QQ0O5H31ulz2f1KK09UhIo4WQbcFU/ccZ7Ax2MFwad5tcauqP8cfc3flFLwxGe
	Y75oecP+XNv5iwLqvldxhGrdvSZiAdo1RNEgog64rZDGoXYdeDr3/Tn4wnsVZDlr
	v5P57anNA1u+0/KQAx/G2WWflCk6nIRdXxiG9tYHoiaBV0XQv8Cuv39dxLYqb4Hf
	eNT7F4OO6XotcScVosu+Q==
X-ME-Sender: <xms:tGF7aiJKno3z67rxtm3MwFWmSr1qq3YuYzcqq6y63Z8oTuM-n8nhVw>
    <xme:tGF7ak8Hu_jhjkU4e82Xz7I9J6AizYJgLpYww1XpLix4ozUrHA2hHKre4tCCegENF
    JKguZ2uOe7Yz-h17ITstcjZNXyrafTMgUbUcfzPTjfN-QuWyVja_w>
X-ME-Received: <xmr:tGF7aoXciMDUTi6hA0_x7ZQsNOwlQ4EtBC8NLT6gl4HIwkC-AsF3-PTrFq6F3Ak_1-9hb2fTU-q8NQzKzWR_o4Q>
X-ME-Proxy-Cause: dmFkZTFP5tmiXRyqpvhao8uWnDWsuVG58E3QcpY8nNF+TN3d4+2z3XaWQJ1+2uEKcUq9Jg
    +xH/KDfBOi31TfxVE5vy2aZ5W5Eono+bvv7mBiiNvVW/C9tjIvrxCLzv7Tz6GJOSvAG1cd
    t11+FzpQNbill+yp1ZC7JKPVzEaxQ4CH2HewKTU1gYEn0mNFldMXWgoBvZ/c5OhwLZogLW
    sZeOMCUfQY9vOvCjGHA0ivpYn+5HBy3sK6RswFREIaUm9jlhbU7pV5ZXGDLpJAMlUAJ/Lo
    y1vjaaTNNEiBF07QqH8YbZg0fsVTsE2lSAku2XiqZRlB3GAWdGnDFC/NxQNHJZjZwh0bM3
    cLQaepUv4mccOXTYHSJClVmCRVjSn+gHGZSrZSr9AIOtFX696ePpwSJ3GivOeqzsZkLmTk
    yyYQq6X2LYjRyPVZRsKI2XFbuaBY59zZqLm0Ubjaf2Up6v/CUhpiejbTg9OndalmiNo1NB
    TgyZExpcvXKCRncIx0T/h5V17Yq+BBkt1Lp9C6cm0M6/7WFjIX6uj79fa7WzCqocBHAItx
    lYJGO4yn0BYCEOUjuH4msbchVi4ZaVb/zXzuqFPnUz6EFLEG1rjqsToNrsNvdQ0zdS7Ksc
    iAXcKrD3AR2kiGeCuPM2c70LXnp+ct6Uu0ATWnPyvkCwQAMtKo2ec5wQGj0w
X-ME-Proxy: <xmx:tGF7asL5qDC481n5yJUehDCZHwRaJL4UwVQrDFm98jQ0hiVJMLyalw>
    <xmx:tGF7ai30rrImeq9T90IIpB94BB1urAX1qiXxvs9BhUZjke5_4nNXEA>
    <xmx:tGF7am4zJuXzY0djzripvWMbDrNrupcdCQQZTxKukPDBk7oCLv2Crg>
    <xmx:tGF7aqDX5cdfqklMb2Ex7760XSkgmpeDBXmZI4o_6ZxqlfsL1Bb5ug>
    <xmx:tGF7aroe6voaYG2F9rSNjt3fN3R27pPqoKVo5MIMqwC34HAnQgRdkqhC>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:53:50 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:52:55 +0200
Subject: [PATCH v2 06/13] security/keys: implement wipe op for user-type
 keys
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-6-9561d13c2340@jaseg.de>
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

Wipe the payload of "user" and "logon" keys, and of the key types reusing
the user-type ops: s390 cert_store, NVMe TLS PSK, NFS idmap and PKCS#7.

Used by CONFIG_CRASH_WIPE_SECRETS.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 crypto/asymmetric_keys/pkcs7_key_type.c |  1 +
 drivers/nvme/common/keyring.c           |  1 +
 fs/nfs/nfs4idmap.c                      |  2 ++
 include/keys/user-type.h                |  1 +
 security/keys/user_defined.c            | 15 +++++++++++++++
 5 files changed, 20 insertions(+)

diff --git a/crypto/asymmetric_keys/pkcs7_key_type.c b/crypto/asymmetric_keys/pkcs7_key_type.c
index b930d3bbf1af..663a246742f7 100644
--- a/crypto/asymmetric_keys/pkcs7_key_type.c
+++ b/crypto/asymmetric_keys/pkcs7_key_type.c
@@ -74,6 +74,7 @@ static struct key_type key_type_pkcs7 = {
 	.instantiate		= generic_key_instantiate,
 	.revoke			= user_revoke,
 	.destroy		= user_destroy,
+	.wipe			= user_wipe,
 	.describe		= user_describe,
 	.read			= user_read,
 };
diff --git a/drivers/nvme/common/keyring.c b/drivers/nvme/common/keyring.c
index 32d16c53133b..33303f035fb1 100644
--- a/drivers/nvme/common/keyring.c
+++ b/drivers/nvme/common/keyring.c
@@ -84,6 +84,7 @@ static struct key_type nvme_tls_psk_key_type = {
 	.instantiate    = generic_key_instantiate,
 	.revoke         = user_revoke,
 	.destroy        = user_destroy,
+	.wipe		= user_wipe,
 	.describe       = nvme_tls_psk_describe,
 	.read           = user_read,
 };
diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index bc397110d977..26f579ae2c73 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -190,6 +190,7 @@ static struct key_type key_type_id_resolver = {
 	.instantiate	= generic_key_instantiate,
 	.revoke		= user_revoke,
 	.destroy	= user_destroy,
+	.wipe		= user_wipe,
 	.describe	= user_describe,
 	.read		= user_read,
 };
@@ -412,6 +413,7 @@ static struct key_type key_type_id_resolver_legacy = {
 	.instantiate	= generic_key_instantiate,
 	.revoke		= user_revoke,
 	.destroy	= user_destroy,
+	.wipe		= user_wipe,
 	.describe	= user_describe,
 	.read		= user_read,
 	.request_key	= nfs_idmap_legacy_upcall,
diff --git a/include/keys/user-type.h b/include/keys/user-type.h
index 386c31432789..685fa054b0ac 100644
--- a/include/keys/user-type.h
+++ b/include/keys/user-type.h
@@ -40,6 +40,7 @@ extern void user_free_preparse(struct key_preparsed_payload *prep);
 extern int user_update(struct key *key, struct key_preparsed_payload *prep);
 extern void user_revoke(struct key *key);
 extern void user_destroy(struct key *key);
+extern void user_wipe(struct key *key);
 extern void user_describe(const struct key *user, struct seq_file *m);
 extern long user_read(const struct key *key, char *buffer, size_t buflen);
 
diff --git a/security/keys/user_defined.c b/security/keys/user_defined.c
index 6f88b507f927..f4897c19c2dd 100644
--- a/security/keys/user_defined.c
+++ b/security/keys/user_defined.c
@@ -6,6 +6,7 @@
  */
 
 #include <linux/export.h>
+#include <linux/crash_core.h>
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/seq_file.h>
@@ -28,6 +29,7 @@ struct key_type key_type_user = {
 	.update			= user_update,
 	.revoke			= user_revoke,
 	.destroy		= user_destroy,
+	.wipe			= user_wipe,
 	.describe		= user_describe,
 	.read			= user_read,
 };
@@ -48,6 +50,7 @@ struct key_type key_type_logon = {
 	.update			= user_update,
 	.revoke			= user_revoke,
 	.destroy		= user_destroy,
+	.wipe			= user_wipe,
 	.describe		= user_describe,
 	.vet_description	= logon_vet_description,
 };
@@ -152,6 +155,18 @@ void user_destroy(struct key *key)
 
 EXPORT_SYMBOL_GPL(user_destroy);
 
+void user_wipe(struct key *key)
+{
+	struct user_key_payload *upayload = key->payload.data[0];
+
+	if (upayload)
+		crash_wipe_memzero(upayload->data, upayload->datalen);
+	key->payload.data[1] = NULL;
+	key->payload.data[2] = NULL;
+	key->payload.data[3] = NULL;
+}
+EXPORT_SYMBOL_GPL(user_wipe);
+
 /*
  * describe the user key
  */

-- 
2.53.0

