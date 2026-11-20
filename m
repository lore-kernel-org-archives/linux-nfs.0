Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795136518;
	b=sS9j9B3eVjIqxncfMA/WJuBm2//IcsoCSCNOi31jOKSbHZVCnbHF9ywJOhDkoSn0anJi
	 +7StvjwQe2hgjVk9I58XRMMEYhisdyYrO/opUgTAzdcJnxre2xMLrVDdDWkHc9KV/AsFE
	 OXbH8fg+f3IjN6j5vAx35LmpJ0kczwkqdwdFsdHBd7Y1hxFAEGR2on9oiHpH+Iv2gBGaM
	 C4FvrimC/dXDNRI9nob6TfqVi1xd1qQVNqiOo7GTj5E5Vw37d8c42GNaz79zkhPJhRpZ1
	 rGm9pTPLioeOAq0kyv9a8UxKK3JqcICZCo5KkScL0wEroY9KVwy+vs/XfJFUpfC8VjA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795136518;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=OhPe+g/wFECUj8BdAJSi2kD3+SaqZrvUK/aeFvZSASo=;
	b=GS6doKEtOQXT2z8lMnN07Ztm3s1wZ2SoQn2t1Xek/xYjOgTaKtRgDIvoy9Y075aDUckz
	 miMb8uZyy+GaGz8nhEDG/eTlTZ1rIa530ft8PVqndI6hsZH7S0g1/hpHDg4pemxUFzsDn
	 Dv3XbxrrJxqjb/Xpr4T89RgjHMjkZ3XVYikxZyMGk2u5I8Q8AqSi/aaLJdbduF9u2e7iP
	 qVd+21VBasCRXENMGyXOhkKKcqYttmk1hykoltWOS6PfYOjSnsn0k0bLOo7wgL1fD33Wk
	 RE+tovhYDfwmc5yPCEk5TkiT58B2G3/lnTDa2rPbdUxpKGhrsOIbcB8qkMeEAOmfXKQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Pnzs6FaQ;
	arc=none smtp.remote-ip=209.85.161.41
Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5024B606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 01:01:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5024B606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Pnzs6FaQ
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-703be215729so180083eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:01:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795136517; x=1795741317; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=OhPe+g/wFECUj8BdAJSi2kD3+SaqZrvUK/aeFvZSASo=;
        b=Pnzs6FaQIhwsQ6m/kMHODMekqUbDjza3TXUMvK2TkvzhoiXs3qawpG1BGEij0CpQXA
         wayQpxJvLqGqFm6rVkHHx1HUQyzwuSIaODBu3j6Wc60Xf9t4Iff6uUlEGGyHhZ9zaRNp
         UIHKLam+E+BK940vXwv3KUsTtkuO3s/ppFQ+gZSnD4Wt+cRAErldcsQG22+o/n1NUxBQ
         K2ciAld8AfkU91jOWW1puLkoxJX5hC9RVQ51GMRVMb6VA9njPPlw2GZdjoNhk38hBC8Q
         RFZJii+nueDRCVS5RQEkAXp+j2D21mVOlwGsZzaMr01dJQReVhqKrocHVfRuyvWW5FXc
         PK+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795136517; x=1795741317;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=OhPe+g/wFECUj8BdAJSi2kD3+SaqZrvUK/aeFvZSASo=;
        b=K179kiaRTQrxZVbaymT3hR9eokHKIDSYL3saVQizRf5/4d1zF3xFs9VdzAKuxDgzt7
         PdLGssUsd9VxPnNvE6W4FSp76Prux3wTrBQH9CqYrQ3C9EM4qrRBYPNPx7KBpOEb076n
         cd7DRutUd5Npur6VOKW7wQr3W7NMIlEWQJ9mdr8dDkVnnsW2UE7iepQfaKgHKL1pd2ep
         T3E1+Fm2QXPLroFpQPq/E3FZmYjqNIbNjPhks8METLpdgWKO9qkfRTmhnjko84FnbLIq
         11RugIYbASwe9DcBv5mBvBQ6VaBYqMc8KLbEvWq8LtFj+zMXLtSfT3bcTmHKMPiXx+cm
         Xs9g==
X-Gm-Message-State: APuU4Z9UaHObaynjGg0xZthUaGzD19asb2sBwriOFPfEJptBjnDEQseY
	FOc1/JSmJyE78glG/t0w3Acyj6AhlZ6DMe1xENil4lbEaM+6698Bk8RZBfidW6hsnv4=
X-Gm-Gg: AYBFou0ulFGKrCFM2RcK32xzWgO6IDR9jfHS7+HQ/v8tr705UqbOrJq0s3RFzY04PMY
	PMfKnBKzzbbwN/whToBWICucHzT84vNegFRF6Zd4TaegIG7n/R5nTeR1ya7+Di1Ln3CAz0hesMJ
	iNnPcvyzTV1VW6Ry4UB4dXkZBoOmKsXCc3RVWyRsOik5AWz8raZjwmf3apg2RxnQ1Pe9Yxq3R1n
	DWAzbw3t0DkcN+8QeV7GB3iEz/60sMOXqhQ8AS/vWLkdTbsGw4UV1NJaoD6h1ua4prEzTJ5a1dV
	Bik/JrezCQ6AgxMc5VlH5QFttXEasp5xiycTtGAJgAndShp3M7gi82F6NmBWXLIDcIvWK6hqqk2
	QyD9KuC47c8wr8JDwDf+/LKcSRwUlTMGtVB9lbcc9u9gsPJWczF5YwINoZKSBBmGU9Z/1qVQOMu
	+02Zwxc+4UeepEwFlMA9hlsdQwB20AqX7eAquW1gVR8yjZMw8VLpL3hleHwS6X8CV0v5XomKg5Y
	WXUo0ZikaUnLG0rlxWPs1jugHRTk7x+Wv/MWpvXXFq6seiAungJJctuJlk8S0u5tgC4vN4hz/xT
	Y/p64KKT5BNAVk8Ge6RjTe5UmVN4n4iWsiSSGnC5V8hD3PJE9jSWmdY1w3bkA4j0Quod4JFrFHw
	ggbDtbF0uF4f3++Lq+vWUAQ==
