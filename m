Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C68F471CE4
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 20:27:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787776024; cv=none; b=oLLXTvc1N4JkVAomRJNG1jWJ2PLHKWY7Bg/ADawk4iISw4u+lEGzsN0H3oro7n9hRXKucb5FsAq9DVzcu4NTDg6g7OOPixa0JMLVMZWjFF55Tl7Tj1pDnVtRiXFu0bFOiTrCq7RkNxsT6LfjVgj0CbTcYXo42+Jzw+oPMXHuGOw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787776024; c=relaxed/simple;
	bh=v5q2CrK11HvGT7c12WqSYTZO19dUCuJ/frAdywtlb0c=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=iLy9q7xlm8GgGv2Jz2Ic519SXrQWJl1aYJFqI1vTsKvH32oy//HuYHaY5uUB282/q1dwTrdAjZHKT1Dv+OS6mYOTObIjrich7qvy8gS0RDFMap49T94NzseCJjoNz7ePQLzZ1+hxwf6ouLBt66noKWk04fXrre+DaGQV5GgnmWA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eg09N9qj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eg09N9qj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 349F41F000E9;
	Wed, 26 Aug 2026 20:27:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787776022;
	bh=SUxwBBUnMq8e++vQll8SP69lAXB1bUoIVsi4Z3zBTgw=;
	h=From:Subject:Date:To:Cc;
	b=eg09N9qjGY0rheDtplwCwyuQdrAK9IOOkjwl38TpDe80Xa8KLG+EZo98HVtGrLIBN
	 WGi2RBN/3XZJntKi5y+L90NEr+mEbthuYnUHFfg/tYxDaZ71drvkdSLA+iZ9Cn6HHK
	 pAsvHBycniEH0WJRiADO43YI3GeGEEubmTc+CSCmV2OI5ZvGU76cjBVEQ98EZ/O7Kj
	 /ksTE5gFR+Y43cRyJn/vCrk0wv96imG6VQBGg4+0KgtdIa/P7RllvHpKXPlQxqUL+L
	 auu7HYx385UIMK+VzSYjhXSaIEHrB4jGWHu4dqaF79Te0sGBJdK0bjbE8CbxkHz64s
	 Md+DPymk610tA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/7] Implied-ACK eviction for NFSD's duplicate reply cache
Date: Wed, 26 Aug 2026 16:26:50 -0400
Message-Id: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMyw6CMBBFf4XM2okVHyT+inHRDrcwhlTSKUZD+
 HdBl+fmnjOTISuMrtVMGS81faYVDruKpPepA2u7MtWuvrhjfeZ2GgcVX8AZ4/Bh8dKDo4topAn
 NyQmt7pgR9f3r3u5/tik8IGWLbY/gDRyyT9Jvk2DYp2gtF1jR1NGyfAGKsHjCnAAAAA==
X-Change-ID: 20260325-duplicate-reply-cache-f0fe7c7b740c
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2350; i=cel@kernel.org;
 h=from:subject:message-id; bh=v5q2CrK11HvGT7c12WqSYTZO19dUCuJ/frAdywtlb0c=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqj0wM7YO3+eTB/6jGwzXULVcSg+TdFxd1ck0hw
 cuRdMY4uPGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCao9MDAAKCRAzarMzb2Z/
 l7iUEACY4cRPZ8vWg+3BUKKpq7L5Jw6ujVrC8tPSH8OhGeZ8UFJSUv/ysk/R37C2rp73h7P1uo4
 acq4T3KdzwWTVJyXbxdJZjrAnhhf5KWJvkidVIs0wJoK5deroPFsYJJICeVYkq/MMHpzYr9FGcZ
 5jhUg32uEzF/EGgAEQKhXdM6PkFiUjW0meRcadLlZVL+9lwlNNfb/ejoLSB3feikyg88VIgIwMK
 ljO8XHkprtBZF+9RAODChGsr62+BNlFIeFljNU86RLtXrgzG3Xs3A4FODtecnFFtc6+H7GUMGqp
 DSsbqQNpSorRy1MoYooorABmO9LfrleYIZEtnO2/ANo2uH7f06o3UNdJn2s0W4oTwHFoj/HEJ24
 uRqWEq/W9Q/CH8LC7cxhOPxfwhhKRcV7St9jnU4siU5OBlTd+vMXG2TpACbD3SwTMA44Fb0z9Xu
 L/+EHH2LCP68Kt/l/L2ZwOjl6/0KQf43zpgp3c1ovATyvJOTlJxsl491Jg1Zz0gUs0yIRnuC8ZU
 /qD8kLTQ0SEzjzjIWABdWrjbmJAcXeaoyhP0TmdNLgY16iQK2fMYL5PvysnTZ3Swkq8l/Y1/4T8
 DZT7ZzT9y8sF/rk5qndtq5nAvxM+aL2n+voA9mk5PIwGjZon00Hogk2CzGK/i4is/y+GOz6xK/D
 AKTpRet/dPEn6Fw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Connection-oriented transports (TCP, RDMA) guarantee in-order
delivery: arrival of a new request proves every prior reply on that
connection has been received. This series exploits that property to
evict completed DRC entries as soon as the next request arrives on
the same transport, rather than waiting out the 120-second
RC_EXPIRE timeout.

Each DRC entry records its originating transport. A new
xpt_last_recv timestamp on svc_xprt marks when the most recent
request arrived. During bucket pruning, nfsd_prune_bucket_locked()
compares the entry's timestamp against xpt_last_recv; a newer
value on the same transport means the reply was delivered, and the
entry is evicted immediately.

Profiled with "perf record -e cycles -e cpu-clock -e LLC-load-misses
-e branch-misses" during an NFSv3/RDMA 4KB random-write workload.
nfsd_cache_lookup overhead dropped from 1.53% to 0.76% of CPU
cycles. The rb-tree operations (rb_erase, rb_insert_color) that
dominated LLC cache misses fell from a combined 13.2% to 1.1% of all
LLC-load-misses, because shorter-lived entries keep the per-bucket
trees small.

---
Chuck Lever (7):
      SUNRPC: Assign a unique identifier to each svc_xprt
      NFSD: Track transport in DRC entries
      SUNRPC: Record last-request timestamp on svc_xprt
      SUNRPC: Mark connection-oriented transports on svc_xprt
      NFSD: Evict completed DRC entries via implied ACK
      NFSD: Add tracepoints for DRC entry eviction
      NFSD: Record DRC population in lookup tracepoints

 fs/nfsd/cache.h                          |  1 +
 fs/nfsd/nfscache.c                       | 88 +++++++++++++++++++++++++++-----
 fs/nfsd/trace.h                          | 49 ++++++++++++++++--
 include/linux/sunrpc/svc_xprt.h          |  5 +-
 include/trace/events/sunrpc.h            |  9 +++-
 net/sunrpc/netns.h                       |  4 ++
 net/sunrpc/sunrpc_syms.c                 |  3 ++
 net/sunrpc/svc_xprt.c                    | 54 ++++++++++++++++++--
 net/sunrpc/svcsock.c                     | 41 ++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  6 ++-
 10 files changed, 222 insertions(+), 38 deletions(-)
---
base-commit: 3a4d7c7c9466a07fa4176ce35180149709d92c22
change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c

Best regards,
--  
Chuck Lever <cel@kernel.org>

