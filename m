Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 583C035C6B5;
	Tue, 11 Aug 2026 17:54:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470883; cv=none; b=AQ+0JbmwtpEbGOj2OWTlKjHwk3ELz/OPZBDWyQB/3Q3J7klbWNN6jeYgiQPBf4NscH1MIvBh98vqjSNHcLVQw3h9oF4shUKAxL5VtNLx8O755RBB0B5ZT6xDQGOTOWRzdsfbpZxBkgZFnQzVF44U4DghOFJ5RHhFV8AGLCFyb/s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470883; c=relaxed/simple;
	bh=C8uzopovspx+jzCgMd++lGEt0kWPN90/8kmHq0MlVWw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gq4UuupX7OnQ6nFYgZGSosWBdoE4myC6cODVEaI229f6uuq4UO32zhCDJ0R7oild6ekixZUdZDMRZcjyIAYXeHU7kZ0WOkfID3HStHFItzjQX5hpBIv8YdV0DjyT2nbkfjseYPhZVf6fDsPlFg3jJYBt2ppJKRBsiq2OLtk5HMg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=JwupcXb6; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=X1drl2a8; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="JwupcXb6";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="X1drl2a8"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.stl.internal (Postfix) with ESMTP id 27DAA13003B1;
	Tue, 11 Aug 2026 13:54:40 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Tue, 11 Aug 2026 13:54:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470880;
	 x=1786478080; bh=qRdj1vbz8p2iExAmHiccg0/3QeT/qpwETqEzoy9C6Gk=; b=
	JwupcXb6vzWjnE7B6o+zL2gfG8BHxyuMrxqZ62dPDH1rPf9NqIyWAOdDMXPMJ7qc
	/RpVi/cf9Tx8gTrJ+7e59DMK1p9rrWA47VdDD0S5wkuEvM4Yh9sl12Pqoi5lY27+
	vR//UyiTXobTrATjv1eJUKqK8rv5CmyWHMOTcNY5Kx9AvFxvjFWM1stEsB/jA73N
	05DfmzbDI70gFHOCvdJZD72aAXGj/cMwYLSuqMq+je5ynyLzdtc4Q5UZlzwkkQUm
	z7iqkMQsLvWGq4KBFOHDTr8IIZIpWEHgX6l8Ngk7dJnFXIT16yx3h3Dun3DHNXoO
	Z7PZXrEr+y8/ZAr1tZynsA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470880; x=
	1786478080; bh=qRdj1vbz8p2iExAmHiccg0/3QeT/qpwETqEzoy9C6Gk=; b=X
	1drl2a8xrd4tktJc08EFNz+Yca5f7KtFC6GwPc2bc+Lv5Wzmg38PqCBQl84MnNuo
	yvA+LGUypfTn8JR8yEFt7GGriz0XrlSCMpRn5jblIi42eemOQ2oR6GvcOtE/B7dt
	Qwn1vALD2p6dLbAwcuF3eqoqwP/U8l+lYJlYmjp9UG4K12TiptH0WkfTRlJgHqiU
	KSed7ev1ENdboNP3czU79Db0QE+aPI9QsohNfATxcdRrzJ+ct3MGgGV80WFKyoUK
	it2GgGSa32FYm+gd86u2RNNxKbo/n48hyUPTVqPOKe6kjBQE25Wp3AigNeeRlSJB
	mkqSOR9aKdZhqEFlwXLxg==
X-ME-Sender: <xms:32F7aiEDlfyYwvJ4fIlLVeCXfGY5rpNo9OOmex0UCUctlJ9HWE0Gcw>
    <xme:32F7alWQsdwwFmkxKbKigMpiJ1KAgjlgD4q2g-OB7W5aXfsjujEoi26jI2Ugt6Fm8
    dSpHOGYlU3QG7OT-odJ_kjXFPK0hPjvQN-F7tyyW2XqDBqRq5nJ>
