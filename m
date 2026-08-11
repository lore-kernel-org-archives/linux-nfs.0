Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC9603793CE;
	Tue, 11 Aug 2026 17:54:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470892; cv=none; b=N8mV0uEDc7NWJBZaD71n8hWohzri201q/G/MlDXlOJSP5HbUiuE2Nd240b1plJqMzr6dpGdvlO3AhsUu7kN5siU+tCZ8VAJTd0jlTFIinS1UdIutcBs8whbBvwtjnDeUEi+5X/+/tPcB3qcD7Q/kjDLcJXrbC0oKiHOtCJXWtNk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470892; c=relaxed/simple;
	bh=TIZ+okVHrCyUtsr8WbeYKknQaRJKbYF43YJPJkdZtTM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=hMrevhqdAYlzhGr857bJDmY0E2zf3+1vT6vMrP/BigEyPVBLCyTP7QtC5Fgkrg8o+PfLZmvWSyroXc1ROrsWkcr4GxQVVRG7eMweL8A66euqS0FMsA1fKDG0qs19/kPHAg4JgYQiMiGdqT2/7Hj4uga0dIoaWj3sFmDHFGPRuXg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=bYeDYVhg; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=GI03wCRG; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="bYeDYVhg";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="GI03wCRG"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailflow.stl.internal (Postfix) with ESMTP id A131F130038D;
	Tue, 11 Aug 2026 13:54:48 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Tue, 11 Aug 2026 13:54:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470888;
	 x=1786478088; bh=jFYKhNM35RpDRZh/43hulCmfEJyGilMf3A0rl4qWOVM=; b=
	bYeDYVhgtPE017gK8myw81IgEJUTe3W99CDML8CpqHp7fU6iAnzN86+mOx7pU8Z/
	Xz25faE9dCrff2JgEY85A8il0GldVKWSWgOy4hiTb9CwSrAu1UA8ybprakhSKiLG
	oIITSW+Nrjy2Sq/XXAbDUY1ZyI6YiBMXr9Yk2a9seCS5IMaaJ7N61dHXvoUtlz8j
	3p4rf5eJtJC2ubYbpyEbWFEarW2qhkEHelWMe2AjTl6Xz3oyvWcBgxSp9m5mz04M
	PiZPAArXKeBHB+U1EAtjh1PXTUxgcDuNYNeEWLP/jcovinleNGmuNB3spTKuDtdC
	x6aphUNJ+Y8113Z0XSyupg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470888; x=
	1786478088; bh=jFYKhNM35RpDRZh/43hulCmfEJyGilMf3A0rl4qWOVM=; b=G
	I03wCRG7sUINfnlJx1HoFrWP/Blr/bsvRmMMtdVhY+z8ikl856vyYKiKSfxJk7TJ
	+Du+2B8fdmMwoashdCtrBOjKrt7zkIVhzPJwU97BFtkm9yeBnyEW9wLTOSe9RXan
	IF1LrphRdo4Uk3avywoso/2ZA+IcNlIwlF46V0biEWeEsORBdaR7O6+Kzp+FqjId
	by1N2tuNRk4YQ/cm2z2zowmmSbKc+xqSKdOTtViGytJI12Acn61UHhiLYE0YFZ+l
	o+fCUXptxoEXuPVdfPm34ZKvgqE/lbkjRsqBea+Ym0d7dKpsuXfQrUtlDEY+S3wi
	JfrtqmZ9utgGiPwezfe5A==
X-ME-Sender: <xms:6GF7ak2aeI67ME2whQjDRFEFUSap2dHoqV5gaRqdIpQaKczG27_ffg>
    <xme:6GF7alrOHZkIbt809LfaVJrW_HTu4cTVBGd32Dlfo2aA52FhJgt1HcVDGGXEZ53Pd
    ie9ejQQf-9bWsIntw6gRpVKcWOLFyyIJofloeBpzpVC4wR9gPSNBA>
