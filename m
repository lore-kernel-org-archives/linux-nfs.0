Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9CFA3546D9;
	Tue, 11 Aug 2026 17:53:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470833; cv=none; b=OE/HUw+46wb9PQU9GcJLOj9aULgw+iJCXFgVSQiMLoLY3kG6vyIUhcCLyl4eqLc6mYB1n4ka85KpbNjNDXAlnB7kIL7ccTMCY1J9PPA+nyMbCmBUIf+cGQliPMoWW4VY38FgEEEbN9nKKQbwN3F6xwnz1EDxGbzNoslE0ptZSs8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470833; c=relaxed/simple;
	bh=D1EEPfJupuPDhVOtTAnEwmkcoO9CoDfH0bLS6OMgw4w=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=B03El6ZzcBUYCs+nyrNc4KHPwg8RfIz5HhBsqvv4ASPY9/tSG014U9aF2gJJDs7xmjOwOjLt+D7NoYtjxm8VwrnfTInRkk38AEOXffmNirR893CE/FR33ve2tcpEcfJIYOi/89p8K9N3wbnFN/46Xm2AP939Dvb956wEk1oDNGQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=Z8bwl0Xj; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=aYONY/pb; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="Z8bwl0Xj";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="aYONY/pb"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailflow.stl.internal (Postfix) with ESMTP id BF9781300395;
	Tue, 11 Aug 2026 13:53:48 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Tue, 11 Aug 2026 13:53:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470828;
	 x=1786478028; bh=qSx5jstEMxGImoS/91W19MHOeSaIonN8JmHYqcRdoo0=; b=
	Z8bwl0XjcJPZQLjW9pXCAUF5EWldkGiE9BEEdn2IuAMsXkmfOq3/dvpxmwnP2ZlY
	8URUSWG/4y0tCxepJplqISoEiYwfVYK/s8vhmV3uUUrGk7zFTdPqMNIWZs+LJLOA
	DyCqajFHL7DmdzdzkamxO9z9Wob/c73E7WLPk597ZlIvHS6jmRJcdG7aHu8F2dTW
	imnXcLgJEGG44MAZQwOinFHlEgCrj6F0218t2fYyyxdt+sm7vHVsMLaS2sM+KzUd
	IucUdBz7PmGhmm4mCSpIW5y7I3249h8Bo0TbSyj3VAlroAAslctclu3lTZEFlZsZ
	2cMCxiZZ3x+umDldQ8whqg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470828; x=
	1786478028; bh=qSx5jstEMxGImoS/91W19MHOeSaIonN8JmHYqcRdoo0=; b=a
	YONY/pbby/jHIFWGCQYz+RGUa9FvXes2QTVlDwZtO0+s6y3GL7Z5zvn5OrsxGQO2
	2CjUf18XoqUu7baCU6uNkr1s/KP55lhhgN6I1S5KKzcgSKi4I4ccbwwOkbop0hph
	KrXZtXVQHK9BAjpJipdmlDKNbWmElQYO0/vPrhkYdaQ8FlfJg+CjWrk3WneBjwRg
	pc+DdLurAGOzcoGOyySJWcadJMh5G3tKOlt3JRBZP/Nm7V58QJLsdxkMviUfgKSz
	faob06Ye2Y6SZRYVO2pKJpjllwmXmNruMWGdOQU6jJuwND0RWOAx2Wp0dtqCg2ma
	mGm/TdYa22Upi948CkHlA==
X-ME-Sender: <xms:q2F7ag6rcMW7PiXU5aVJpGDMjV4y94oKSR98ceGllN2DVEqdO41whA>
    <xme:q2F7aodWtq_UGq3M8P8T9aqgN8mqQTBDNAGndFFqhUm_HvSXiChe26yhBuoJs-LWV
    FKzg3Q3CUg4vLxtFs9M4rLni7eZdMo12wZBq520sgFNd2w0dQP_KQ>
X-ME-Received: <xmr:q2F7asO212iSnFyguVFX2i8LKazuh-gy3sRI-dv5M7tTiMrce552n4EusAmZ-Cefm6zvuGdbae04IA7lsGMs-mk>
X-ME-Proxy-Cause: dmFkZTFP5tmiXRyqpvhao8uWnDWsuVG58E3QcpY8nNF+TN3d4+2z3XaWQJ1+2uEKcUq9Jg
    +xH/KDfBOi31TfxVE5vy2aZ5W5Eono+bvv7mBiiNvVW/C9tjIvrxCLzv7Tz6GJOSvAG1cd
    t11+FzpQNbill+yp1ZC7JKPVzEaxQ4CH2HewKTU1gYEn0mNFldMXWgoBvZ/c5OhwLZogLW
    sZeOMCUfQY9vOvCjGHA0ivpYn+5HBy3sK6RswFREIaUm9jlhbU7pV5ZXGDLpJAMlUAJ/Lo
    y1vjaaTNNEiBF07QqH8YbZg0fsVTsE2lSAku2XiqZRlB3GAWdGnDFC/NxQNHJZjZwh0bh8
    kqbkKWELcjtAChbH2Wzn4QOL41OlbQEqlswqKr3P1+VpFR+XsiNX3rUaf5vdKXSnolPw5Q
    /Ll/uLB1cldMhqyZbAiZQTCYwXiJkO7FdRZ/9Gqe2gvfTrCfAfdNHgTLVZMsAD+fn76T3x
    gFGfQHvbVS8RM9muaXsf/hhgBhDP9KsibwWWSg2C80hHXEUnxirzCVePR8OTs9vajPnbRl
    X6LpwU+UjkzYg6auPW6XF1a5W10elYx6W0MaLbP3aPYktTrXr0mX/LqhjI0xOv8F8rUXJl
    m+CCx3AZq3TzeBvltaEQBfoUWTY6LYm9OAxOqDrHYgNL3v9VOvbb9AA+vdHQ