X-ME-Received: <xmr:32F7aga9BeaDmKTezgYLR3u-cjakFsz9BmF3s_ZmRF5Zw8mczLWt3IU7vSkM6ohMYNDf5rPMj5sPCZzTe_1j-1M>
X-ME-Proxy-Cause: dmFkZTFCz0Ji0ZFixqgSD/OqUUF4WVuqQyEz0ee6kaomlH2rCyU90DaPXp9i3px2Lq+46e
    zZlpuku5qPti3Gv38qfq9xHPmHStFaNGWUmW+rS5ek9JmDGNNRsgxagXJtF9Le+4XfImj6
    mvMRPguD+8olj0InbNxmoLdJWN0NXIY/BV8bJGOsCN5DcFzTXrQNXDLJ5EPLOl/eJIbITE
    fuecBbgsXxiwgqmdOe8RK2G3tEPcBtYf6l6zHVsw1qVGswhc+c+1u5vXrkKBY9NmW4VKq8
    bvVbENKoHBjwphNqlCAPHx41cLq72VIcTLcaeIhNcr+RTNY3yub1H3GKyFpQQN9DEaiInz
    G8kwhPzX4fKDKFMJHiDdv476bp0EU4pCQHsrnAjj4PK9JHfApNpmBNBOd9/d2BE2ctMGwe
    QfR6GBtnKVoAg6eRj7FywHBVVRfXjhUSDkbMlT+8u84dCMPccPUkd9ZEmGHvVX/v1wZ9Zh
    RipOHWMdXpVMKkC1X+4O/fxjbhxCIsI+e6+caIbc7yG1lgcjZOCA6bDY975/SJMasWJr/B
    h5v0sK4TQfJ/XV25PeuAXylmTVnWaZxZhJ6BKDSTc2DV7dRtbFyS38lagxkb6hL1jbQvcJ
    EO2BPT+v/huL8aZtyS8/X9QTZRBrSife8dNDrDCwQaamKL1jBZqLUpKNHn9Q
X-ME-Proxy: <xmx:32F7anClTh-NuVh0LI8PE0qsIqb2jMsBiWDjmcFlz1YtpN71AIVU3g>
    <xmx:32F7atGnBkBv-bGYSid9U1vQ1J-TQhXqLqkHJuo6XUs2_i_howEJdw>
    <xmx:32F7apCKx993xY6lD6VgqOysqBaATsrib5PLFLle7_F496DosaRMCA>
    <xmx:32F7apUt_6x_R0MyaPtbEW7TsF-WM0ujJjptx7YVJRwSN4tCEnuraw>
    <xmx:4GF7akIhIfcPFmxVvU9ar7SBsnx0_zEm9tlL9B6C1-G2-WiKi4GGxlPb>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:54:33 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:53:00 +0200
Subject: [PATCH v2 11/13] fscrypt: wipe master keys before kdump
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-11-9561d13c2340@jaseg.de>
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

fscrypt master keys hang off the superblock rather than a keyring of their
own key type, so register a separate notifier that walks the live
superblocks via the new super_blocks_crash_wipe() helper.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 fs/crypto/block.c           | 10 +++++++
 fs/crypto/fscrypt_private.h | 15 ++++++++++
 fs/crypto/keyring.c         | 68 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/crypto/keysetup_v1.c     | 15 ++++++++++
 fs/super.c                  | 29 +++++++++++++++++++
 include/linux/fs.h          |  4 +++
 6 files changed, 140 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/block.c b/fs/crypto/block.c
index 5193f8ba3ee0..a2fa1469b3c4 100644
--- a/fs/crypto/block.c
+++ b/fs/crypto/block.c
@@ -15,6 +15,7 @@
 
 #include <linux/blk-crypto.h>
 #include <linux/blkdev.h>
+#include <linux/crash_core.h>
 #include <linux/export.h>
 #include <linux/sched/mm.h>
 #include <linux/slab.h>
