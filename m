Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.219.44
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795072725;
	b=cY8hnXepmlt2NKetnz7yTUjLolj3mdr9xvGqNFkwGHGArHicKDdJ5Gh208VaTJqxxMAj
	 DA17nslin/ljAls7kVg75fBAZOWb8/PK1Tn3/6sO8y4AEIvTDmS4wBeh1znTneLEZ8O0g
	 o+tJGNmL6abQs7yZ71bkKkUD4RuNlZOefw4rRL+9zPzGvhg2czqKjYtHxabFTjYTd9hEy
	 dc70BD2l7I7P+NtlryVZEKa+gPQopwAEXOkOLYxgsnpcxvLezTqq8AUaQA0qjuUv25i5h
	 udPQd/YQyOOZIJLTVyGV28Y3vTcHNjeV8eIJoQgLyTx+WQ5nH+pxUGPgBL5ek23do0w==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795072725;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:From:Date:X-Gm-Features:Message-ID:Subject:To:Cc:
	 Content-Type;
	bh=NsJb7bPA9D+bcQDpZCNr8K9FWLxPII4RzY6xFEDpZMg=;
	b=1CSXMxLPqC+7C0bNwOKF0UuhpiyKmZn/c6ByM9F0ofZhW2EZYFFg3erpWHQcTE+n07wC
	 6eJG6JNgka9zVEYHhFzeXcZlh8B+eppxHOm6xiS626/M9qyyalysOf9ajfuNaANAETRmN
	 9Z1HyS/9QHb5RA0mOUdNZ7q88bsdzDWHCYpQ7V5M0A0kY+F5JgmlGd5DZDQaUuE218uBL
	 GV0oMCyqhI423rQCwD5pxpUGBTasUNuRPkX5DIUvKCyWaBE1bucjziyF34/kzomSf35Cv
	 gSoe6nWKFs6C1WpyX3jS32Y3odIrfIER4rVukZKB4pyaK+Ys5jJhYXzFtIxDTYXNFFQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=BiYz9lJE;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.219.44