X-ME-Proxy: <xmx:q2F7atztMqppu2lCJw-ae59-79OYTIhf_9RyZUK_28A5frxI4jADzw>
    <xmx:q2F7ao60tNlXmCbxPM9_Vtf4u2b_FNL1_oEvj80sP9fbOVH7gyrr4A>
    <xmx:q2F7apcLuELBIZJX3JNKD7FIGWcg6-VMv9HSb2EfWQYrubi0zhIlPw>
    <xmx:q2F7at7pehO2MMvoObvrQcmAnnV-vM28a5gSPy_0kgEBunY_22OfOw>
    <xmx:rGF7ajAHefbo5jnothnc_kPjagUMcTa_3pOxoBH00iCr7EwKCl7HBwFz>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:53:41 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:52:54 +0200
Subject: [PATCH v2 05/13] security/keys: wipe key payloads before kdump
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-5-9561d13c2340@jaseg.de>
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

When CONFIG_CRASH_WIPE_SECRETS is set, try to erase key payloads on
panic before jumping to the kdump kernel.

CRASH_WIPE_SECRETS notifiers run during panic() with other CPUs stopped
and preemption disabled. In this state, we can't rely on free()'ing
being safe, so we define a new `wipe` key op.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 Documentation/security/keys/core.rst | 13 +++++++++++
 include/linux/key-type.h             |  9 ++++++++
 security/keys/key.c                  | 43 ++++++++++++++++++++++++++++++++++++
 3 files changed, 65 insertions(+)

diff --git a/Documentation/security/keys/core.rst b/Documentation/security/keys/core.rst
index 326b8a973828..35cb00a87c46 100644
--- a/Documentation/security/keys/core.rst
+++ b/Documentation/security/keys/core.rst
@@ -1596,6 +1596,19 @@ The structure has a number of fields, some of which are mandatory:
      It is not safe to sleep in this method; the caller may hold spinlocks.
 
 
+  *  ``void (*wipe)(struct key *key);``
+
+     This method is optional. It is called from the panic path when
+     CONFIG_CRASH_WIPE_SECRETS is enabled, to erase the key material from
+     memory before the kdump kernel is started, so that it does not end up in
+     the crash dump. Unlike destroy(), it must only clear the payload, not
+     free it.
+
+     This method is called with all other CPUs stopped and preemption
+     disabled, and only for positively instantiated keys. It must not sleep,
+     allocate, free or take locks, as they will never be released.
+
+
   *  ``void (*describe)(const struct key *key, struct seq_file *p);``
 
      This method is optional. It is called during /proc/keys reading to
diff --git a/include/linux/key-type.h b/include/linux/key-type.h
index bb97bd3e5af4..21e07db0c5f2 100644
--- a/include/linux/key-type.h
+++ b/include/linux/key-type.h
@@ -122,6 +122,15 @@ struct key_type {
 	/* clear the data from a key (optional) */
 	void (*destroy)(struct key *key);
 
+	/* wipe the key material without free'ing (optional)
+	 * - used from CONFIG_CRASH_WIPE_SECRETS during panic to keep keys out
+	 *   of crash dumps
+	 * - called from the panic path with other CPUs stopped and preemption
+	 *   disabled
+	 * - must not sleep, allocate, free or take locks
+	 */
+	void (*wipe)(struct key *key);
+
 	/* describe a key */
 	void (*describe)(const struct key *key, struct seq_file *p);
 
diff --git a/security/keys/key.c b/security/keys/key.c
index b34a64d81d47..213e6f1d5d83 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include <linux/security.h>
 #include <linux/workqueue.h>
+#include <linux/crash_core.h>
 #include <linux/random.h>
 #include <linux/err.h>
 #include "internal.h"
@@ -1268,6 +1269,47 @@ void unregister_key_type(struct key_type *ktype)
 }
 EXPORT_SYMBOL(unregister_key_type);
 
+/* Called far into vpanic from crash_core.c with other CPUs stopped and
+ * preemption disabled
+ */
+static int key_crash_wipe(struct notifier_block *nb, unsigned long action,
+		void *data)
+{
+	struct rb_node *node;
+
+	/* If we can't acquire the lock, the rbtree might be in an inconsistent
+	 * state. That's all we can do then, as there's no point to waiting
+	 * at this stage.
+	 */
+	if (!spin_trylock(&key_serial_lock)) {
+		pr_crit("crash_wipe_secrets: can't acquire key_serial_lock. skipping keyrings.\n");
+		return NOTIFY_DONE;
+	}
+
+	for (node = rb_first(&key_serial_tree); node; node = rb_next(node)) {
+		struct key *key = rb_entry(node, struct key, serial_node);
+
+		/* Negatively instantiated keys have key->state < 0 and never
+		 * had a payload attached, so only wipe positive ones.
+		 */
+		if (key->type == &key_type_keyring || !key_is_positive(key))
+			continue;
+
+		/* We have a dedicated wipe callback for this since free'ing
+		 * isn't safe at this point
+		 */
+		if (key->type->wipe)
+			key->type->wipe(key);
+	}
+	spin_unlock(&key_serial_lock);
+	/* off to kexec()! */
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block key_crash_wipe_nb = {
+	.notifier_call = key_crash_wipe
+};
+
 /*
  * Initialise the key management state.
  */
@@ -1290,4 +1332,5 @@ void __init key_init(void)
 
 	rb_insert_color(&root_key_user.node,
 			&key_user_tree);
+	crash_wipe_secrets_register(&key_crash_wipe_nb);
 }

-- 
2.53.0