@@ -144,6 +145,15 @@ int fscrypt_prepare_inline_crypt_key(struct fscrypt_prepared_key *prep_key,
 	return err;
 }
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+void fscrypt_crash_wipe_inline_crypt_key(struct fscrypt_prepared_key *prep_key)
+{
+	if (prep_key->blk_key)
+		crash_wipe_memzero(prep_key->blk_key->bytes,
+				   sizeof(prep_key->blk_key->bytes));
+}
+#endif /* CONFIG_CRASH_WIPE_SECRETS */
+
 void fscrypt_destroy_inline_crypt_key(struct super_block *sb,
 				      struct fscrypt_prepared_key *prep_key)
 {
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 74329e0953d1..95cb50e5cbcd 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -413,6 +413,10 @@ int fscrypt_prepare_inline_crypt_key(struct fscrypt_prepared_key *prep_key,
 void fscrypt_destroy_inline_crypt_key(struct super_block *sb,
 				      struct fscrypt_prepared_key *prep_key);
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS /* && CONFIG_FS_ENCRYPTION_INLINE_CRYPT */
+void fscrypt_crash_wipe_inline_crypt_key(struct fscrypt_prepared_key *prep_key);
+#endif
+
 int fscrypt_derive_sw_secret(struct super_block *sb,
 			     const u8 *wrapped_key, size_t wrapped_key_size,
 			     u8 sw_secret[BLK_CRYPTO_SW_SECRET_SIZE]);
@@ -454,6 +458,13 @@ fscrypt_destroy_inline_crypt_key(struct super_block *sb,
 {
 }
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS /* && !CONFIG_FS_ENCRYPTION_INLINE_CRYPT */
+static inline void
+fscrypt_crash_wipe_inline_crypt_key(struct fscrypt_prepared_key *prep_key)
+{
+}
+#endif
+
 static inline int
 fscrypt_derive_sw_secret(struct super_block *sb,
 			 const u8 *wrapped_key, size_t wrapped_key_size,
@@ -760,6 +771,10 @@ static inline int fscrypt_require_key(struct inode *inode)
 
 void fscrypt_put_direct_key(struct fscrypt_direct_key *dk);
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+void fscrypt_crash_wipe_direct_keys(void);
+#endif
+
 int fscrypt_setup_v1_file_key(struct fscrypt_inode_info *ci,
 			      const u8 *raw_master_key);
 
diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 76e28d1e0064..5ac302146eb2 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -19,6 +19,7 @@
  */
 
 #include <crypto/skcipher.h>
+#include <linux/crash_core.h>
 #include <linux/export.h>
 #include <linux/key-type.h>
 #include <linux/once.h>
@@ -239,8 +240,9 @@ void fscrypt_destroy_keyring(struct super_block *sb)
 			fscrypt_initiate_key_removal(sb, mk);
 		}
 	}
+	/* Stop panic-time walkers from finding @keyring before it is freed. */
+	smp_store_release(&sb->s_master_keys, NULL);
 	kfree_sensitive(keyring);
-	sb->s_master_keys = NULL;
 }
 
 static struct hlist_head *
@@ -640,6 +642,13 @@ static void fscrypt_provisioning_key_destroy(struct key *key)
 	kfree_sensitive(key->payload.data[0]);
 }
 
