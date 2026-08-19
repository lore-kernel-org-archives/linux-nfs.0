Received: from mail-ej1-f44.google.com (mail-ej1-f44.google.com [209.85.218.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 035422609FD
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 17:01:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787158886; cv=none; b=HaHg7qe0Wyy532fzcKtCm5/SJ42Z6y6is81KgK0vTwJeckRa50hq/49UaZK5OJJ4F0O1icS4jOct40cNDJx42eMuezXAHKDwT/d0woCAXh/+r4NMDP1oElM6xiEvmedSoGA/2yKWQF3Oigk8BHY52qlGxuxv3Kn4iO6KtBxaEIA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787158886; c=relaxed/simple;
	bh=fwV+JDCI3nJfFhJewL7AP2S++Rp+BbZQQu6VkrL8T2o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=uJ9c4gskn+WPRZfeYySIjcvRL8og/l7Rz733HdeTHPubW+dO/VfDv4AEDEizkXA5ObHjGSNDJFf0fXC7vZlbnfsKZF4ECvcLS9V2L+d/haiJB/eRXZjXoSycT5xTTF2kSzDv4FpABLlwWN+hp95QPRO1t8GdA0mxTFptN/BlXrs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=bynar.io; spf=pass smtp.mailfrom=bynar.io; dkim=pass (2048-bit key) header.d=bynar.io header.i=@bynar.io header.b=XespfQRD; arc=none smtp.client-ip=209.85.218.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=bynar.io
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bynar.io
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bynar.io header.i=@bynar.io header.b="XespfQRD"
Received: by mail-ej1-f44.google.com with SMTP id a640c23a62f3a-c214e625259so185121266b.2
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 10:01:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bynar.io; s=google; t=1787158883; x=1787763683; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=xAl6LZ0+0WULftqzAvcI3a0vNTBx8JGUNC+xMI0jl40=;
        b=XespfQRD+OYg9a6Q86EuzIv2xKScX2J8IpCux/7HGDaTDS+A3tJ2gUXg3I5rGt99MH
         vKOR4MHm8Blvm8adm7K7gXbx92oxvgoxoaUTGPq5qoXlT68f2tz1HUChLXvLFbRtZ9cS
         tcALUMrczgMkOeCg9f6BPiNUm12onMSVCLQtr1z7r2sdKeyw58VHnvmLEL/WOqdp6eyf
         iv2iKLhLpQnwCLU9Eh1iaDmFnmlMq2M4TO1TYgytEC0+F57LnSi0p8vbSLU6SnNIIlQg
         2j5VmuPlw5nNktojm75/hUILElfis3xGUrXCm2V8o+SUsEapzxo12/GUR5UpYvzHIS8R
         6Deg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787158883; x=1787763683;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=xAl6LZ0+0WULftqzAvcI3a0vNTBx8JGUNC+xMI0jl40=;
        b=STkNQjggkakjZkBkwh4zXlCQ3NwwFKhlSc1bRGaGB7x/5C7l+PKzYVQEEynWKLxQm7
         oId7oxLW+4iLnGL5T2K2H3UYOoGwtZ2T6kozjuPR/w3r14dhIXWdgXcDuTFlGRZC8DHu
         3pVtIgzz8Ohomi3vycVXq5N9KitqG/LBQewv0k8pWIyZaCY8TFl+6oX4bhNI7QAwYeVs
         MR5omCmogiGF9bgVpxedRIBZ74ECX3ymQEIaTL95nOgeEnBrmY38cIfWQ+9rnvrLIDM1
         vVDSkjitf5nHGr5ps4061Koiv4vyBpdNOd5RCmlDpr0fGRkXNzK4NTTZ/PJhWhRY5iBJ
         Jv3A==
X-Forwarded-Encrypted: i=1; AHgh+RpqBZUA0a4jQxHNCw5aeRgAds8kr9So8qfYUm8pHVPWDgpIVztoziEeqfx7RQOQ/SVnTebmxETbuuI=@vger.kernel.org
X-Gm-Message-State: AOJu0YwGaYVzPFpiEp3ve629dVYVPFccuikpErA0J7V/Jo2n94PjnUYt
	hBTxQdrRtDpt4KoniBi56Fe+tp5td/EpLa+2696YX6w3+0UQ2ZK9AgLF8Mf1fnsndrfex3dbLI3
	y8l8ktT4h
X-Gm-Gg: AR+sD11nB4nK5jQexd2iYtlnV9g9ayo7kBKyLfin3P7OsaTbdYMS5GUz67gkn4mLE8N
	gWrOcfKVFSrq84gKLNBV6pjw5S7ySvHv1KZnuGg7ElFcbOUaCp5SM9Vz8qTcaHVH3O7s5Fk83kT
	v7KCIluXDwtiaKOVyHHkFrIfniiQIdfBQHlfPG7cObFfiuSnHMwWmZtIBcFDFaGLxU1gvn/zFqO
	6htm6ZME4/lG6QYJaNIfZ6yoTYMSEycLVlqcD0prxmVYLVeM4G0ru9Ko7ceE3rcIAsuhm6kyfis
	7+Fg+ofNxUOxcEc0SfE4QIqFiIl4qYQYHV4tYxw8ePcNz7rNLu2xCSL31CShtZZxqeTIIOqt4Wc
	PEDhYIQcCJ6WyoXcRd5NINV9MajhYF7iGFfjS9dDf0nekMDij2KpNu26IB618xdRaaa/9zThPtN
	yNibpletGCsnCM3Kc/PpP1RtwSLbaoxUYb2IrEnoGnc9kEbqJDrbRF0Z7v0fnnVSNV0c+qJ5zO0
	xPSl/U0onGhcxklvE/c86qnRUQfmQcVrlOd3DZDrtJpqCWSfHdsvsylKzU=
X-Received: by 2002:a17:907:3e18:b0:c20:33db:41d3 with SMTP id a640c23a62f3a-c242e1e6a65mr446099266b.11.1787158882885;
        Wed, 19 Aug 2026 10:01:22 -0700 (PDT)
Received: from localhost.localdomain (cpc69057-oxfd26-2-0-cust39.4-3.cable.virginm.net. [82.6.0.40])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c243c7c2b45sm103155066b.13.2026.08.19.10.01.21
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Wed, 19 Aug 2026 10:01:22 -0700 (PDT)
From: Paula <paula@bynar.io>
To: Trond Myklebust <trondmy@kernel.org>
Cc: Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Paula <paula@bynar.io>
Subject: [PATCH] NFSv4.1: fix out-of-bounds write from zero back channel ca_maxrequests
Date: Wed, 19 Aug 2026 18:01:09 +0100
Message-ID: <20260819170109.8132-1-paula@bynar.io>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs4_verify_back_channel_attrs() validates the channel attributes a
server returns in a CREATE_SESSION reply before they are used to size
the back channel slot table. Unlike its fore channel sibling
nfs4_verify_fore_channel_attrs(), it never rejects a back channel
ca_maxrequests (rcvd->max_reqs) of zero.

A zero value reaches nfs4_realloc_slot_table(), where
nfs4_reset_slot_table() derives both server_highest_slotid and
max_slotid from max_reqs - 1. The subtraction is unsigned, so zero
underflows to 0xffffffff and is stored as the table's slot-id ceiling.

The attributes are chosen by the server in its CREATE_SESSION response:
a malicious or compromised NFSv4.1 server, on the wire, with no
authentication under sec=sys, and before the mount completes.

With server_highest_slotid and max_slotid at 0xffffffff, the bounds
checks in nfs4_lookup_slot() (slotid <= max_slotid) and validate_seqid()
(csa_slotid > server_highest_slotid) no longer constrain the
server-chosen CB_SEQUENCE csa_slotid. nfs4_lock_slot() then runs
__set_bit(slotid, tbl->used_slots) against the fixed used_slots[] array,
which is only SLOT_TABLE_SZ (16) unsigned longs / 1024 bits. A csa_slotid
of 3584 sets a bit 448 bytes past the array, a slab-out-of-bounds write
into the neighbouring allocation. The slot id is server-controlled, so
the write offset is attacker-chosen and deterministic.

KASAN labels the access below "Read of size 8" because __set_bit() is a
read-modify-write and the sanitizer flags the load; the store is the
actual defect, hence "out-of-bounds write".

  BUG: KASAN: slab-out-of-bounds in nfs4_lock_slot+0x148/0x15c
  Read of size 8 at addr ffff0000c7232bf0 by task NFSv4 callback/235
  Call trace:
   nfs4_lock_slot+0x148/0x15c
   nfs4_try_to_lock_slot+0x74/0xc0
   nfs4_callback_sequence+0x850/0x141c
   nfs4_callback_compound+0x414/0x111c
   nfs_callback_dispatch+0x6c/0xf4
   svc_process_common+0xb3c/0x1ba4
   svc_process_bc+0x400/0x9bc
   svc_recv+0xb5c/0x23fc
   nfs4_callback_svc+0xa8/0x140
   kthread+0x32c/0x3e4
   ret_from_fork+0x10/0x20

  Allocated by task 234:
   __kmalloc_cache_noprof+0x188/0x480
   nfs4_alloc_session+0x44/0x260
   nfs41_init_client+0x18/0x80
   nfs4_init_client+0x120/0x440
   nfs4_set_client+0x310/0x5a0
   nfs4_create_server+0x124/0x234
   nfs4_try_get_tree+0x70/0x240
   vfs_get_tree+0x74/0x2c0

Reachable with CONFIG_NFS_V4_1 whenever the client mounts an NFSv4.1
export from a server the attacker controls or can spoof.

Reject a zero back channel ca_maxrequests in
nfs4_verify_back_channel_attrs(), as nfs4_verify_fore_channel_attrs()
already does, so the underflow never sizes the slot table. The error
propagates through nfs4_verify_channel_attrs() and aborts
nfs4_proc_create_session() before nfs4_update_session() installs the
poisoned ceiling.

Fixes: 5405fc44c337 ("NFSv4.x: Add kernel parameter to control the callback server")
Cc: stable@vger.kernel.org
Assisted-by: Bynario AI
Signed-off-by: Paula <paula@bynar.io>
---
 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5709c6fea..182078c2e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9161,6 +9161,8 @@ static int nfs4_verify_back_channel_attrs(struct nfs41_create_session_args *args
 		return -EINVAL;
 	if (rcvd->max_resp_sz_cached > sent->max_resp_sz_cached)
 		return -EINVAL;
+	if (rcvd->max_reqs == 0)
+		return -EINVAL;
 	if (rcvd->max_ops > sent->max_ops)
 		return -EINVAL;
 	if (rcvd->max_reqs > sent->max_reqs)

base-commit: 3a0dd7ba4f44cdc116d83712f61e7c1a95be3588
-- 
2.50.1 (Apple Git-155)

