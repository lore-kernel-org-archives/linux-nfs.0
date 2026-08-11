Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E059835B65D;
	Tue, 11 Aug 2026 17:54:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470866; cv=none; b=mMrbum3KONV23epK3IjyO/l8bFKMFDjFpOJbrqJ0/i20lJ5mFlgc6794VzW48TM80yMXP/jnjFaysr3VpOYSpcf8VEuSByr6O4eaSTnAPzn+Fk25KxbtI3D9R+tnW2zu1s4AfGTFtvNVU7aDpsYL8u5Ce6HYBc62SsptyCsG79g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470866; c=relaxed/simple;
	bh=pFhp6xnik0wvtR0KY8MWR4dOyalbUlDaPKD/cfIHUmA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=W6u41UyEdDqPxvG7+HzQU8M7IE5oXKWkg87EzNWaX2W6chbZkGr4DOQ9PbAfxtpD1Sd9WthL5X20x7BsPfxDQtVrel0EznAmIqaG2PxSPQZAx4wcLAIYi4+bqae8V4NXhMsXctZyCU5XclObQvomo/5VTDnCbzmIUbBeJjUD1DQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=qB2Jy7vX; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=TRxBuSxw; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="qB2Jy7vX";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="TRxBuSxw"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailflow.stl.internal (Postfix) with ESMTP id C358513003A6;
	Tue, 11 Aug 2026 13:54:22 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Tue, 11 Aug 2026 13:54:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470862;
	 x=1786478062; bh=6GTy/7ZYnhxwkN3CoOvmK6vIIxg2qB1mjCGqyHajM1A=; b=
	qB2Jy7vX5C5g7HFTE11w3KW7iFGS08Hi2Z6fdKdbd+NH+vR4665E+YY32z+VrqHW
	e8VqhnOhmjyMa+NhOcxYaLSFJm4O2aPGvq4PP0flRu/uCP3GXTHNw4uZQN9Jdn5m
	iDDZ/byDI9F+wTQibuac57c6zH2r3wPapyRCaq71th2vwXrzwW1kJwv4/K+v10Xc
	S/HsLRiVsm96zzjZc3hnudlFMXt4fH2Ygh4Y6AoAzx9jJsK9iJAN2YUhK9QqJCvd
	mQzgHE16IfdSAAeBDmYhEdflm5INZlpdetbk6F4+XseJ8OSLrgHIidqZ7Tvl6149
	gZM82j6UrZMR4gFcY37t3g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470862; x=
	1786478062; bh=6GTy/7ZYnhxwkN3CoOvmK6vIIxg2qB1mjCGqyHajM1A=; b=T
	RxBuSxw+xYevsT25Hc1JPuxXZqY/uEsl8wSxfZhf/AnKlFUhLhxDA6OAGexc/MPq
	yo4PqNgNydIVClSZ3ANQkB+z3UkR32qE7fBDOKJlV2ywY71eXlLfNkDQmBS75Caw
	Gb5aPaFEYzA/RZqFwZZ7kP8Mj31loYQbhJfKe9D7873Xr2U0jy0m6K9ka6JILxIb
	npR/zyq+eq6XNbfqaIWlAGkJucqyPYs4Y1Uw/X4bU1kkyrXwCZ0N8BcWdYyVXSI1
	1/D5iiCrk0Ijt8TBdbCTi30INqZ8bShadFPJ4WPiTgAbfc52SukdVu0W4GMsCW+L
	n5fdbrFiJ8s2Rm29o5wZw==
X-ME-Sender: <xms:zmF7ai_Zs1u6hV2jKxhqrcmi2g4fPeq5mYeMVGalh6VRy0_rEPJ8SQ>
    <xme:zmF7arjBYupbF0QtI3fQ6K3iDO3yXS_DD6X8uY5PNvKM_DZM7Oov2AUNLqc_vJb1_
    XoRSZQyoiHQyvs0SSqbEnE7I9j2_yxhLuaETEs0R4seyWWRT0a__A>
X-ME-Received: <xmr:zmF7aum43js_e2C7xRDlq-oNYfs2k3-LQyC7IMVMZzVMq_cQuDUY0kKQzQa0JnTQlIDv1EMq5DCMC4U1awBhRHg>
X-ME-Proxy-Cause: dmFkZTFz4vgNe8oY8QyUL0mlPqEECv57Qi7HCBIaM0H0fEpf1xbY2+8hZG6UpCbiC57xgk
    VavagF0YgIkokz9w1ZYP1FsIKkSgwmPUkWwZZopzEj1hsTumYxogfZ8LsE2lIsmrvQrzxe
    DNsAmjkffjDdnK7Hikwb1PBijPzdc+/pLDsJWa/G9io4Zr2WihJBScLGTtc/AAEph99TK7
    KMYjrfPBzTMOGahPoGoXnc0LQ7Z6pMXIRNlA+PEZw+HSeBor1z9UME1MTUTi3zab2cdg5l
    S2ygLFXboS6erW/oqrZ0wC4vZEyPuJEZAHdMIjRfMGBWirnE5Gt0LHQJATpVfpt20aHeDl
    XyB37WkgHmCL0bqV/gwYjrSWwACRVv3L2mFYMT6Mo8TeRqIhBfn+EZ+AprPeNbPdQGricJ
    fO7wnskH9wB1YuqUpy/Yx4yIVrnrUMhSspS5ClTRyNPxGziAfpZ/o6pFI/pcdBeJrhWtVd
    c/IPXtIPiAGqw8VslzaK5j2qHpjEI9MJdVRoNbyWuxPSNIqfN/6kAbwCFumcLChonGTjyx
    H616czHqhxUWbir/Tq/u5KYre5BpB9QBmnbWNbZpMwYCQH7GlGObbgqRwGUDDtBN3ktFC5
    fRYyjzm6ZZWpXmztHWaeJ2+3hyK7XjHM2TIVurBh/oB9ziDN7H8PBTB/+KCw
