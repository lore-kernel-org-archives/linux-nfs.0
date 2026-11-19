Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.219.51
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795069201;
	b=wLBiOXvtZHPXpZQyTOfkIu/3YZrrH6O14wByW44HINpT5yVH33BsIUnMilcEMIhTDbL5
	 7lbxE3iGmXt9VN4FStwozdJlyp9+yRVJvO9Mb5n0V1wzxl4p7gY0/2GAzDohpqg7qt40+
	 1vn5FCf8yRaf4ijId7gNupwalN0tbVwUy/ZZvx/xjIPfGMUw7yxkjcUzrrEgVYqIYquSJ
	 YcSFRrSfZTpcYHRSd+I/jT6mZ3jxVkAAGPe3R8Zu2SH10he9bUwl7v/0OzK7aUjPJCV/4
	 iVXyDQlmTB8evnH2GDT9JZf8aZef1/cc34F7mvRI1rUywgPEXPCVvMGwWxngAIcqMuA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795069201;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:From:Date:X-Gm-Features:Message-ID:Subject:To:Cc:
	 Content-Type;
	bh=xoCndVwrvCSfCd0BaHKCqL9ELaacWGRyWSDCytAWBDI=;
	b=gqFrw5YEJfu7xZncVA0Diq7duWrMf2/aS1/8jsJU9qq6MjswWEAsJczgFe25j7OppIlm
	 nUbqywYcSyNQjfKdfSckHOXff4knrj1HlEKQobxMC5TkdUnbgU/uhrXwuy74LJ2DeHxbg
	 jZxJwPWrBKRlI2avLF2cENlihxyQPJg3ZplWbU4IwQiBxenEXs7I7T62WOia2v7VCNdc5
	 sx8Tp1CKW4uVmp4/tMo2bZzwedXCb1hfh4h5hLQEYCCEIKTIlePCTWM2ai2y8mKMW6CEt
	 EhbglHC1bSs7aZxwX4KIf49Zki2zdsiZIMaXJnU5OhiCKKisxshv82X56gclDu7GQsg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=UT7r6HIM;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.219.51