+/* wipe the key without freeing. used by CONFIG_CRASH_WIPE_SECRETS. */
+static void fscrypt_provisioning_key_wipe(struct key *key)
+{
+	if (key->payload.data[0])
+		crash_wipe_memzero(key->payload.data[0], key->datalen);
+}
+
 static struct key_type key_type_fscrypt_provisioning = {
 	.name			= "fscrypt-provisioning",
 	.preparse		= fscrypt_provisioning_key_preparse,
@@ -647,6 +656,7 @@ static struct key_type key_type_fscrypt_provisioning = {
 	.instantiate		= generic_key_instantiate,
 	.describe		= fscrypt_provisioning_key_describe,
 	.destroy		= fscrypt_provisioning_key_destroy,
+	.wipe			= fscrypt_provisioning_key_wipe,
 };
 
 /*
@@ -1220,6 +1230,58 @@ int fscrypt_ioctl_get_key_status(struct file *filp, void __user *uarg)
 }
 EXPORT_SYMBOL_GPL(fscrypt_ioctl_get_key_status);
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+/*
+ * Wipe the master keys of one superblock.  The master keys don't live on a
+ * keyring of their own key_type, so the keyrings core can't reach them.
+ */
+static void fscrypt_crash_wipe_sb(struct super_block *sb)
+{
+	struct fscrypt_keyring *keyring = sb->s_master_keys;
+	size_t i;
+
+	if (!keyring)
+		return;
+
+	for (i = 0; i < ARRAY_SIZE(keyring->key_hashtable); i++) {
+		struct fscrypt_master_key *mk;
+
+		hlist_for_each_entry(mk, &keyring->key_hashtable[i], mk_node) {
+			struct fscrypt_inode_info *ci;
+			struct fscrypt_mode_key *node;
+
+			crash_wipe_memzero(&mk->mk_secret,
+					   sizeof(mk->mk_secret));
+
+			list_for_each_entry(node, &mk->mk_mode_keys, link)
+				fscrypt_crash_wipe_inline_crypt_key(&node->key);
+
+			list_for_each_entry(ci, &mk->mk_decrypted_inodes,
+					    ci_master_key_link)
+				fscrypt_crash_wipe_inline_crypt_key(&ci->ci_enc_key);
+		}
+	}
+}
+
+/* Called far into vpanic from crash_core.c with other CPUs stopped and
+ * preemption disabled
+ */
+static int fscrypt_crash_wipe(struct notifier_block *nb, unsigned long action,
+			      void *data)
+{
+	if (!super_blocks_crash_wipe(fscrypt_crash_wipe_sb))
+		pr_crit("crash_wipe_secrets: can't acquire sb_lock. skipping fscrypt keys.\n");
+
+	fscrypt_crash_wipe_direct_keys();
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block fscrypt_crash_wipe_nb = {
+	.notifier_call = fscrypt_crash_wipe
+};
+#endif /* CONFIG_CRASH_WIPE_SECRETS */
+
 void __init fscrypt_init_keyring(void)
 {
 	int err;
@@ -1235,4 +1297,8 @@ void __init fscrypt_init_keyring(void)
 	if (err)
 		panic("failed to register fscrypt-provisioning key type (%d)",
 		      err);
+
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+	crash_wipe_secrets_register(&fscrypt_crash_wipe_nb);
+#endif
 }
diff --git a/fs/crypto/keysetup_v1.c b/fs/crypto/keysetup_v1.c
index 87fe13ccb253..08dd0a682a8f 100644
--- a/fs/crypto/keysetup_v1.c
+++ b/fs/crypto/keysetup_v1.c
@@ -23,6 +23,7 @@
 #include <crypto/aes.h>
 #include <crypto/utils.h>
 #include <keys/user-type.h>
+#include <linux/crash_core.h>
 #include <linux/hashtable.h>
 
 #include "fscrypt_private.h"
@@ -118,6 +119,20 @@ void fscrypt_put_direct_key(struct fscrypt_direct_key *dk)
 	free_direct_key(dk);
 }
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+void fscrypt_crash_wipe_direct_keys(void)
+{
+	struct fscrypt_direct_key *dk;
+	unsigned int i;
+
+	/* No locking: all other CPUs are stopped, so nothing can race with us. */
+	hash_for_each(fscrypt_direct_keys, i, dk, dk_node) {
+		crash_wipe_memzero(dk->dk_raw, sizeof(dk->dk_raw));
+		fscrypt_crash_wipe_inline_crypt_key(&dk->dk_key);
+	}
+}
+#endif /* CONFIG_CRASH_WIPE_SECRETS */
+
 /*
  * Find/insert the given key into the fscrypt_direct_keys table.  If found, it
  * is returned with elevated refcount, and 'to_insert' is freed if non-NULL.  If
diff --git a/fs/super.c b/fs/super.c
index 5feecf5d9038..cd51e9cfe93b 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -2463,3 +2463,32 @@ int sb_init_dio_done_wq(struct super_block *sb)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(sb_init_dio_done_wq);
+
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+/**
+ * super_blocks_crash_wipe - run @wipe against every live superblock
+ * @wipe: callback to invoke for each superblock
+ *
+ * Called from the panic path with other CPUs stopped and preemption disabled.
+ * The callback must not sleep, allocate, free or take locks.
+ *
+ * Returns false without doing anything if @sb_lock could not be acquired, in
+ * which case the list may be inconsistent and walking it is unsafe.
+ */
+bool super_blocks_crash_wipe(void (*wipe)(struct super_block *sb))
+{
+	struct super_block *sb;
+
+	/* There is no point in waiting for a lock that will never be released
+	 * at this stage.
+	 */
+	if (!spin_trylock(&sb_lock))
+		return false;
+
+	list_for_each_entry(sb, &super_blocks, s_list)
+		wipe(sb);
+
+	spin_unlock(&sb_lock);
+	return true;
+}
+#endif
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 072d8cd09a0b..7832a77908d2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2378,6 +2378,10 @@ extern __printf(2, 3)
 int super_setup_bdi_name(struct super_block *sb, char *fmt, ...);
 extern int super_setup_bdi(struct super_block *sb);
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+bool super_blocks_crash_wipe(void (*wipe)(struct super_block *sb));
+#endif
+
 static inline void super_set_uuid(struct super_block *sb, const u8 *uuid, unsigned len)
 {
 	if (WARN_ON(len > sizeof(sb->s_uuid)))

-- 
2.53.0