X-ME-Proxy: <xmx:zmF7an2mxQxYibZJ0Vc8f-12U_TtbV1qjsbmxtvBc36oNvgma10L0w>
    <xmx:zmF7ag4cW4egXWZhGkNKj4xWcwr0Qvhl0CDNsmZy2blqSXy7nPYpwA>
    <xmx:zmF7athLaQ8JhBVZx4QUPOKI1_ZDgp0jQdH1181gcQnl8eeGhA0XBg>
    <xmx:zmF7ahnywASeh6bXo1Y-9SkkriNPy8-KxFnJsTQ0daM8WYvknajE1Q>
    <xmx:zmF7al3sbciruhHrY45Vzi7-LbLTUplldIvu9zOXsR3LZrVj5NfYvtVK>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:54:15 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:52:58 +0200
Subject: [PATCH v2 09/13] security/keys: implement wipe op for asymmetric
 keys
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-9-9561d13c2340@jaseg.de>
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

Add wipe op to the subtype and implement it for public_key.

Used by CONFIG_CRASH_WIPE_SECRETS.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 crypto/asymmetric_keys/asymmetric_type.c | 11 +++++++++++
 crypto/asymmetric_keys/public_key.c      | 15 +++++++++++++++
 include/keys/asymmetric-subtype.h        |  5 +++++
 3 files changed, 31 insertions(+)

diff --git a/crypto/asymmetric_keys/asymmetric_type.c b/crypto/asymmetric_keys/asymmetric_type.c
index 16a7ae16593c..a0a68ebd0746 100644
--- a/crypto/asymmetric_keys/asymmetric_type.c
+++ b/crypto/asymmetric_keys/asymmetric_type.c
@@ -481,6 +481,16 @@ static void asymmetric_key_destroy(struct key *key)
 	asymmetric_key_free_kids(kids);
 }
 
+/* wipe the key without freeing. used by CONFIG_CRASH_WIPE_SECRETS. */
+static void asymmetric_key_wipe(struct key *key)
+{
+	struct asymmetric_key_subtype *subtype = asymmetric_key_subtype(key);
+
+	if (subtype && subtype->wipe)
+		subtype->wipe(key->payload.data[asym_crypto],
+				key->payload.data[asym_auth]);
+}
+
 static struct key_restriction *asymmetric_restriction_alloc(
 	key_restrict_link_func_t check,
 	struct key *key)
@@ -612,6 +622,7 @@ struct key_type key_type_asymmetric = {
 	.match_preparse		= asymmetric_key_match_preparse,
 	.match_free		= asymmetric_key_match_free,
 	.destroy		= asymmetric_key_destroy,
+	.wipe			= asymmetric_key_wipe,
 	.describe		= asymmetric_key_describe,
 	.lookup_restriction	= asymmetric_lookup_restriction,
 	.asym_query		= query_asymmetric_key,
diff --git a/crypto/asymmetric_keys/public_key.c b/crypto/asymmetric_keys/public_key.c
index 09a0b83d5d77..9931d56337e5 100644
--- a/crypto/asymmetric_keys/public_key.c
+++ b/crypto/asymmetric_keys/public_key.c
@@ -13,6 +13,7 @@
 #include <crypto/sig.h>
 #include <keys/asymmetric-subtype.h>
 #include <linux/asn1.h>
+#include <linux/crash_core.h>
 #include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -58,6 +59,19 @@ static void public_key_destroy(void *payload0, void *payload3)
 	public_key_signature_free(payload3);
 }
 
+/* wipe the key without freeing. used by CONFIG_CRASH_WIPE_SECRETS. */
+static void public_key_wipe(void *payload0, void *payload3)
+{
+	struct public_key *key = payload0;
+
+	if (key) {
+		if (key->key)
+			crash_wipe_memzero(key->key, key->keylen);
+		if (key->params)
+			crash_wipe_memzero(key->params, key->paramlen);
+	}
+}
+
 /*
  * Given a public_key, and an encoding and hash_algo to be used for signing
  * and/or verification with that key, determine the name of the corresponding
@@ -464,6 +478,7 @@ struct asymmetric_key_subtype public_key_subtype = {
 	.name_len		= sizeof("public_key") - 1,
 	.describe		= public_key_describe,
 	.destroy		= public_key_destroy,
+	.wipe			= public_key_wipe,
 	.query			= software_key_query,
 	.eds_op			= software_key_eds_op,
 	.verify_signature	= public_key_verify_signature_2,
diff --git a/include/keys/asymmetric-subtype.h b/include/keys/asymmetric-subtype.h
index d55171f640a0..17c74070c101 100644
--- a/include/keys/asymmetric-subtype.h
+++ b/include/keys/asymmetric-subtype.h
@@ -32,6 +32,11 @@ struct asymmetric_key_subtype {
 	/* Destroy a key of this subtype */
 	void (*destroy)(void *payload_crypto, void *payload_auth);
 
+	/* Wipe a key of this subtype without freeing it (optional).  Used by
+	 * CONFIG_CRASH_WIPE_SECRETS from the panic path.
+	 */
+	void (*wipe)(void *payload_crypto, void *payload_auth);
+
 	int (*query)(const struct kernel_pkey_params *params,
 		     struct kernel_pkey_query *info);
 

-- 
2.53.0

