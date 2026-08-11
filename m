Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 933723546D7;
	Tue, 11 Aug 2026 17:54:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470848; cv=none; b=IiLtm3pEP59DzgGc7JaQAukR2k7LWyjYgycoa3XyPOkXTCAGbd1X3074AN6haePsxxkDeHq4JCM+3KFcvZrXTHjeh/mVSlLIL4YZrM+UoRHTf7w2kCPQf1uyqXbl8G6bXjjPIWkALnq2cMFgE/w1//BbvqvvQQ6BHEAMMcJwWug=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470848; c=relaxed/simple;
	bh=dLmnCMrwGiZmuxsn1+1ltOBeSqEbD7lNdGjE68Bw/IA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=fRBI9tFhcHYrC0zz6uYlzrRc7NdgPwy5we8UxYQXhGRSSx4vbidBxr5WJ8mIMES4RAoJiWycrk7natDYN5v9sCtGHF2DtR1tJAna8TyO1Fl212CJmI+FWJYhs8AiUjqkDNuGO9kVp+iHyRo5699nsN4k3yM+nTSIhDfKUtt/tCY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=CO0Kje71; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=koLw6IQ5; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="CO0Kje71";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="koLw6IQ5"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.stl.internal (Postfix) with ESMTP id 768401300399;
	Tue, 11 Aug 2026 13:54:05 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Tue, 11 Aug 2026 13:54:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470845;
	 x=1786478045; bh=ZpsnlNCccEzAx1VvGs1BtMr3ZszQOnPZ7Dvx24ZVOoQ=; b=
	CO0Kje71ADHAkCmXbnQAZokL+eSWvgwPZWPHmSNOEOVHrTnQpYRqXb1hqK2Uh/r/
	Yd3x7VDfQYmeW35C1EDJN1ovLe9G9sdhLEjE0SMuPLGt7/sOh1Wd8prN4/uu6Lqm
	qha8bFKTOzaB8Xl1n8NkI2GfBXs1RX2UJHbEueS78UVr7xN+39obSLaQs6q0l5Dq
	EANeKWNx1Q4PWyA8udr9f3AfbbuhlciRtcPB1Z8t3mMBdrnykbUwsqViH6leJRVs
	PF3UGXQF48IPvFdkDna56xKJyD6BHZwD6coo+eOmMthRuKaA7WeKH/2uHqZpzrYY
	6UMvpA7pj39GegQSfpmpMQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470845; x=
	1786478045; bh=ZpsnlNCccEzAx1VvGs1BtMr3ZszQOnPZ7Dvx24ZVOoQ=; b=k
	oLw6IQ54IYbzIorzGo/Fm0B2EF48jdeMVhpkER6hAlAzec9z9ubOQ6rRjdPVTFcc
	MubOaAcsdMKqhJkjfR/utkUOiNg+8gEExZHQMDjQa59TqonNX06lcrgg8XkjpTb4
	pnacKb6GoWq2VHJU70pbHR2oEK19mZk2PvSoj5X8jk4vD10oej5X/bb6bWaz3eU3
	YYzcZU9/r753lY6x867A1rWK4WybMP5WuuH9Zoi+DwdxDogx1dBFXyxxTT1hy8/t
	1ZAeV9pkJoYJ/b5bVN0hfT4BQqAFEklAkju521/YsTD7qA1u50yFPH++xKyGKKCp
	PH4kIQZwcW7p8gtl1lzEg==
X-ME-Sender: <xms:vGF7ap-78Cw810gkzWisJUAzuiMpXwBK7ozuqxBLIcNUgARH8MADFg>
    <xme:vGF7amjL_5OwyUN72qGopD0KVc-DCcP7fvdq_mjaprq89Y6hJuefK8C4h8ZDyG0ja
    1ssePlZZb0rQDz871exzHBdmC6Dq_lIEhgJDAojuPSFy14xVWIT>
