Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E59A4352022;
	Tue, 11 Aug 2026 17:54:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470900; cv=none; b=SOWOQ/2psOIvwjLURNoGE5tuDNHyiO6LrrvjJBjYCqAVVkifypFUzINbyf58TpywG7tO6HUI0DOqEQLoJ7E0Ea1xiCbmPqKv4jjYXjdtU2+bHvN75Gn7t7uWbhABHcl35nwslbXBo00J/Myjk+AQmAlqf7z/GS3OIF77xypMrtQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470900; c=relaxed/simple;
	bh=T47lbZ/5Ik9XFF2I7gSkXtBswUfH4MhklVGOicIW3mg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=T8F7mpdJ7X1uuAPzu8fNjUZX09aqofBaxgnXTfUPCTJ8zASYksYcDHxo2WlUf+eW0+MaZ0BOOU6UE3TOu0+AhtdSqSX04drHaaIwYo4/05nuxylIXz3O0/tGz0ppOLHKA1GaM0nbrhB6oWoaYIJI0EXmCbOvDSrak4tQKmiI2XQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=VxLE2qEQ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=SSkpNzd/; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="VxLE2qEQ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SSkpNzd/"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.stl.internal (Postfix) with ESMTP id E4B6A13003B7;
	Tue, 11 Aug 2026 13:54:56 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Tue, 11 Aug 2026 13:54:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470896;
	 x=1786478096; bh=VywNlkxt81T21aE3I2g5wIsi8+Y5h/Z8ZTT1u80XjqQ=; b=
	VxLE2qEQb7RhsyFopOdNb1xsSG9C6lDp17xIF/tW5fjKC1h018h/TlWsm/mt1Idn
	ZSK2E16qh46bW4rFguHdnSDeoawg47gLExP576bp6CIE8pmJO1p3VJR4godaM57E
	hegomH+Tm6aRDm7eapdKWDIRCOLutTQUOXkcdoqTQUYkPUlYwNK4AiE2GEjntV8D
	nOZUZE1dsHD7l7B6o6I0E+Z7KOFHSCwfmpbVItkOnDXBlwdg/KI6LFsv1O4fgK8C
	sNIXlyLHP/J1eRm5b34phMIq8G1I046mN12Eh2YjdyHKUEiWE8gOIdkKynoaeOtc
	hry+Xrxf5w8noY46zpYPgQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470896; x=
	1786478096; bh=VywNlkxt81T21aE3I2g5wIsi8+Y5h/Z8ZTT1u80XjqQ=; b=S
	SkpNzd/1QrAjL9XQuiY+AkLt5lhLMYS3fgQngrswG+ix3NYfCF51zDhtGkf9E3it
	EQyT+Rd7EOEwWw0vxrrZ4kZgKv2EaomfwB4Q4IfGJXY5OLdoKREMy6SWMXJE2hkQ
	Gh27Q1huZYbWz0FezXE2ibsfSAkFa8EzFJTwZZvodEhUTI3ayQ1c1LlpFvNjnscD
	eEMLauBLJnWFJ+YEiJrj4V6aLPml0dvZnT68l8/ygPykF6BpcpZvnPx1T3IY0Hx0
	CyS6cPyQrBjHT9LKQGDvcLFnAxB0OmdCrqj6Y7qHTBK/z6ZMRmdQQkdO+AJ8uv2e
	59gY7aIp+7XNH/xQlIfhA==
X-ME-Sender: <xms:8GF7anDtUhMVogtIaF90eVohO54NG6fXU9fcJcr-PVrP6uV-EQMAsQ>
    <xme:8GF7amXHPA-M36SqWIaoOOfC0KAXmAh8RqSljUWbXl5gA-ZdNXp3YnS24rY7uSAPZ
    QzFeSW1aLArq1iVhVcarr_eR9r8_Ng7vq7v3QK5RebjW_stD86P>