X-ME-Received: <xmr:6GF7appNETAxMOIJoMSSYEXVLzHtyEW4fHehW-qDFB4UzD9f0PJdzjffpHYSEDkJg7_lcX-JIFlYipUTyCzV-xQ>
X-ME-Proxy-Cause: dmFkZTFP5tmiXRyqpvhao8uWnDWsuVG58E3QcpY8nNF+TN3d4+2z3XaWQJ1+2uEKcUq9Jg
    +xH/KDfBOi31TfxVE5vy2aZ5W5Eono+bvv7mBiiNvVW/C9tjIvrxCLzv7Tz6GJOSvAG1cd
    t11+FzpQNbill+yp1ZC7JKPVzEaxQ4CH2HewKTU1gYEn0mNFldMXWgoBvZ/c5OhwLZogLW
    sZeOMCUfQY9vOvCjGHA0ivpYn+5HBy3sK6RswFREIaUm9jlhbU7pV5ZXGDLpJAMlUAJ/Lo
    y1vjaaTNNEiBF07QqH8YbZg0fsVTsE2lSAku2XiqZRlB3GAWdGnDFC/NxQNHJZjZwh0bMi
    3ropPtGEXwJYJAu285XzhREMMjarFs0U0qMD7zjrDHqt6fJ8xSO2sk61ZxfqGLG5LEahc7
    vwAk5zUO0ZCCm9fM+L422IUoCWwqFOjz+0aNT0kFyZ0Q1Ln5ckpifI68KSJbkT7he4JGsz
    gnYBtMLYaheT0cogeUK3622EJ3Z+e4Ukbofzl4+gPfWHBkTRbmKjtE6P4Ot7qNxDbkBV9f
    6r8fT1r6KlUCPnqErm914p+GFvLXJ9n92U6RxanpRYnFHvVP6n6k2ggCnlgrXR6Uub55UK
    uDCtbwOviWOwgtdaHKlTAzhxVcXj+aqh2aNk2mWVG/8eK7aDZGpVw69gy5wQ
X-ME-Proxy: <xmx:6GF7amdRcbsx2qfRi8Cd7iqirsDyMVXLbbc0EFhgE-YV-qN-A-n8YA>
    <xmx:6GF7ar3414zMwqGprCZiQmHYu9pyMRwm63XrVoSErX6qc-cgchR1Pg>
    <xmx:6GF7appNUtXCAZ3BPwO2kwj0wrqDcwnqsypWPF3DoBa2ZTNBOw4Q1w>
    <xmx:6GF7aiW3O4vSZ6P4QnlVVOEiR378mmPRjHDcwpHayiuZTg9-sqozcg>
    <xmx:6GF7aq85EqVYPI90O7QDsJHYjnOV5PSwDC15fyrxlypXGHf1F3HESgUy>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:54:41 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:53:01 +0200
Subject: [PATCH v2 12/13] crypto: api - wipe tfm contexts before kdump
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-12-9561d13c2340@jaseg.de>
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

tfm structs contain key material like expanded key schedules. Under
CONFIG_CRASH_WIPE_SECRETS, wipe all tfms before kdump to prevent
leakage. Copies outside the tfm context, e.g. on the stack or in
hardware key registers, are not covered.

Also change two kfree() calls to kfree_sensitive() for good measure.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 crypto/api.c           | 78 ++++++++++++++++++++++++++++++++++++++++++++------
 include/linux/crypto.h | 11 +++++++
 2 files changed, 81 insertions(+), 8 deletions(-)

diff --git a/crypto/api.c b/crypto/api.c
index 24227582cfcf..f919f52e8b5f 100644
--- a/crypto/api.c
+++ b/crypto/api.c
@@ -10,13 +10,16 @@
  * and Nettle, by Niels Möller.
  */
 
+#include <linux/crash_core.h>
 #include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/jump_label.h>
 #include <linux/kernel.h>
 #include <linux/kmod.h>
 #include <linux/module.h>
+#include <linux/notifier.h>
 #include <linux/param.h>
+#include <linux/rculist.h>
 #include <linux/sched/signal.h>
 #include <linux/slab.h>
 #include <linux/string.h>
