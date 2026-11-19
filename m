Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.219.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795069247;
	b=g85Go007OUA8l/Q5rRMl18ew3S2JWXiR5o9c/YWGSslwJpq9jiPuCHynwEk7qcnoX6uX
	 SLDGyb+bWKSFv3w27pLjZP5OKMqyBXGeDkmRXngodWyGxn4DorN5uCi6+md/Or7wpDX2k
	 dOFg9A6O72j7OzaZSL8ix/WAuGUx+mVnmSV8jWhixggdlVvdd3QJPPTRktqkF7wJNBQbZ
	 iCtpzCPoQzO9kbpUExFnNkDapqCcg+OshcnmMUEXXLdqeXOHeXjMg3aUML5+8y2qSWPPg
	 JcBG3cl+kE6J9yVhDIhOhsccPTe634SGjp9CFJeob5DqlQxP8v08rqZGs5lBgr3SdVQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795069247;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:From:Date:X-Gm-Features:Message-ID:Subject:To:Cc:
	 Content-Type;
	bh=R72tSyuvoCt5/QGm7uguOsGtVeCA2C72cLraw6uBskI=;
	b=eOZGTKL0qs5hvGeEosdWyFtVd3vddykQcUEA4PYvbWMV6QUW7fHtmsY6QXKO0aOFs4lu
	 nQHSFXlEtTveqRao8XtKg+vB15qSzMpWscifa9sq4Fw0s8h699b548RogGQ76v3HRc0Mh
	 KcA7R8JWh9zC6/GQ3znET5+FM5hboLKSr96j/XCOZqnoMBlXCehx18AROqr2IFIwmu+5Y
	 yBigT/B2ucAeUSDKVbtCPdTJHV+CX4rIdTwWmq/HsQVpMppAkd2JzWKxrcRZVNReG5sas
	 fFD76Y161tuD6lIYJ25Kbmt3fm9IzQwfmBgpPFZFEoz6NuzkAA4A9z+qVRKN5RpMCtw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=K3oxpHUL;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.219.50