X-ME-Received: <xmr:8GF7apKRSA-4AtWEVZN0vEz0zHtt51ctuF2j_4YNkvmM_Ueovh_yp8kgTwn6TBnQO3FEzYRwb1ZL_InFNDWbb1Y>
X-ME-Proxy-Cause: dmFkZTFz4vgNe8oY8QyUL0mlPqEECv57Qi7HCBIaM0H0fEpf1xbY2+8hZG6UpCbiC57xgk
    VavagF0YgIkokz9w1ZYP1FsIKkSgwmPUkWwZZopzEj1hsTumYxogfZ8LsE2lIsmrvQrzxe
    DNsAmjkffjDdnK7Hikwb1PBijPzdc+/pLDsJWa/G9io4Zr2WihJBScLGTtc/AAEph99TK7
    KMYjrfPBzTMOGahPoGoXnc0LQ7Z6pMXIRNlA+PEZw+HSeBor1z9UME1MTUTi3zab2cdg5l
    S2ygLFXboS6erW/oqrZ0wC4vZEyPuJEZAHdMIjRfMGBWirnE5Gt0LHQJATpVfpt20aHeqK
    Vr9NQnZCOXNfk60Be2/UTgwxliwGfCsjAkA0QYgfJNinx6Wwn1xj1scz+ZOK1UcMfrRo3H
    GCXnRzeaKRJs42Gl0t0l71rV4rTv2MuB04VclqcHrLKbriLjI7PchBKyX9kKyt8FtiadHn
    kgkLCoKG8Tq29peNW3i083C3qqLlJiA31CXtZwOLh0hzkw0OD7PaCvxdbvZqcmgF/2MQXw
    ok2S4ZpzbXxDIPa2svuYyCoOyztu/wUpLoiJbWVNlNpLTwmQbxnU0qlYkEMtS1gPXfoUt0
    +shDuurgOLjLUdMZz5xGuS9e2Efp7ZYl0UQf/a+Ej/KDT1ub33VVQNiznkQA
X-ME-Proxy: <xmx:8GF7anK8SnN8j0nsdIirDkp8C-b2cS0dQ1GW_PnwrjuEtqsmXmdx9w>
    <xmx:8GF7al-Tm3NpfKZDQ_6NCnm_aTVZv1oKr_Ao3YmlaNotR-5SdCUNDA>
    <xmx:8GF7alXfus4HujHBcwGz6nBKsHMbDL6OmwQa1ZKeZqSpAmYWSKHCtA>
    <xmx:8GF7alIMOyKbcmgUZaZwY45TO6dUB6_p7zKIiIR4DbwJ7h6hJDPWHQ>
    <xmx:8GF7asdY0A9ZOpiiTn5RpxE8VLjFbOKBq5nTSgG4p52Ol3XlmVKbNOhH>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:54:50 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:53:02 +0200
Subject: [PATCH v2 13/13] dm crypt: wipe key material before kdump
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-13-9561d13c2340@jaseg.de>
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

Wipe volume key/iv copies kept by dm-crypt with
CONFIG_CRASH_WIPE_SECRETS. The backend tfms are already handled
separately.

Add a list tracking struct crypt_config instances when
CONFIG_CRASH_WIPE_SECRETS is set. Structs are tracked here to avoid
having to enumerate them through some roundabout way before kdump, when
we can't safely take locks anymore.

Use custom wipe handlers even for things like ivs that have existing
wipe functions elsewhere because we need to use crash_wipe_memzero
instead of memzero_explicit. The crash_wipe helper memzero_explicit's
the target buffers and flushes data caches. On ARM64, missing that cache
flush could lead to the zeros not being written to DRAM before the kdump
code turns off the data caches moments later.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 drivers/md/dm-crypt.c | 151 ++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 134 insertions(+), 17 deletions(-)

diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 608b617fb817..86adb2f9b94c 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -9,12 +9,14 @@
  */
 
 #include <linux/completion.h>
+#include <linux/crash_core.h>
 #include <linux/err.h>
 #include <linux/module.h>
 #include <linux/hex.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/key.h>
+#include <linux/list.h>
 #include <linux/bio.h>
 #include <linux/blkdev.h>
 #include <linux/blk-integrity.h>
@@ -234,6 +236,11 @@ struct crypt_config {
 	struct mutex bio_alloc_lock;
 
 	u8 *authenc_key; /* space for keys in authenc() format (if used) */
+
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+	struct list_head wipe_list;
+#endif
+
 	u8 key[] __counted_by(key_size);
 };
 