Received: from mail-qv1-f44.google.com (mail-qv1-f44.google.com [209.85.219.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE193606A325
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 07:18:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AE193606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=BiYz9lJE
Received: by mail-qv1-f44.google.com with SMTP id 6a1803df08f44-92107df3f13so17418916d6.3
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 23:18:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795072723; cv=none;
        d=google.com; s=arc-20260327;
        b=PkxV4s20H15uFmQgbo1n7roekcvA7ftRER6Man2zVHiw36AVrhZ9bdSLfyyRh16+vs
         Zv3I+usPNnmkQhcC4DoU9pB0VypxiZHW+Fw+PMvVjR8sye3hFUd5bcXN3rp01eHdYVHF
         0r3oAWLJy06+5bZfaB37gME5zCCTasNwel+W4MoAHx8rQOa+vIlSHLguXlgNiWiIISZm
         9ZLKyEDcY54y7uifJUnE8FtvPaHC1CPCaXl7i5Xj8hQZBLRcd5Dupb+lrWdALvJuJA0a
         CER4VQg1xwtijNWaM3htsXJPOukhFT6f4iQaCbP96Ai97+2UktU/iHJJZCWOF2eak+s2
         SrHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=NsJb7bPA9D+bcQDpZCNr8K9FWLxPII4RzY6xFEDpZMg=;
        fh=9fwGdNbGC8+f/B0kiB0baVfhE0H7+u/25CYoj7+yZrE=;
        b=sCLPerYwCPkGS6z71zTye2Tw4RC3HtGt6nkbxKVlQLCNsMhkS9Xa9eNX0kaTCoLvhA
         y2+yKg4rgZ+9xupHzZKYgV7n4tc+RiFO25rFq544AwSHWm2MvJ++DKx/cH6nzVgr+79+
         C8PX3mvdKdUeYPa/BuVFxeIZO5CNY4mSGhax5vF/EzplxOXVf8sGDk9VrXdOKc26QSj0
         nNDlwCO/OfO/MNUYhpOeCciGXBy5ZIXzPQ54giHRVG38uQ1Nlh2XHGroqPYu1TBVPkmI
         EFoDXW1KNAO9uFL2V5hdgNHBhgWTUOvePLgGEBPU0TGnSIgIjtYh66ANHUGptLkFqkie
         xiqg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795072723; x=1795677523; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=NsJb7bPA9D+bcQDpZCNr8K9FWLxPII4RzY6xFEDpZMg=;
        b=BiYz9lJEERcoGyT04qVsDnpRknGsxOdwQXMrJP2DZ0x60fmfzVOwGDIuuevls3tQMs
         zUiTqUTqMaicg0A7nLQnAKQ0qWMGNRz9Eyfkit0HCAKT2RO7h7/feC4jKf7Mrxd0uNhN
         7ke0RwaLAtJfKR+Naq23c4Soy7izzkKkA5ym+gAF6r9zNrT4/dQY5uX8AX6+hGoR727/
         zo/Jzi/4JfRR5CNJrfEZkQvTb0FPbHezGUG9C8Ur3SLvaIOA6pgvSMzOatU26oziQC8N
         IlMEWUJinVPHrekV5H17XucfZBm1tw40lFH5qAFi7W4uWziYQRpAdJUw0n7uHZjh2/N7
         ZeGg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795072723; x=1795677523;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=NsJb7bPA9D+bcQDpZCNr8K9FWLxPII4RzY6xFEDpZMg=;
        b=RicjzayKCDytl9k5DX5q8Js7FMG1ZJxnt3C1pOlrU++8kEm1XpXCXOTbu3Z6f4zLnw
         QsFhPuGEzfPVqaGv0NVXm51lHc7/ogn8aj6qZrxCz1Julbe/TKousMte2eyleHxBDxFW
         HMZeP9a09ip1l7lZ3t6Zsi8Oo2Dd5VDym29oj+5FPOZpzX6kkYDRTsOq0PiIuJBu64IU
         q+JZ7GwiN69uEm9MbE1toaBSqs249VymgsbWiZ/vGbtXkZOL8q5KZZRRqh/qtfRwO66y
         MBnLX+/XDz11OHLkBtEbYZInQA2YVIzZiZtkOH7fEf6JMLiZ3fsIL34DOemJIB5XobbZ
         AaeQ==
X-Forwarded-Encrypted: i=1; AL+hErEq9hiAA4nJXI7tMmCEF+Dog+twod7JOi+V6DEJXkAERkm1vGLRCi6Gn4ED2De8JBWnmfigGG7TlIQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z9zwC7e6rujU3ivE4w4X7TNyxcpLLr+KFxPxbJmhDyS9AK4nnPj
	tK9OgQCwIzt+lWNJFpn+ATB66TSwAHodrEhV05EV6Np+zC3SJiBNyxBJLqn6PCSXuBEqa0ye/yW
	jPAuDFJtBP7CZ6usOYoZgHLGX5JbxT2U=
X-Gm-Gg: AZFdTZcBrAUmiuA1NK6WTaQ49E6CMONsJm06pYOZfG8p563j02zGjHW4jOsEIQfR8LQ
	Tum15xuNamDge7L1hbhaHdWGH8K2gK8W0y956sX0EUE52oNJ3CiZ1c9MaBQsmE+iRDOGoc9A/b7
	ODxdC/VXgrZLMdlAtueMXepiFAfhq5cvOobbl87CThAT24/86XzC/Rkb9rDRY/VSJu4KhV+1a8a
	PCr9qqeJufB4qPa7AhQCzm3Tup1e6hfR1ZEZ3+WqRuQ20EuPq2wQZCPI2zs4TCZW2xDV8ACTrzq
	EaNWflC8JeTatvVLK8DjIi7P5jEPt7cq6wD/yQnn/ZTg2/htwYZmwIjHuA6rU5ivUpwZfVDRg89
	tBxYng2YN/sFUcWo+YjeWAAh01BJGnIbMssOKvIrKpeKv3O4IM7lLNrICpYHBgWNFZQ7u6uPbVz
	ppoAxxLfuzzl8SSVVEFg==
X-Received: by 2002:a05:6214:2484:b0:91f:10b6:2743 with SMTP id
 6a1803df08f44-92114f68851mr74072936d6.36.1795072723595; Wed, 18 Nov 2026
 23:18:43 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: Yingke Xiao <inkxiao12@gmail.com>
Date: Thu, 19 Nov 2026 02:18:29 -0500
X-Gm-Features: Aa3M54pxDoYxauvJoi_1hEHlnijhpNFabeXJ38e3q8jAEIPpcdRwokeVm9U0kZs
Message-ID: <CAMcAce-ytH2Xt_0+1fKXzxy+a8fi0Md-4SSoLZ1RQxKQoLq-tw@mail.gmail.com>
Subject: [PATCH bpf v2 1/3] bpf: Replace DECLARE_EVENT_CLASS names in raw_tp_null_args[]
To: bpf@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>, anna@kernel.org, linux-nfs@vger.kernel.org, 
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au, ast@kernel.org, 
	daniel@iogearbox.net, andrii@kernel.org, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

btf_ctx_access() strips the "btf_trace_" prefix from attach_btf_id
and matches tname with strcmp(tname, raw_tp_null_args[i].func). Because
each attachable tracepoint typedef corresponds to a DEFINE_EVENT() name
rather than its DECLARE_EVENT_CLASS() template, three existing entries
in raw_tp_null_args[] never match any program:

  1. "nfs4_inode_callback_event" and "nfs4_inode_stateid_callback_event"
     are DECLARE_EVENT_CLASS templates in fs/nfs/nfs4trace.h whose
     DEFINE_EVENT instances are nfs4_cb_getattr (:1455) and
     nfs4_cb_recall (:1518). fs/nfs/callback_proc.c:50,106 pass literal
     NULL for arg 2 (const struct inode *inode), and TP_fast_assign
     (:1424, :1481) checks !IS_ERR_OR_NULL(inode). Keeping 0x200
     (0x2ULL << (2 * 4)) sets ptr_err_raw_tp = true so btf_ctx_access()
     assigns SCALAR_VALUE to ctx[2], rejecting any pointer dereference
     even under if (inode) and matching existing raw_tp_null_args[]
     0x2-nibble convention (0x300 yields the identical SCALAR_VALUE).

  2. "iptfs_ingress_postq_event" is the DECLARE_EVENT_CLASS template in
     net/xfrm/trace_iptfs.h:108 whose DEFINE_EVENT instances (:130-148)
     are iptfs_first_dequeue, iptfs_first_fragmenting,
     iptfs_first_final_fragment, and iptfs_first_toobig.
     net/xfrm/xfrm_iptfs.c:2025 and :2051 pass literal NULL for arg 3
     (struct iphdr *iph), requiring mask 0x1000 (PTR_MAYBE_NULL).

Replace these dead template names with their DEFINE_EVENT tracepoints.
Verified in QEMU on x86_64 7.4.0-rc3 (iptfs_first_{fragmenting,
final_fragment} and nfs4_cb_{getattr,recall} flip from LOADED to
REJECTED) and 6.12.118 (nfs4_cb_{getattr,recall} flip from LOADED to
REJECTED; iptfs_first_* absent in 6.12).

Fixes: c83e2d970bae ("bpf: Add tracepoints with null-able arguments")
Cc: stable@vger.kernel.org # 6.12+ (nfs4_cb_*)
Signed-off-by: Yingke Xiao <inkxiao12@gmail.com>
---
v1 -> v2:
  - Correct sender identity and Signed-off-by with real legal name per DCO.
  - Remove drafting notes.
  - No functional code changes.

 kernel/bpf/btf.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/btf.c b/kernel/bpf/btf.c
index a123456..b234567 100644
--- a/kernel/bpf/btf.c
+++ b/kernel/bpf/btf.c
@@ -6605,10 +6605,13 @@ static const struct bpf_raw_tp_null_args
raw_tp_null_args[] = {
  { "bcache_journal_entry_close", 0x20 },
  { "bch2_journal_entry_close", 0x20 },
  { "fsnotify_bump_event_seq", 0x20 },
- { "nfs4_inode_callback_event", 0x200 },
- { "nfs4_inode_stateid_callback_event", 0x200 },
+ { "nfs4_cb_getattr", 0x200 },
+ { "nfs4_cb_recall", 0x200 },
  { "nilfs2_transaction_entry", 0x4 },
- { "iptfs_ingress_postq_event", 0x1000 },
+ { "iptfs_first_dequeue", 0x1000 },
+ { "iptfs_first_fragmenting", 0x1000 },
+ { "iptfs_first_final_fragment", 0x1000 },
+ { "iptfs_first_toobig", 0x1000 },
 };

 static bool is_raw_tp_null_arg(const struct bpf_raw_tp_null_args *entry,
-- 
2.43.0