Received: from mail-qv1-f51.google.com (mail-qv1-f51.google.com [209.85.219.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17679606A326
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 06:19:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 17679606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=UT7r6HIM
Received: by mail-qv1-f51.google.com with SMTP id 6a1803df08f44-91ccfb88e4dso19677696d6.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 22:19:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795069199; cv=none;
        d=google.com; s=arc-20260327;
        b=OPIeXUY2//NTqExvcUccMgSfIDLCocD0NRrZ9CiC9OfIOKLpjMIxJRnbZXWqNUoZUC
         itHeKCy9unJW+P/m3WTV62WDbhzcFdDK35+pJFvgBq+84voR/PfBNc1kzOruEHfvvzC1
         S/pNQ+BEH1cW1RTSpZB020XLEsRWGE9FcZX9wjxel0yxfAXJrWE0uU08F5Jc3apUEmXe
         XHPO5+mHVH5XrB4r/7hmUNZcOwxj8bqgFzhslVywc2siBgHWBpKtJ1Dh/h5SmC4ivPDW
         VrivUH31oOPun78AMCJsSZFJA/7+yXv+KFB29oa448ap8t8hU1DZrrAhPPX3k73+Xnb8
         s93Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=xoCndVwrvCSfCd0BaHKCqL9ELaacWGRyWSDCytAWBDI=;
        fh=l6p7kQlZkypuJNiqOoxy77jrHom7fkQxgsKkclavoF4=;
        b=sjaknO0+aBmloPo2uMjcZ+pDbriqbbZ4ZjAiTM0HOggj7Vj/ul2PxHIn9J46Yudsr6
         pqcv0/j26BDy7kT2793PIwh37Vx0tWwtQRI3QcN5jaf6wMWvLK29uLpLmmz+bLAJftMf
         ZNVNCf8itVcaig0+41SD8oOx1HEsgwn1fuYDAt4/jzzyI2PUVIDEgbTFK9mGOMkJiw/M
         rfYNaHObEexQq9zI78XcGajd9RkD2MXZsyM0m1ifYcsVffKjdSFinjstnJljO+M5RkDo
         QpM2UbcHTokD3yZ1QgKjkj82QY6YRBC4vWS1NJZ5MIsQWaurrM7cwHfcCvbavpCO/d1K
         VXvw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795069199; x=1795673999; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=xoCndVwrvCSfCd0BaHKCqL9ELaacWGRyWSDCytAWBDI=;
        b=UT7r6HIMP8x6DmYZaQezLkvtfE9jNe8QAZNjoZ+BDLGzqxB4OhFh83dq2c2fciCrs0
         7fuwCWV8wQqIvxi9O3MUE0IR/oZMWHzvUTGYfc1aN+Z//8i+lhbV8PKSw89euW0ZQk+H
         8q5pGCTpngISoL3G/Cb+omZLqqhIVPdvAFuv6b2+g7FV5AWky6L+uVa71XJbPqKri9I1
         dZXoe+f8xzF4CDQJKfgEocHcqWxhEpQOfdD3u1P1GtLbiAv6i41ol3ck/rANGAfP9rnU
         Gug2I0Kyk+h0n1UkYk86LPFEZ1RNs0GugUbSr7SGaIIAhH6643rg0QYLZACAQp2am9Bp
         BvdA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795069199; x=1795673999;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=xoCndVwrvCSfCd0BaHKCqL9ELaacWGRyWSDCytAWBDI=;
        b=XUPNcwN6IqNlH/ZihAoEVIVh/Dj/hV5/cBgXnC0tnTQtSrW9g9wIhXyCEigiATyMDF
         smoRlGoe7lYiWTe4wt1TKbN3QO8wIHaNiKzvNXrezHGNXGzj59h20jhDymrM+GlQyxjp
         AHybx1q8wJ8mPrRpzq8uWdx4fcYTjt7u5d+cPC3PU9jb4okzveJUDmP6+c4d9/YOvLfz
         C9dk78DDSfQfcKSLSkXD3Jk04iwuWqiYjfnXg3rPpS4rpz7BjcbvJmYUeT6VnI+qwyor
         8zMxYncnzmXRPhHYBfTbxL01Q9BtShtkABu4mnsKzjlwP4vdd6Rd/Hqk8Q8Rb3uRnLvS
         EmJg==
X-Forwarded-Encrypted: i=1; AL+hErGQSQ4vx1d5qLY02alnSI9PPJspBRD/utZpIkCizg/4SXV6pRFJV/fTxYEWvl1fyyo5wtG//xGsSBo=@vger.kernel.org
X-Gm-Message-State: APuU4Z9vBFAZ0eStgwMvyBmUT7NYsl5Jpr99hjg4ebhGDETleuZY2mBv
	yNJcUW9fMGnbUc4AdomRjlR24MgkOQ6d00RgA+IqjyKAC7D1kVenfyRgWqSi+XCjtmnLwq+JAto
	MioMxpQaKVOHGP8XoOtHXxyGEd1IFNZs=
X-Gm-Gg: AZFdTZeoZdlXZHSFkvb8Ot5pyoxo9ImB0qivOIxwNKsip3NwryR0YvxZepIOU2yCyg6
	G+SoN+rypp9tnstThj/QoAAQhKvUj2I9Pk8vX7GrkC8JaTp2vcJGTTwUbuYuftcNYoi4hSvjQb5
	9AUC2uBBF1b9KcooIA7JPL18GXQGuWJ//AcI312CEIzWALr1EN0j4Z6e+ITjSKxZm1uCFTqlHq2
	SQu844z4nTqsuLMn4tVI8fzN/xwQLWtJDqM/gXhLjylUz7sZYAPiO/PxzKkAe6WZFpDORqmK/OX
	P8bWMU/SpxJ72bdRV4ka0FucXUg96bL3eb25CZuDmKdKmyKSW5EsZEA5gO8jUO/GAOFQQJRUPXl
	senZge83ppIjnLVGcKwcx4vyaZJ+iZpHRNenEuA0J0Ht8PGjcVDKeFUWQft5P5skThkygRZ44rU
	2xTiWYMdrJndXloaYfbQ==
X-Received: by 2002:a05:6214:21e3:b0:91c:7a3f:f548 with SMTP id
 6a1803df08f44-92114f7d496mr80145356d6.49.1795069198906; Wed, 18 Nov 2026
 22:19:58 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: =?UTF-8?B?5qKT5bed5ZKy5aSq?= <inkxiao12@gmail.com>
Date: Thu, 19 Nov 2026 01:19:46 -0500
X-Gm-Features: Aa3M54oxphJvWdfM-fUHq_7nMxHgG-ail465DDEoF5yzwUuPEfq0cOpWCDpLL0o
Message-ID: <CAMcAce-4z6mGO70Bb32quoTj0aRmVERxPKCfb2VpY_w3wHjaRQ@mail.gmail.com>
Subject: [PATCH bpf 1/3] bpf: Replace DECLARE_EVENT_CLASS names in raw_tp_null_args[]
To: bpf@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>, anna@kernel.org, linux-nfs@vger.kernel.org, 
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au, ast@kernel.org, 
	daniel@iogearbox.net, stable@vger.kernel.org
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
Signed-off-by: BoBppy <inkxiao12@gmail.com>
---
 kernel/bpf/btf.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/btf.c b/kernel/bpf/btf.c
index 7e866bf..0044156 100644
--- a/kernel/bpf/btf.c
+++ b/kernel/bpf/btf.c
@@ -7403,8 +7403,8 @@ static const struct bpf_raw_tp_null_args
raw_tp_null_args[] = {
  /* nfs4 */
  { "nfs4_setup_sequence", 0x1 },
  { "pnfs_update_layout", 0x10000 },
- { "nfs4_inode_callback_event", 0x200 },
- { "nfs4_inode_stateid_callback_event", 0x200 },
+ { "nfs4_cb_getattr", 0x200 },
+ { "nfs4_cb_recall", 0x200 },
  /* nfs from pnfs_layout_event */
  { "pnfs_mds_fallback_pg_init_read", 0x10000 },
  { "pnfs_mds_fallback_pg_init_write", 0x10000 },
@@ -7441,8 +7441,11 @@ static const struct bpf_raw_tp_null_args
raw_tp_null_args[] = {
  { "btree_path_free", 0x100 },
  /* hfi1_tx */
  { "hfi1_sdma_progress", 0x1000 },
- /* iptfs */
- { "iptfs_ingress_postq_event", 0x1000 },
+ /* iptfs from iptfs_ingress_postq_event */
+ { "iptfs_first_dequeue", 0x1000 },
+ { "iptfs_first_fragmenting", 0x1000 },
+ { "iptfs_first_final_fragment", 0x1000 },
+ { "iptfs_first_toobig", 0x1000 },
  /* neigh */
  { "neigh_update", 0x10 },
  /* snd_firewire_lib */