@@ -243,6 +250,12 @@ struct crypt_config {
 
 static DEFINE_SPINLOCK(dm_crypt_clients_lock);
 static unsigned int dm_crypt_clients_n;
+
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+static LIST_HEAD(dm_crypt_wipe_list);
+static DEFINE_SPINLOCK(dm_crypt_wipe_list_lock);
+#endif
+
 static volatile unsigned long dm_crypt_pages_per_client;
 #define DM_CRYPT_MEMORY_PERCENT			2
 #define DM_CRYPT_MIN_PAGES_PER_CLIENT		(BIO_MAX_VECS * 16)
@@ -460,8 +473,7 @@ static void crypt_iv_lmk_dtr(struct crypt_config *cc)
 {
 	struct iv_lmk_private *lmk = &cc->iv_gen_private.lmk;
 
-	kfree_sensitive(lmk->seed);
-	lmk->seed = NULL;
+	kfree_sensitive(xchg(&lmk->seed, NULL));
 }
 
 static int crypt_iv_lmk_ctr(struct crypt_config *cc, struct dm_target *ti,
@@ -582,10 +594,8 @@ static void crypt_iv_tcw_dtr(struct crypt_config *cc)
 {
 	struct iv_tcw_private *tcw = &cc->iv_gen_private.tcw;
 
-	kfree_sensitive(tcw->iv_seed);
-	tcw->iv_seed = NULL;
-	kfree_sensitive(tcw->whitening);
-	tcw->whitening = NULL;
+	kfree_sensitive(xchg(&tcw->iv_seed, NULL));
+	kfree_sensitive(xchg(&tcw->whitening, NULL));
 }
 
 static int crypt_iv_tcw_ctr(struct crypt_config *cc, struct dm_target *ti,
@@ -761,8 +771,7 @@ static void crypt_iv_elephant_dtr(struct crypt_config *cc)
 {
 	struct iv_elephant_private *elephant = &cc->iv_gen_private.elephant;
 
-	kfree_sensitive(elephant->key);
-	elephant->key = NULL;
+	kfree_sensitive(xchg(&elephant->key, NULL));
 }
 
 static int crypt_iv_elephant_ctr(struct crypt_config *cc, struct dm_target *ti,
@@ -2547,8 +2556,7 @@ static int crypt_set_keyring_key(struct crypt_config *cc, const char *key_string
 		goto free_new_key_string;
 
 	set_bit(DM_CRYPT_KEY_VALID, &cc->flags);
-	kfree_sensitive(cc->key_string);
-	cc->key_string = new_key_string;
+	kfree_sensitive(xchg(&cc->key_string, new_key_string));
 	return 0;
 
 free_new_key_string:
@@ -2612,8 +2620,7 @@ static int crypt_set_key(struct crypt_config *cc, char *key)
 	clear_bit(DM_CRYPT_KEY_VALID, &cc->flags);
 
 	/* wipe references to any kernel keyring key */
-	kfree_sensitive(cc->key_string);
-	cc->key_string = NULL;
+	kfree_sensitive(xchg(&cc->key_string, NULL));
 
 	/* Decode key from its hex representation. */
 	if (cc->key_size && hex2bin(cc->key, key, cc->key_size) < 0)
@@ -2641,14 +2648,97 @@ static int crypt_wipe_key(struct crypt_config *cc)
 	if (cc->iv_gen_ops && cc->iv_gen_ops->wipe)
 		cc->iv_gen_ops->wipe(cc);
 
-	kfree_sensitive(cc->key_string);
-	cc->key_string = NULL;
+	kfree_sensitive(xchg(&cc->key_string, NULL));
 	r = crypt_setkey(cc);
 	memset(&cc->key, 0, cc->key_size * sizeof(u8));
 
 	return r;
 }
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+static void crypt_crash_wipe_iv(struct crypt_config *cc)
+{
+	if (cc->iv_gen_ops == &crypt_iv_lmk_ops) {
+		struct iv_lmk_private *lmk = &cc->iv_gen_private.lmk;
+
+		if (lmk->seed)
+			crash_wipe_memzero(lmk->seed, LMK_SEED_SIZE);
+	} else if (cc->iv_gen_ops == &crypt_iv_tcw_ops) {
+		struct iv_tcw_private *tcw = &cc->iv_gen_private.tcw;
+
+		if (tcw->iv_seed)
+			crash_wipe_memzero(tcw->iv_seed, cc->iv_size);
+		if (tcw->whitening)
+			crash_wipe_memzero(tcw->whitening, TCW_WHITENING_SIZE);
+	} else if (cc->iv_gen_ops == &crypt_iv_elephant_ops) {
+		struct iv_elephant_private *elephant =
+			&cc->iv_gen_private.elephant;
+
+		if (elephant->key)
+			crash_wipe_memzero(elephant->key,
+					   sizeof(*elephant->key));
+	}
+}
+
+static int crypt_crash_wipe(struct notifier_block *nb, unsigned long action,
+			    void *data)
+{
+	struct crypt_config *cc;
+
+	/* No locking: all other CPUs are stopped, and a cc is unlinked before
+	 * it is freed, so the forward walk can't reach freed memory.
+	 */
+	list_for_each_entry(cc, &dm_crypt_wipe_list, wipe_list) {
+		crash_wipe_memzero(cc->key, cc->key_size);
+
+		if (cc->authenc_key)
+			crash_wipe_memzero(cc->authenc_key,
+					   crypt_authenckey_size(cc));
+
+		if (cc->key_string)
+			crash_wipe_memzero(cc->key_string,
+					   strlen(cc->key_string));
+
+		crypt_crash_wipe_iv(cc);
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block crypt_crash_wipe_nb = {
+	.notifier_call = crypt_crash_wipe
+};
+
+static void crypt_track_cc(struct crypt_config *cc)
+{
+	spin_lock(&dm_crypt_wipe_list_lock);
+	list_add(&cc->wipe_list, &dm_crypt_wipe_list);
+	spin_unlock(&dm_crypt_wipe_list_lock);
+}
+
+static void crypt_untrack_cc(struct crypt_config *cc)
+{
+	spin_lock(&dm_crypt_wipe_list_lock);
+	list_del(&cc->wipe_list);
+	spin_unlock(&dm_crypt_wipe_list_lock);
+}
+
+static void crypt_crash_wipe_init(void)
+{
+	crash_wipe_secrets_register(&crypt_crash_wipe_nb);
+}
+
+static void crypt_crash_wipe_exit(void)
+{
+	crash_wipe_secrets_unregister(&crypt_crash_wipe_nb);
+}
+#else
+static void crypt_track_cc(struct crypt_config *cc) { }
+static void crypt_untrack_cc(struct crypt_config *cc) { }
+static void crypt_crash_wipe_init(void) { }
+static void crypt_crash_wipe_exit(void) { }
+#endif /* CONFIG_CRASH_WIPE_SECRETS */
+
 static void crypt_calculate_pages_per_client(void)
 {
 	unsigned long pages = (totalram_pages() - totalhigh_pages()) * DM_CRYPT_MEMORY_PERCENT / 100;
@@ -2729,12 +2819,15 @@ static void crypt_dtr(struct dm_target *ti)
 		dm_put_device(ti, cc->dev);
 
 	kfree_sensitive(cc->cipher_string);
-	kfree_sensitive(cc->key_string);
+	kfree_sensitive(xchg(&cc->key_string, NULL));
 	kfree_sensitive(cc->cipher_auth);
-	kfree_sensitive(cc->authenc_key);
+	kfree_sensitive(xchg(&cc->authenc_key, NULL));
 
 	mutex_destroy(&cc->bio_alloc_lock);
 
+	memzero_explicit(cc->key, cc->key_size);
+	crypt_untrack_cc(cc);
+
 	/* Must zero key material before freeing */
 	kfree_sensitive(cc);
 
@@ -3210,6 +3303,8 @@ static int crypt_ctr(struct dm_target *ti, unsigned int argc, char **argv)
 
 	ti->private = cc;
 
+	crypt_track_cc(cc);
+
 	spin_lock(&dm_crypt_clients_lock);
 	dm_crypt_clients_n++;
 	crypt_calculate_pages_per_client();
@@ -3716,7 +3811,29 @@ static struct target_type crypt_target = {
 	.iterate_devices = crypt_iterate_devices,
 	.io_hints = crypt_io_hints,
 };
-module_dm(crypt);
+
+static int __init dm_crypt_init(void)
+{
+	int r;
+
+	crypt_crash_wipe_init();
+
+	r = dm_register_target(&crypt_target);
+	if (r) {
+		crypt_crash_wipe_exit();
+		return r;
+	}
+
+	return 0;
+}
+module_init(dm_crypt_init);
+
+static void __exit dm_crypt_exit(void)
+{
+	crypt_crash_wipe_exit();
+	dm_unregister_target(&crypt_target);
+}
+module_exit(dm_crypt_exit);
 
 MODULE_AUTHOR("Jana Saout <jana@saout.de>");
 MODULE_DESCRIPTION(DM_NAME " target for transparent encryption / decryption");

-- 
2.53.0