X-ME-Received: <xmr:vGF7atn4rxipHGchHUmh1LwuQ3ShBMoBsR87w1J2fN-MpT0rYMoCqIa1ap8CFEOM90WFY0lbHShBlJV71bW8rSs>
X-ME-Proxy-Cause: dmFkZTFz4vgNe8oY8QyUL0mlPqEECv57Qi7HCBIaM0H0fEpf1xbY2+8hZG6UpCbiC57xgk
    VavagF0YgIkokz9w1ZYP1FsIKkSgwmPUkWwZZopzEj1hsTumYxogfZ8LsE2lIsmrvQrzxe
    DNsAmjkffjDdnK7Hikwb1PBijPzdc+/pLDsJWa/G9io4Zr2WihJBScLGTtc/AAEph99TK7
    KMYjrfPBzTMOGahPoGoXnc0LQ7Z6pMXIRNlA+PEZw+HSeBor1z9UME1MTUTi3zab2cdg5l
    S2ygLFXboS6erW/oqrZ0wC4vZEyPuJEZAHdMIjRfMGBWirnE5Gt0LHQJATpVfpt20aHeVC
    WVD3qwZKQUbal0U+m98B4JhWUSNaJDclWMKiggs1inMalAO0xRnRH3Oouto/luMbNsCB2k
    eSSMm2vjcQBKUvPCfA9hEqFDdbvDb3quCu37KQrVNZypjOu6fL7cprPZRqICDDKVtkztFU
    yrFIasOIyWnuenf8eW7I1Zps/ju1bW9xOHNoW4ln3/bmbFFIXA1cNSJEjke0FYBk7fwY26
    UXB3NzWKPPR2sQ+sCGiPGl0CFHNyi7yjk0GLrJPi2Yr6boERxx1j+qh0F9fuatJNPph+i3
    qUZDH/7D50/AxoO6XxEpOgSyBH2Tr99IP5LbQWtXdp+AhwI4U5A+5y275YDg
X-ME-Proxy: <xmx:vGF7aq1_jyJ3orlciFCUouprVANRIpGlkWCFcyvQc_aJBo0eKcNFOg>
    <xmx:vGF7an61rf_JljW_69O71GwKPMZx349kMnGhgDw_-ouNaIEVpYCCNQ>
    <xmx:vGF7aohArxPwGkmaLkAm1gbdwtxkaVYdmXSi-SXyVYuUkiwN-ay-HQ>
    <xmx:vGF7aglBoOLkcA3og2op4zVMarAqmM_uURQoA1x32QUsN8vPKT9uIw>
    <xmx:vWF7as3ir_QgDzIGYjVblmX7CRlZmtJIgtJFpPtTacPxRUOwiYwKxR3e>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:53:58 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:52:56 +0200
Subject: [PATCH v2 07/13] security/keys: implement wipe op for big_key
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-7-9561d13c2340@jaseg.de>
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

For keys stored in shmem only the ChaCha20-Poly1305 key is reachable here,
so wiping it is enough to render the payload unreadable.

Used by CONFIG_CRASH_WIPE_SECRETS.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 security/keys/big_key.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/security/keys/big_key.c b/security/keys/big_key.c
index 268f702df380..c01a212bec90 100644
--- a/security/keys/big_key.c
+++ b/security/keys/big_key.c
@@ -8,6 +8,7 @@
 
 #define pr_fmt(fmt) "big_key: "fmt
 #include <linux/init.h>
+#include <linux/crash_core.h>
 #include <linux/seq_file.h>
 #include <linux/file.h>
 #include <linux/shmem_fs.h>
@@ -35,6 +36,8 @@ struct big_key_payload {
  */
 #define BIG_KEY_FILE_THRESHOLD (sizeof(struct inode) + sizeof(struct dentry))
 
+static void big_key_wipe(struct key *key);
+
 /*
  * big_key defined keys take an arbitrary string as the description and an
  * arbitrary blob of data as the payload
@@ -46,6 +49,7 @@ struct key_type key_type_big_key = {
 	.instantiate		= generic_key_instantiate,
 	.revoke			= big_key_revoke,
 	.destroy		= big_key_destroy,
+	.wipe			= big_key_wipe,
 	.describe		= big_key_describe,
 	.read			= big_key_read,
 	.update			= big_key_update,
@@ -279,6 +283,19 @@ long big_key_read(const struct key *key, char *buffer, size_t buflen)
 	return ret;
 }
 
+static void big_key_wipe(struct key *key)
+{
+	struct big_key_payload *payload = to_big_key_payload(key->payload);
+
+	if (payload->data) {
+		if (payload->length > BIG_KEY_FILE_THRESHOLD)
+			crash_wipe_memzero(payload->data,
+					   CHACHA20POLY1305_KEY_SIZE);
+		else
+			crash_wipe_memzero(payload->data, payload->length);
+	}
+}
+
 /*
  * Register key type
  */

-- 
2.53.0