Received: from mail-qv1-f50.google.com (mail-qv1-f50.google.com [209.85.219.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A48A8606A325
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 06:20:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A48A8606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=K3oxpHUL
Received: by mail-qv1-f50.google.com with SMTP id 6a1803df08f44-921276742e3so4308786d6.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 22:20:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795069246; cv=none;
        d=google.com; s=arc-20260327;
        b=WLJyxX5+b1+JUafUON0IL8n/jRO0gevA2ucvMwD8cFHLUXPdmmyhWUU+tymmaasuZY
         po07l7qztjvztU0p1YPzk7nxU4n/UduJadOO0l9mwVYdU7JBagUPPJAf9CTl5luU3iDc
         wb2FhMjWWlxGeBxuFupldjhPvcfIo5khHMzEaWubApIKMP0F5z3rheZ5XbNQQ92A8isX
         gUU2mroWYwMBmtfVSp18adA+T8wESdfgyWY16FRRRcusS8LHDmSgeuRokMe8a8AaR/J6
         ZElK/0TKnTpcEei0FjrhckVFFe8bbDCCKrDngmT/kVSXuJiw1oyITyz35nn2MdBi45la
         QXXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=R72tSyuvoCt5/QGm7uguOsGtVeCA2C72cLraw6uBskI=;
        fh=lVyEV1Sr0WF3UiuiSO29iVD42H3od/olcUnrz34ZyXs=;
        b=a0CxnFQCBmSCeeOefpNeFFj6+u5znf7xeFq3PqTf3QMqUSZUUXgfTbTaj5AjdNAnMY
         YF7umk/6EkGHPMw1P0dmJop63EzLJJ05pPmJWvR5L/XLYF9v0sBaKpBnbfH/gG5C1N1A
         voG8PUFsQsjus+sg9VTHGOCuVvcFbxOmR5comCbXJpk1w+0RVHWyaMb5JhuVHqriY6xi
         QfJPON7oFH02ui5XhoEg1GT3lzqKO3AhW8sSq5cm1TN9MGpkI2XPB6SYO1bQnumnirr+
         7IVUNLuk/tAF4Du5oCBZo01HFtP3KnoniFCSmYohEPXN59H/rP+G99HcWjduNbZTjViC
         k4Dw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795069246; x=1795674046; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=R72tSyuvoCt5/QGm7uguOsGtVeCA2C72cLraw6uBskI=;
        b=K3oxpHULF4L+vV1q+0GdTBv3uOvLHlttlMr7OApOglNWVl+Zu9hnmsfBh8ArpL5nos
         0Cp5+2skbP0ZCKEDEDLtPxweHy1c/1NSt6N68MGuiUtoCU/ddPCHUsx5Pcx+AJ5lx3l/
         4f7UJPrMJgYaPHi3y5ZzjqrX8tNmwRvhBoc5WTpy4NoLLVMEo0FHTyqgMPrqR/R0J9XI
         fJRVS6H1aLtMQwDm4aahimGeHRiCYiipcu0FD0Ll6DtrvUvcqhq9gim+3Y0YzSNYYenN
         Xh0uaI5/fA8UB01kXzaOOTmXD9Bc97UfjMZ5RrjNmn9ReLJHBkhF4ykhtWf4pNu6tD6c
         MtDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795069246; x=1795674046;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=R72tSyuvoCt5/QGm7uguOsGtVeCA2C72cLraw6uBskI=;
        b=YTCy6FeHyZdS3ahgKd/1FSKYdq+v3Z6TBWSZt7yLgTKPODQj5WY2JgWpcX17L3hEqx
         M/mIyL3A38HunxXyAPCAQiKxAdYbcgt4defrS5gofkHk0mt2RX4BbKqTSRZY1Cf30uOW
         FVBlc0GerRrcqqmtwGvcqux4BC/dy0uDKi0l4IxGX5YPKZh01DZnqrpfZqcdF0ZAEFp1
         arFUzEQi42uOfCbaF94Wi94qSbhc7FTcNwNqjrVMUBjEpBl0lR4HnEUtYz6tmFOKhJYE
         1IvziZSlFL49u521DflPrWREgIkxgZbsLUgcoDMq0RbxkLOmt7t7zAHVPc1VGIUYQmzm
         +qIA==
X-Forwarded-Encrypted: i=1; AL+hErF0CjbInXWi6LUn4EYX9Rog0ZKh/IZ10bACA5xwNZQPjRfJ1Yz9+yPxJFWKYr0Uu8Gwd0rvqvoYxhw=@vger.kernel.org
X-Gm-Message-State: APuU4Z/wA3eW3DgHvh/qECwoei+74FimDQlhRTjMDglaFololIIceRAO
	qb75ySjYAeSyJq/y8H6G8DL0ZZWzfJyTND/TSZQWAUHfVF3rFUP+MTuCfioGdUWw8A60V2LL8pu
	nxhRuBnEjyq55OKvVDY0Vd6W8nrdfghk=
X-Gm-Gg: AZFdTZd8fcN/PPEuPQZ4Dn/xZRVVHhrWCNTJGQ0i2p7MIT+3wZEgZSei6wqtRXzIGcH
	ylO7syU4UxpgvgvZSbL/RerQSf4reeCGy2tJRz+Oi1G3dMfbzUiEX3Tkr3jtaoOw6EJWdvgExcA
	T9bougbosAi0fPlrl1JYAVGDugP9ThYiIvgxzF78rmrHNUVjYBA7Y8A/WG/2sbIayvZdkiZBAo2
	v8xXZk/8qopDmwSMHHOoxvlxNekCuHNVjWVExn7ngY/YLCJCin+KlujXUIRNRbriQZ0uLmme4Ey
	itfXOUwP4XISv+oKIwvKpM8nXY/xNzBOF4wjr3OjhPDU3AfLJQDKcj5BqUBpMwTu2dCDeX7uoZ8
	8BjMqhzTROxOPC6OE1Swl6KBYKFREJKASY1qJHc7xMeQ7F6BQa2cL8gz+C3tTgJLyZDSq5VAu/W
	pf11HxJnckLg6JkjoSLw==
X-Received: by 2002:a05:6214:8010:b0:921:18e2:4b8 with SMTP id
 6a1803df08f44-92118e205f4mr59170016d6.12.1795069245648; Wed, 18 Nov 2026
 22:20:45 -0800 (PST)
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
Date: Thu, 19 Nov 2026 01:20:34 -0500
X-Gm-Features: Aa3M54peGcZ3HW3rbZ6EtpU-sE3Eis0PWV29zDNE9SCTxw0n7cbFv5MbYn1qN6c
Message-ID: <CAMcAce9pi3BwKUAdsfx8GFwMMFx-=-UkkUkqsCDOqbwaL9eSxA@mail.gmail.com>
Subject: [PATCH bpf 2/3] bpf: Fix missing raw_tp_null_args masks for NFS and pNFS
To: bpf@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>, anna@kernel.org, linux-nfs@vger.kernel.org, 
	ast@kernel.org, daniel@iogearbox.net, andrii@kernel.org, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Audit of NFS/pNFS tracepoint callers against raw_tp_null_args[] reveals
several missing or incomplete argument masks:

  1. pnfs_update_layout (fs/nfs/nfs4trace.h:1990): raw_tp_null_args[]
     currently sets only 0x10000 (arg 4, lo), omitting arg 5 (lseg).
     fs/nfs/pnfs.c passes both literal NULL (:2166, :2177, :2337) and
     ERR_PTR(...) (:2205-2206, :2300-2301) for lseg. Set 0x200000
     (0x2ULL << (5 * 4)) alongside 0x10000 so btf_ctx_access() marks
     ctx[5] as SCALAR_VALUE, preventing both NULL and ERR_PTR
     dereferences even behind a NULL check.

  2. pnfs_mds_fallback_pg_{init_read,init_write,get_mirror_count}:
     raw_tp_null_args[] sets only 0x10000 (arg 4, lo). In
     fs/nfs/flexfilelayout/flexfilelayout.c:1225-1231,
     ff_layout_pg_get_mirror_count_write() returns early whenever
     pgio->pg_lseg != NULL, so trace_pnfs_mds_fallback_pg_get_mirror_count()
     (:1228) unconditionally receives arg 5 (lseg) == NULL.
     pg_init_read (:1128) and pg_init_write (:1201) are likewise
     reached when pgio->pg_lseg == NULL. Update all three to 0x110000.

  3. nfs4_cb_layoutrecall_file (fs/nfs/nfs4trace.h:1520): absent from
     raw_tp_null_args[]. fs/nfs/callback_proc.c:262-267,320 passes
     ino = ERR_PTR(-ENOENT) / ERR_PTR(-EAGAIN) as arg 2 (inode) on the
     out_noput path; TP_fast_assign (:1546) checks !IS_ERR_OR_NULL(inode).
     Add { "nfs4_cb_layoutrecall_file", 0x200 }.

  4. nfs4_test_delegation_stateid and nfs4_test_open_stateid
     (fs/nfs/nfs4trace.h:1119-1120): absent from raw_tp_null_args[]
     while fs/nfs/nfs4proc.c:2910 and :3003 pass literal NULL for arg 1
     (const struct nfs4_lock_state *lsp). Add both with mask 0x10.

Verified in QEMU on x86_64 7.4.0-rc3 (20eef29b7c84) and 6.12.118
when CONFIG_NFS_FS=y and CONFIG_NFS_V4=y (all reproducers flip from
LOADED pre-patch to REJECTED post-patch, including pnfs_update_layout
and nfs4_cb_layoutrecall_file under if (!ptr) scalar enforcement).

Fixes: c83e2d970bae ("bpf: Add tracepoints with null-able arguments")
Cc: stable@vger.kernel.org # 6.12+
Signed-off-by: BoBppy <inkxiao12@gmail.com>
---
 kernel/bpf/btf.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/kernel/bpf/btf.c b/kernel/bpf/btf.c
index 0044156..ef10af2 100644
--- a/kernel/bpf/btf.c
+++ b/kernel/bpf/btf.c
@@ -7402,13 +7402,16 @@ static const struct bpf_raw_tp_null_args
raw_tp_null_args[] = {
  { "nfsd_file_cons_err", 0x1 },
  /* nfs4 */
  { "nfs4_setup_sequence", 0x1 },
- { "pnfs_update_layout", 0x10000 },
+ { "pnfs_update_layout", 0x10000 | 0x200000 },
  { "nfs4_cb_getattr", 0x200 },
  { "nfs4_cb_recall", 0x200 },
+ { "nfs4_cb_layoutrecall_file", 0x200 },
+ { "nfs4_test_delegation_stateid", 0x10 },
+ { "nfs4_test_open_stateid", 0x10 },
  /* nfs from pnfs_layout_event */
- { "pnfs_mds_fallback_pg_init_read", 0x10000 },
- { "pnfs_mds_fallback_pg_init_write", 0x10000 },
- { "pnfs_mds_fallback_pg_get_mirror_count", 0x10000 },
+ { "pnfs_mds_fallback_pg_init_read", 0x110000 },
+ { "pnfs_mds_fallback_pg_init_write", 0x110000 },
+ { "pnfs_mds_fallback_pg_get_mirror_count", 0x110000 },
  { "pnfs_mds_fallback_read_done", 0x10000 },
  { "pnfs_mds_fallback_write_done", 0x10000 },
  { "pnfs_mds_fallback_read_pagelist", 0x10000 },