@@ -397,6 +400,60 @@ static unsigned int crypto_ctxsize(struct crypto_alg *alg, u32 type, u32 mask)
 	return len;
 }
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+/*
+ * tfm allocations are tracked on crypto_tfm_list so that they can be wiped
+ * before kdump.
+ */
+static HLIST_HEAD(crypto_tfm_list);
+static DEFINE_SPINLOCK(crypto_tfm_list_lock);
+
+static int crypto_crash_wipe(struct notifier_block *nb, unsigned long action,
+		void *data)
+{
+	struct crypto_tfm *tfm;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tfm, &crypto_tfm_list, wipe_list)
+		crash_wipe_memzero(tfm->__crt_ctx, tfm->wipe_size);
+	rcu_read_unlock();
+
+	/* off to kexec()! */
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block crypto_wipe_nb = {
+	.notifier_call = crypto_crash_wipe
+};
+
+static int __init crypto_tfm_track_init(void)
+{
+	crash_wipe_secrets_register(&crypto_wipe_nb);
+	return 0;
+}
+core_initcall(crypto_tfm_track_init);
+
+/* @size is the size of __crt_ctx */
+static void crypto_track_tfm(struct crypto_tfm *tfm, size_t size)
+{
+	tfm->wipe_size = size;
+
+	spin_lock(&crypto_tfm_list_lock);
+	hlist_add_head_rcu(&tfm->wipe_list, &crypto_tfm_list);
+	spin_unlock(&crypto_tfm_list_lock);
+}
+
+static void crypto_untrack_tfm(struct crypto_tfm *tfm)
+{
+	spin_lock(&crypto_tfm_list_lock);
+	hlist_del_rcu(&tfm->wipe_list);
+	spin_unlock(&crypto_tfm_list_lock);
+}
+#else
+static void crypto_track_tfm(struct crypto_tfm *tfm, size_t size) { }
+static void crypto_untrack_tfm(struct crypto_tfm *tfm) { }
+#endif /* CONFIG_CRASH_WIPE_SECRETS */
+
 void crypto_shoot_alg(struct crypto_alg *alg)
 {
 	down_write(&crypto_alg_sem);
@@ -409,15 +466,16 @@ struct crypto_tfm *__crypto_alloc_tfm(struct crypto_alg *alg, u32 type,
 				      u32 mask)
 {
 	struct crypto_tfm *tfm;
-	unsigned int tfm_size;
+	unsigned int ctx_size;
 	int err = -ENOMEM;
 
-	tfm_size = sizeof(*tfm) + crypto_ctxsize(alg, type, mask);
-	tfm = kzalloc(tfm_size, GFP_KERNEL);
+	ctx_size = crypto_ctxsize(alg, type, mask);
+	tfm = kzalloc(sizeof(*tfm) + ctx_size, GFP_KERNEL);
 	if (tfm == NULL)
 		goto out_err;
 
 	tfm->__crt_alg = alg;
+	crypto_track_tfm(tfm, ctx_size);
 
 	if (!tfm->exit && alg->cra_init && (err = alg->cra_init(tfm)))
 		goto cra_init_failed;
@@ -428,7 +486,8 @@ struct crypto_tfm *__crypto_alloc_tfm(struct crypto_alg *alg, u32 type,
 	crypto_exit_ops(tfm);
 	if (err == -EAGAIN)
 		crypto_shoot_alg(alg);
-	kfree(tfm);
+	crypto_untrack_tfm(tfm);
+	kfree_sensitive(tfm);
 out_err:
 	tfm = ERR_PTR(err);
 out:
@@ -497,12 +556,12 @@ void *crypto_create_tfm_node(struct crypto_alg *alg,
 			     int node)
 {
 	struct crypto_tfm *tfm;
-	size_t size;
 	char *mem;
 	int err;
+	size_t ctx_size = frontend->extsize(alg);
 
-	size = frontend->tfmsize + sizeof(*tfm) + frontend->extsize(alg);
-	mem = kzalloc_node(size, GFP_KERNEL, node);
+	mem = kzalloc_node(frontend->tfmsize + sizeof(*tfm) + ctx_size,
+			GFP_KERNEL, node);
 	if (!mem)
 		return ERR_PTR(-ENOMEM);
 
@@ -510,6 +569,7 @@ void *crypto_create_tfm_node(struct crypto_alg *alg,
 	tfm->__crt_alg = alg;
 	tfm->node = node;
 	tfm->fb = tfm;
+	crypto_track_tfm(tfm, ctx_size);
 
 	err = frontend->init_tfm(tfm);
 	if (err)
@@ -525,7 +585,8 @@ void *crypto_create_tfm_node(struct crypto_alg *alg,
 out_free_tfm:
 	if (err == -EAGAIN)
 		crypto_shoot_alg(alg);
-	kfree(mem);
+	crypto_untrack_tfm(tfm);
+	kfree_sensitive(mem);
 	mem = ERR_PTR(err);
 out:
 	return mem;
@@ -627,6 +688,7 @@ void crypto_destroy_tfm(void *mem, struct crypto_tfm *tfm)
 		alg->cra_exit(tfm);
 	crypto_exit_ops(tfm);
 	crypto_mod_put(alg);
+	crypto_untrack_tfm(tfm);
 	kfree_sensitive(mem);
 }
 EXPORT_SYMBOL_GPL(crypto_destroy_tfm);
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index b7c97f1c47c9..59d6d62180fd 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -14,6 +14,7 @@
 
 #include <linux/completion.h>
 #include <linux/errno.h>
+#include <linux/list.h>
 #include <linux/refcount_types.h>
 #include <linux/slab.h>
 #include <linux/types.h>
@@ -420,6 +421,16 @@ struct crypto_tfm {
 
 	struct crypto_alg *__crt_alg;
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+	/*
+	 * Link on crypto_tfm_list, used to wipe the expanded key schedule in
+	 * __crt_ctx before kdump. wipe_size covers __crt_ctx only, excluding
+	 * this struct and any frontend preceding it.
+	 */
+	struct hlist_node wipe_list;
+	size_t wipe_size;
+#endif
+
 	void *__crt_ctx[] CRYPTO_MINALIGN_ATTR;
 };
 

-- 
2.53.0