X-Received: by 2002:a05:6820:a743:20b0:71a:e96b:d510 with SMTP id 006d021491bc7-71b39437af8mr987397eaf.23.1795136516917;
        Thu, 19 Nov 2026 17:01:56 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea818bsm1101995eaf.1.2026.11.19.17.01.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 17:01:56 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] pNFS/flexfiles: mirrored writes that fall back to the MDS
Date: Thu, 19 Nov 2026 20:01:51 -0500
Message-ID: <cover.1795136323.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

ff_layout_pg_init_write() can fall back to the MDS from a pg_init in the
middle of a mirrored descriptor: when pnfs_generic_pg_check_layout() drops
the layout segment, or when a mirror's DS can't be prepared.  pg_init runs
for each mirror whenever that mirror's list is empty, so by then the other
mirrors can already hold requests.  nfs_pageio_reset_write_mds() replaces
pg_ops with nfs_pgio_rw_ops before it completes the descriptor, and
nfs_pgio_rw_ops has no pg_get_mirror, so the completion sees only mirror 0.
The requests on the other mirrors are never sent or cleaned up, the mirror
array they are linked on is freed, and their folios never leave writeback:
the next fsync hangs in folio_wait_writeback().  nfs_do_recoalesce() and
pnfs_write_through_mds() also write to the freed array.

Patch 3 keeps a mirrored descriptor that still holds requests off the MDS:
pg_init returns -EAGAIN, as it does for a mirror count change, and error
cleanup redirties or requeues the requests with the flexfiles ops still in
place.  The next pg_init starts from an empty descriptor and can switch
safely.  ff_layout_write_pagelist() returns PNFS_TRY_AGAIN instead of
PNFS_NOT_ATTEMPTED for a mirrored layout and leaves the fallback to pg_init
of the retry.

Patches 1 and 2 fix the generic code that path goes through.  O_DIRECT
error cleanup releases -EAGAIN requests without writing them, so after
patch 3 an O_DIRECT write would report success with some mirrors left
holding the old data; patch 1 requeues them for the reschedule instead.
Patch 2 makes nfs_do_recoalesce() look its mirror up again after
pg_init, and stops nfs_pageio_complete() from sending the next mirror
after a failed pg_init released the layout segment.

Sashiko found the bug while reviewing the FF_FLAGS_NO_IO_THRU_MDS series:
https://lore.kernel.org/linux-nfs/cover.1795024981.git.bcodding@hammerspace.com/
These patches don't depend on that series, and the two apply in either
order.

Tested against a reffs MDS and DS with a six-way mirrored layout, on a
KASAN kernel, with client fault injection that fails a mirror's pg_init
while other mirrors hold requests, fails the pg_init that a retry runs
during completion, and fails a mirror's DS setup in write_pagelist.
Without the series, fsync hangs in folio_wait_writeback() and KASAN
reports use-after-free in nfs_do_recoalesce() and
pnfs_write_through_mds().  Without patch 1, an O_DIRECT write returns
success while five of the six mirrors keep the old data.  With the
series, buffered and O_DIRECT writes complete, the data is on all six
mirrors, and KASAN reports nothing.

The series is based on v7.4-rc3 with three flexfiles fixes that were
posted separately for stable, and also applies to v7.4-rc3 alone:

  pNFS/flexfiles: read the layout hdr under i_lock in pg_get_mirror_count_write
  https://lore.kernel.org/linux-nfs/23435d398481f51ce2680053cd3a151fe673f91c.1795108831.git.bcodding@hammerspace.com/
  pNFS/flexfiles: don't delay or restart an rpc_task that LOCALIO never ran
  https://lore.kernel.org/linux-nfs/9c46fda0f2cd6d3843b198dac304b4722514b8e3.1795108831.git.bcodding@hammerspace.com/
  pNFS/flexfiles: restart a write that the DS error handler retries
  https://lore.kernel.org/linux-nfs/8ee107c9d0c68b6d0ee7305605ff7edbe0ffa160.1795108832.git.bcodding@hammerspace.com/

Benjamin Coddington (3):
  NFS: resend O_DIRECT write requests that error cleanup gets with
    -EAGAIN
  NFS: don't use a mirror after pg_init can free it
  pNFS/flexfiles: don't switch a busy mirrored write descriptor to the
    MDS

 fs/nfs/direct.c                        | 48 ++++++++++++++++----------
 fs/nfs/flexfilelayout/flexfilelayout.c | 48 ++++++++++++++++++++++++--
 fs/nfs/pagelist.c                      | 15 +++++---
 fs/nfs/read.c                          |  3 +-
 fs/nfs/write.c                         |  5 +--
 include/linux/nfs_xdr.h                |  3 +-
 6 files changed, 93 insertions(+), 29 deletions(-)


base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
prerequisite-patch-id: 71097d575f7ba74684462ab64b028ff8815dff63
prerequisite-patch-id: 5a73a1fb9d47a31d4ec337ec0264eadbcaa9fd4e
prerequisite-patch-id: 2663ab8e1949d6a11d957cc2784161bf2816cac2
-- 
2.53.0

