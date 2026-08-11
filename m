Received: from flow-b7-smtp.messagingengine.com (flow-b7-smtp.messagingengine.com [202.12.124.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E2C6353A94;
	Tue, 11 Aug 2026 17:53:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786470804; cv=none; b=mPJSlEcksMFXpOK6vhlonZgH5H0e5ZHE0mJZJi604OWBAhXkO7TWrhBVLTC/SAkRIiDMADIe7CTW/mCl5jRgZR4o+01bY6cfR4lYtUK/6hN4dvm6cmDRhyTWS71zwr+A0MV6eL52zScZxMa5T+ce7hX5jX/+Fwln5XWdaacWQPI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786470804; c=relaxed/simple;
	bh=LTAReVc9x33R8uYRFqmmctmj7lFmtsfAK2qsskKYG6k=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FQAkYCwep3DxVnfOjcyiFkhtYgQelHXpfyHcVBTTKJIdGNZeHl1cGg2FbLrAsdTrd5iyb4sIIsLYUUem/MpAqd9ixz7l9s5DCMtwaGCmzmLse1KzN7lDzmWjUPb5YGfk5xK3TG66s1Zc3qpQMeR+vHvko9B5NKCHjuifyUObc2Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de; spf=pass smtp.mailfrom=jaseg.de; dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b=QkWk+O+I; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=JDK0hyLP; arc=none smtp.client-ip=202.12.124.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jaseg.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jaseg.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=jaseg.de header.i=@jaseg.de header.b="QkWk+O+I";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="JDK0hyLP"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailflow.stl.internal (Postfix) with ESMTP id 6B744130016C;
	Tue, 11 Aug 2026 13:53:21 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-08.internal (MEProxy); Tue, 11 Aug 2026 13:53:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=jaseg.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1786470801;
	 x=1786478001; bh=drS8nyfS/5n/9X4otzCRfuA2cT+uvRCf3SjirFiIRoo=; b=
	QkWk+O+IqbOXXrBukMGBQdbUdPA1KgNBvThM4OEZTKN8XpOagHUofAFG1d1GR0ao
	/lYX1uSnQOpRvbvBo8VQVpXEd+yKNzZBvE641sl2Ttw5KCW90N1yb9Xc9aWTvJ+4
	xvr5xnDrHDEAkJAPTfIN+w27hRJFgxz3k/73vpih+tg+BRUVzXl3xyjuCF9AKkX4
	ui+Mo0rDMoxmZpHVqNTF0DmWMAdRdfhWu7pk5oTYovuv09/KgDB+MZdvbDavQSH7
	rx6blAFkBeLVeUMUFKx5/AfC7mkG2ceQc6gSeO3jDjRn0c9F7A50k4X7JfQdp36W
	DYaXkdMfmfOE5iyBgwWj7A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786470801; x=
	1786478001; bh=drS8nyfS/5n/9X4otzCRfuA2cT+uvRCf3SjirFiIRoo=; b=J
	DK0hyLPHLvx4qRVfCyhcGaY3Y1afb/Vr6BSxZ+SPEkbntfgaOn3F/kaQ55e/DxpY
	MF4ppmUTtSC+i3NwhKwiUU8tVt5edI7hjrpkhlgm8jHHb/vnsiqQlbQmwKe2gElS
	Yxt8h5eVOzzYCSAw9E8TNszM0vfl9lRNNiykjDUWSsSaaRdIdHpBElBkLvT+wo7h
	LF/926SMCsrhNUHaIx06eCNigbGYwQwANiIXGVuTJEP2ET+U0v8jnyrTC/LaUMFm
	3U6E0p1RUXgaQrWhipCy3DiU6Ztdr94fYDc7ollSUWH7sZHSzTojL3uivjRFAHCg
	cTMFmqJEuklLuwg+uoKqw==
X-ME-Sender: <xms:kWF7ahPL-vL3tF84f1TFR9W7IQw7kPkSUVz234bdzUjweCdAL6k4-g>
    <xme:kWF7aqh25gYsUv1Slr7d0IyOkpYuU6WDllfNUjmUCT6qyUKRl-zshfE0yW7h9ZfmV
    ZVd1FTHJXqI7KVbWSRN81HrjwJFURiy9FPpCGaD_fUsX16NC8CcmA>
X-ME-Received: <xmr:kWF7atAKnwG_L1Az0VDKSMi6BdZRPeBv8cEo0ZDxj9uHgueAY6Z7Fe5AyeSiirFdNPrA7RsCuIiD-TCb3SZafg8>
X-ME-Proxy-Cause: dmFkZTEJEGuCgn7zSteBDxNtSJjV76+V4CnevXg+/HpV8pBcUcuiCNODIEIDrvYJtfUig4
    YbV/QY7F/5FmNh0pRZPVmKSRgYy7+KF1hyAgmaSBfjrBu1Tf17UBdgE0OKLaTkwTcf35M8
    A3BG9gU1kUODTHqS0pdsippevO97iASgI9eCstdiieZcmNJMxjp+Dk/kb2yyT19QSKiq2/
    PYmZLQclF7ZDW1mh1YN6ilSkOCjygxJsr5eR/wz7HE2fkmdnLW9InISWV9kR+irzxvtO9I
    pnBZF98lSAmI852yZY0IsRjcC4lEqWDe/NVDMPZFCYAeAfD86idfVCQ6A0RRy8MpCwFrGi
    JaamIhViNAMRkMCXjV9YL6sd6IHyq/tf2HlfDMjgIP2APCVaZFFwrE7zrV7ovbBban3Iu7
    W/Uh5FMdKsGj5pZx7P6MCTneY76byI6K9C/6cbEqr5VdWRn4duFZrtBn2D1tYrI8NiPdWc
    ppdDBXno6JjG1NA7VgMw1eNcNKfSPsYaWA1j2XBlxJK1+DKisAb9rbUMzR+NeEbFpeQxKg
    w7AZvvx58bqYqiXZjVrLVsnJ4IKjr0WeLWQcsrUy/zeFdUPOGwdqK34r2DtI5AwmetFmPP
    0W7aqfZ35Td15bHqKqCcppuR1Zm69cCvNfIMnYwrbZbhpOtGuGMgQK9/Qtsg
X-ME-Proxy: <xmx:kWF7amVlkY6EEuDIyC0WoxRvqtGq5ILKX5as1F-XLFce9eQpdiS7uA>
    <xmx:kWF7auOvnvXF8D31HFphofi61ah5tcQFkBu7TeKHgioHgv92EAB4_w>
    <xmx:kWF7ashsgsVXibL7meABAHFLlo7CAUmBCG9_7nrRcUqZrWwBnbtGiw>
    <xmx:kWF7artRJK5afcegwONALqXLII5e98jHTVHA6TFoouW-ondHQiaCzQ>
    <xmx:kWF7avUG4Ti3NfPHjv73nO4mc1ldjlFs9gNabtv2uLpn8YPIE-JzZ_ON>
Feedback-ID: i60a14417:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 13:53:14 -0400 (EDT)
From: =?utf-8?q?Jan_Sebastian_G=C3=B6tte?= <linux@jaseg.de>
Date: Tue, 11 Aug 2026 19:52:51 +0200
Subject: [PATCH v2 02/13] crash-core: Flush caches on CRASH_WIPE_SECRETS
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260811-crash-zeroize-rework-v2-2-9561d13c2340@jaseg.de>
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

Replace memzero_expclit with our custom wrapper that additionally
flushes the target address ranges from CPU caches.

On ARM64, while memzero_explicit is already reasonably reliable for
wiping secrets from memory during kdump, it can theoretically leave
residue in DRAM when the last memzero_explicit writes are still in
flight in caches when shutting down the caches in machine_kexec.

We need to swap every memzero_explicit call because ARM64 do not have a
wholesale "flush all caches" primitive and only support flushes targeted
to a particular address range.

Architectures other than ARM64, notably x86-64, are not affected by this
cache flush issue.

Signed-off-by: Jan Sebastian Götte <linux@jaseg.de>
---
 arch/arm64/kernel/machine_kexec.c | 20 ++++++++++++++++++++
 include/linux/crash_core.h        | 21 +++++++++++++++++++++
 kernel/crash_core.c               | 23 +++++++++++++++++++++++
 3 files changed, 64 insertions(+)

diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
index c5693a32e49b..12bf3c90f519 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -6,6 +6,7 @@
  * Copyright (C) Huawei Futurewei Technologies.
  */
 
+#include <linux/crash_core.h>
 #include <linux/interrupt.h>
 #include <linux/irq.h>
 #include <linux/kernel.h>
@@ -15,6 +16,7 @@
 #include <linux/set_memory.h>
 #include <linux/smp.h>
 
+#include <asm/barrier.h>
 #include <asm/cacheflush.h>
 #include <asm/cpu_ops.h>
 #include <asm/daifflags.h>
@@ -221,6 +223,24 @@ void machine_crash_shutdown(struct pt_regs *regs)
 	pr_info("Starting crashdump kernel...\n");
 }
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+/*
+ * Queue each wiped range for cleaning to the point of coherency.  Deferring
+ * the barrier until the notifier chain is complete avoids one DSB per range.
+ */
+void arch_crash_wipe_range(void *addr, size_t size)
+{
+	unsigned long start = (unsigned long)addr;
+
+	dcache_clean_poc_nosync(start, start + size);
+}
+
+void arch_crash_wipe_flush(void)
+{
+	dsb(sy);
+}
+#endif
+
 #if defined(CONFIG_CRASH_DUMP) && defined(CONFIG_HIBERNATION)
 /*
  * To preserve the crash dump kernel image, the relevant memory segments
diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
index 4230463f3faa..d3e4192b7e6d 100644
--- a/include/linux/crash_core.h
+++ b/include/linux/crash_core.h
@@ -6,6 +6,7 @@
 #include <linux/elfcore.h>
 #include <linux/elf.h>
 #include <linux/notifier.h>
+#include <linux/string.h>
 
 struct kimage;
 
@@ -15,6 +16,26 @@ struct crash_mem {
 	struct range ranges[] __counted_by(max_nr_ranges);
 };
 
+#ifdef CONFIG_CRASH_WIPE_SECRETS
+/*
+ * Record a range that has already been wiped, or wipe and record it in one
+ * operation.  Architectures may use the ranges to push the wipes out to
+ * memory before kexec disables the caches.
+ */
+void crash_wipe_cache_range(void *addr, size_t size);
+void crash_wipe_memzero(void *addr, size_t size);
+
+void arch_crash_wipe_range(void *addr, size_t size);
+void arch_crash_wipe_flush(void);
+#else
+static inline void crash_wipe_cache_range(void *addr, size_t size) { }
+
+static inline void crash_wipe_memzero(void *addr, size_t size)
+{
+	memzero_explicit(addr, size);
+}
+#endif
+
 #ifdef CONFIG_CRASH_DUMP
 
 int crash_shrink_memory(unsigned long new_size);
diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index 95f5c0415e60..42faf8d0a4c4 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -51,10 +51,33 @@ int crash_wipe_secrets_unregister(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(crash_wipe_secrets_unregister);
 
+/*
+ * Some kexec paths disable the data cache without first cleaning it.  Give
+ * architectures valid virtual ranges for the wiped data, then let them defer
+ * any completion barrier until all crash-wipe callbacks have run.
+ */
+void __weak arch_crash_wipe_range(void *addr, size_t size) { }
+void __weak arch_crash_wipe_flush(void) { }
+
+void crash_wipe_cache_range(void *addr, size_t size)
+{
+	if (size)
+		arch_crash_wipe_range(addr, size);
+}
+EXPORT_SYMBOL_GPL(crash_wipe_cache_range);
+
+void crash_wipe_memzero(void *addr, size_t size)
+{
+	memzero_explicit(addr, size);
+	crash_wipe_cache_range(addr, size);
+}
+EXPORT_SYMBOL_GPL(crash_wipe_memzero);
+
 static void crash_wipe_secrets(void)
 {
 	pr_info("Wiping sensitive secrets...\n");
 	atomic_notifier_call_chain(&crash_wipe_secrets_notifier_list, 0, NULL);
+	arch_crash_wipe_flush();
 	pr_info("Done wiping secrets.\n");
 }
 #else

-- 
2.53.0

