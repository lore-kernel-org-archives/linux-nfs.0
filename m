Received: from mail-yx1-f43.google.com (mail-yx1-f43.google.com [74.125.224.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 59DD63BF682
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 21:10:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.224.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787001023; cv=none; b=cTDAte9quqJlcty6pOPsRoX4H4u3xI+4nTrq92TSgVKiOPczCsh3W+Pw0ASSjB7KEvFKWIc0b7B9MGbiQT6bgPX6d4vL9K+JFZAaWVlirDG2Mzv0b9f5QF2PC//oUNw4lMce0jrslRmk+wqQ2wx4pY0ritQ3uj7AgOB76aw4ie4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787001023; c=relaxed/simple;
	bh=9n36HTH3aWNjmHlpHpNL+Yc9siD++p5wkT/OskyQ+WU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Z2fFes1ismGrTtG538Zyh18OJAgLfy4HvFD89i2saVWgvKkbubKLyHNFRri0hJ8w2TrpnOIr1l05mEVi+tnfQTu2lFgajOlZo07zMO7zBCM68mGdPeb1219l0Vy0RjkdDYL5pTZ5rKVmJqmohk2MM/QNWQzrLjLU/g7orSliOoo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=ioeoFS9f; arc=none smtp.client-ip=74.125.224.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="ioeoFS9f"
Received: by mail-yx1-f43.google.com with SMTP id 956f58d0204a3-66cad42593dso1366521d50.1
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 14:10:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787001020; x=1787605820; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=hzSh2/I0Brxey3YvJbYrC+EaMekGCLHW+FjEIkhA5VY=;
        b=ioeoFS9f8GMaF0Imudok+RstFWb8RVWI6bc6aIlR4Hll/aqIP2rkRGBG0/16au2mYh
         m255tebLQFbZI6AjqQIXKhizpufspygnQdkLT8UXJAEgLeJukRoAzCgMfUZjPU+mvzJj
         61EMRWUXjMmQeuaqIQFYuN8KLErautN/GM42kVdH1SlzkJx6abIvsl6F9IS6Z96eKT7U
         xQzO6myhzG2owkxrHLfVb+yrad/+Hde2Gpgu+y0X3QSDHwe8slVoIawPx/pyqRHido79
         hJ+aL8aH/xMpO9rqm0zjNc7BwgbtXWRR2UH4QNwaVflcMC45HVWQuKDR8yfm1UcH7Oqb
         bDEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787001020; x=1787605820;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=hzSh2/I0Brxey3YvJbYrC+EaMekGCLHW+FjEIkhA5VY=;
        b=sUJUyQIejcwOO4hpN7X70TaiSxaQICJEy5VXkVwtSIR279hSP+fVxW0Ag3Vnb+4s5s
         2SqPskpLplJpFP57ljo6SAd2wi2Z0b5jZQah4o0ePIRqcEYsiwvucnwH7qLVaj/1uk+L
         fTsotk4pnwojG+abvk+0NYS/k3oTz7qH9p6n6B6mviyFpBLKUiBTgUFAazQai4j8eipV
         lxtUQSz9M5w/x4vxeskVwiDNoDQnvBBT7xTVByxlVrdIy5OgVMqMvH+SIeZwGduXNNg1
         grfMeUHW1CG+s7CUHlEU9dPI34D/o3od9ynSWc+M3PMd0t3TgqvYM0uX9gX7piYfI6T1
         RFkg==
X-Forwarded-Encrypted: i=1; AHgh+RpAHv5hhW/F/vhYGnnXVbp0dwJyYjv1iSs1fNPrYMkSAQ4+PHua6myPjRJW0tseAKdmEnrP/hqG5Zs=@vger.kernel.org
X-Gm-Message-State: AOJu0YzT1YEOpUdK2/gT1hNrHPXtB48Wh3ivHM190p8gPz3bZgPrTkiq
	wEj4aOVgfL7MRAanLw9jpisOOVihjCpzbQ43ADbPsw9Lj2DWW8YtwISIgz2GaibmRg==
X-Gm-Gg: AR+sD109Jr2AXLfUKMs++GdI5Pzt76zR9mUZZFcLJS3R7Kr3fOx27vOEROgPVCcbB4p
	lF+IrmR2XQH0yk+Cm9bpegsT6ofx/zmQpQ1uOB6BjiANNwNPhS+drfV16x999Wg4zq9c5JcNPPE
	3MlX3jswRJ/8mrEloiGVhWdhqmlFjTSHn0R7OfODZdNhWTemEm/VFe307qLGMMzD5Xu/B9iYBZK
	MHaHubBFG0PD4ollk46M9VaEfoAHvjtDlfC0teTMUSELpirDDHZ8r7mT5l5bJLTWZRcDhavJkdH
	f8Becd5GqMsIOES+THPeYrdRlGhxiO1o9RiK31Nc4aN/34Q0IEPz4YDtLd7XazaOQUjzCiCnOO4
	dYykU0rBgqpniwNJtjslYf9o/IxB2/BvLvfjiGhjWqxnpubrBUAFb6Z7QTR22e0JKD4RlLbITiR
	RIWCxsfIZIwpgpwmkzBcfg0cSEr02LZlPA/lbXYCx4
X-Received: by 2002:a53:d90a:0:b0:668:84cc:7426 with SMTP id 956f58d0204a3-66c72c01c4emr7129562d50.24.1787001020031;
        Mon, 17 Aug 2026 14:10:20 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-840f25bed4csm9533557b3.29.2026.08.17.14.10.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 Aug 2026 14:10:19 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com
Subject: [PATCH 2/2] SUNRPC: Recycle sent Reply pages instead of freeing them
Date: Tue, 18 Aug 2026 02:08:11 +0500
Message-ID: <20260817210811.3984663-3-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260817210811.3984663-1-ameer.hamza@truenas.com>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_rqst_release_pages() drops the thread's reference on each sent
Reply page right after the send, and svc_alloc_arg() bulk-allocates
replacements before the next RPC. Socket transports send with
MSG_SPLICE_PAGES and hold a reference of their own until transmit
completion (UDP) or until the peer's ACK covers the data (TCP), so
for a Reply built in pages the thread allocated, the last reference
is dropped from softirq at ACK time: ~257 pages per 1 MiB READ on
4 KiB pages. A Reply spliced from page-cache folios is unaffected,
since the page cache still holds a reference and nothing reaches
the allocator.

Since commit 574907741599 ("mm/page_alloc: leave IRQs enabled for
per-cpu page allocations"), alloc_pages_bulk() holds the pcp lock
across the whole batch with IRQs enabled. An ACK-time free landing
on that CPU inside the window cannot take the pcp lock, because the
free path only trylocks, so it falls back to free_one_page() under
zone->lock. The allocating CPUs then refill from the buddy more
often, under zone->lock with the pcp lock still held, so the window
lengthens and the next free collides more often. On a single memory
node this settles into a steady state with most CPU cycles in the
queued-spinlock slowpath. Commit a39f0ce0c9da ("Revert "svcrdma:
Use contiguous pages for RDMA Read sink buffers"") describes the
same terminal state.

Remove the free. svc_rqst_release_pages() now keeps the thread's
reference on pages the thread allocated, parking them in a small
per-thread array, so the transport's final put_page() no longer
enters the page allocator. A parked page refills a free slot in
this thread's buffers once folio_ref_count() reads 1, whether that
slot awaits a Call or a Reply. That is the gate the network stack
has applied to its own ACK-timed references since 2012, today in
skb_page_frag_refill(). Releasing result pages was discussed in
2021 [1][2]. The array is unordered and each scan resumes from a
persistent cursor, so pages still held by one slow connection
cannot block reuse of pages parked after them.

Reuse is opt-in per transport class and only svc_udp_class and
svc_tcp_class declare XCL_FL_REPLY_PAGE_REUSE: on a socket, every
consumer of a sent Reply page either holds its own reference for
as long as it uses the page or is done with it before
->xpo_sendto() returns, so a reference count of 1 is proof the
network is done with the page. A Reply that carries spliced-in
folios is excluded, and a page is reused only if it is order-0,
unpoisoned, not pfmemalloc, node-local and not page-cache-backed.
Otherwise pages are released exactly as before.

A thread holds at most enough pages for four maximum-size
Replies and never more than 4 MiB, so a 128-thread server holds
at most 512 MiB. A surplus is trimmed as the thread's own demand
falls; a thread that stops serving keeps what it has until
traffic resumes or it exits. For comparison, each svc_rqst
already pins two arrays of rq_maxpages pages for the life of the
thread, which is of the same order.

Measured with this work backported to 6.18.38, serving 1 MiB cached
reads to eight clients over NFSv4.0 from an ext4 export mounted
dax=always: cycles spent in free_one_page() fall from 43% to nil,
and page allocations per page of payload served from 2.97 to 0.05.
A tmpfs export with nfsd_disable_splice_read set, which reaches the
same path without the previous patch, falls from 33% to nil and
from 1.98 to 0.05. An ext4 export without DAX has no such free to
collide; its free_one_page() cycles and throughput are unchanged.

Link: https://lore.kernel.org/linux-nfs/87im7ffjp0.fsf@notabene.neil.brown.name/ [1]
Link: https://lore.kernel.org/linux-nfs/161400740732.195066.3792261943053910900.stgit@klimt.1015granger.net/ [2]
Assisted-by: Claude:claude-fable-5
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
 include/linux/sunrpc/svc.h      |  14 ++
 include/linux/sunrpc/svc_xprt.h |  14 ++
 include/trace/events/sunrpc.h   |  32 ++++-
 net/sunrpc/svc.c                | 235 +++++++++++++++++++++++++++++++-
 net/sunrpc/svc_xprt.c           |   7 +
 net/sunrpc/svcsock.c            |   2 +
 6 files changed, 300 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2db1b9ec5658d..407558b8cbdc8 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -155,6 +155,13 @@ extern u32 svc_max_payload(const struct svc_rqst *rqstp);
  * [rq_respages, rq_next_page) after each RPC. svc_alloc_arg()
  * refills only that range.
  *
+ * On a transport that has declared XCL_FL_REPLY_PAGE_REUSE,
+ * Reply pages this thread allocated and sent are moved to
+ * rq_reuse_pages instead of being released; once the transport
+ * has dropped its references, they refill released slots in
+ * place of fresh page allocations. A Reply into which
+ * nfsd_splice_actor() installed any page is released as before.
+ *
  * xdr_buf holds responses; the structure fits NFS read responses
  * (header, data pages, optional tail) and enables sharing of
  * client-side routines.
@@ -221,6 +228,9 @@ struct svc_rqst {
 	struct page *		*rq_respages;	/* Reply buffer pages */
 	struct page *		*rq_next_page; /* next reply page to use */
 	struct page *		*rq_page_end;  /* one past the last reply page */
+	struct page		**rq_reuse_pages; /* sent pages held for reuse */
+	unsigned long		rq_nreuse;	/* entries in rq_reuse_pages */
+	unsigned long		rq_reuse_cursor; /* where the last scan stopped */
 
 	struct folio_batch	rq_fbatch;
 	struct bio_vec		*rq_bvec;
@@ -276,6 +286,7 @@ enum {
 	RQ_DROPME,		/* drop current reply */
 	RQ_VICTIM,		/* Have agreed to shut down */
 	RQ_DATA,		/* request has data */
+	RQ_RES_REPLACED,	/* splice actor installed Reply pages */
 };
 
 #define SVC_NET(rqst) (rqst->rq_xprt ? rqst->rq_xprt->xpt_net : rqst->rq_bc_net)
@@ -456,6 +467,9 @@ struct svc_serv *svc_create(struct svc_program *, unsigned int,
 bool		   svc_rqst_replace_page(struct svc_rqst *rqstp,
 					 struct page *page);
 void		   svc_rqst_release_pages(struct svc_rqst *rqstp);
+void		   svc_rqst_refill_pages(struct svc_rqst *rqstp,
+					 struct page **first,
+					 struct page **last);
 int		   svc_new_thread(struct svc_serv *serv, struct svc_pool *pool);
 void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *prog,
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index da2a2531e1106..73f9a8c9a6fbf 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -8,6 +8,7 @@
 #ifndef SUNRPC_SVC_XPRT_H
 #define SUNRPC_SVC_XPRT_H
 
+#include <linux/bits.h>
 #include <linux/sunrpc/svc.h>
 
 struct module;
@@ -37,8 +38,21 @@ struct svc_xprt_class {
 	struct list_head	xcl_list;
 	u32			xcl_max_payload;
 	int			xcl_ident;
+	unsigned long		xcl_flags;
 };
 
+/*
+ * A transport sets this flag to declare that every consumer of a
+ * sent Reply page either holds a page reference for as long as it
+ * uses the page, or is done with the page before ->xpo_sendto()
+ * returns, as sendmsg() is when it copies the payload for an
+ * egress device that lacks NETIF_F_SG. A Reply page whose
+ * folio_ref_count() has returned to one after the send is
+ * therefore no longer in use and may be reused (see
+ * svc_rqst_release_pages()).
+ */
+#define XCL_FL_REPLY_PAGE_REUSE	BIT(0)
+
 /*
  * This is embedded in an object that wants a callback before deleting
  * an xprt; intended for use by NFSv4.1, which needs to know when a
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ff855197880de..7f5c6dc5bb35a 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1673,7 +1673,8 @@ DEFINE_SVCXDRBUF_EVENT(sendto);
 	svc_rqst_flag(USEDEFERRAL)					\
 	svc_rqst_flag(DROPME)						\
 	svc_rqst_flag(VICTIM)						\
-	svc_rqst_flag_end(DATA)
+	svc_rqst_flag(DATA)						\
+	svc_rqst_flag_end(RES_REPLACED)
 
 #undef svc_rqst_flag
 #undef svc_rqst_flag_end
@@ -2174,6 +2175,35 @@ TRACE_EVENT(svc_alloc_arg_err,
 		__entry->requested, __entry->allocated)
 );
 
+TRACE_EVENT(svc_reuse_scan,
+	TP_PROTO(
+		const struct svc_rqst *rqstp,
+		unsigned long free,
+		unsigned long filled,
+		unsigned long trimmed
+	),
+
+	TP_ARGS(rqstp, free, filled, trimmed),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, held)
+		__field(unsigned long, free)
+		__field(unsigned long, filled)
+		__field(unsigned long, trimmed)
+	),
+
+	TP_fast_assign(
+		__entry->held = rqstp->rq_nreuse;
+		__entry->free = free;
+		__entry->filled = filled;
+		__entry->trimmed = trimmed;
+	),
+
+	TP_printk("held=%lu free=%lu filled=%lu trimmed=%lu",
+		__entry->held, __entry->free, __entry->filled,
+		__entry->trimmed)
+);
+
 DECLARE_EVENT_CLASS(svc_deferred_event,
 	TP_PROTO(
 		const struct svc_deferred_req *dr
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 8297bad2b1777..ededac15771e0 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -20,6 +20,8 @@
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/kthread.h>
+#include <linux/pagemap.h>
+#include <linux/sizes.h>
 #include <linux/slab.h>
 
 #include <linux/sunrpc/types.h>
@@ -548,6 +550,25 @@ svc_destroy(struct svc_serv **servp)
 }
 EXPORT_SYMBOL_GPL(svc_destroy);
 
+/**
+ * svc_reuse_capacity - Bound on the pages a thread may hold for reuse
+ * @rqstp: RPC transaction context
+ *
+ * Four Reply payloads, capped at 4 MiB. On a service whose own
+ * maximum payload is 4 MiB the cap is what binds, and a thread
+ * holds at most one Reply's worth. This is a policy cap, sized so
+ * that the sent-but-unacknowledged data of the connections a
+ * thread services typically fits; pages beyond it are released
+ * exactly as before, as they are when the array cannot be
+ * allocated.
+ *
+ * Return: maximum count of pages to park in rq_reuse_pages
+ */
+static inline unsigned long svc_reuse_capacity(const struct svc_rqst *rqstp)
+{
+	return min(4 * rqstp->rq_maxpages, SZ_4M / PAGE_SIZE);
+}
+
 static bool
 svc_init_buffer(struct svc_rqst *rqstp, const struct svc_serv *serv, int node)
 {
@@ -570,6 +591,15 @@ svc_init_buffer(struct svc_rqst *rqstp, const struct svc_serv *serv, int node)
 		return false;
 	}
 
+	/*
+	 * Page reuse is an optimization; a thread that cannot allocate
+	 * the array releases sent pages the way it always has.
+	 */
+	rqstp->rq_reuse_pages = kcalloc_node(svc_reuse_capacity(rqstp),
+					     sizeof(struct page *),
+					     GFP_KERNEL | __GFP_NORETRY |
+					     __GFP_NOWARN, node);
+
 	rqstp->rq_pages_nfree = rqstp->rq_maxpages;
 	rqstp->rq_next_page = rqstp->rq_respages + rqstp->rq_maxpages;
 	return true;
@@ -596,6 +626,12 @@ svc_release_buffer(struct svc_rqst *rqstp)
 				put_page(rqstp->rq_respages[i]);
 		kfree(rqstp->rq_respages);
 	}
+
+	if (rqstp->rq_reuse_pages) {
+		while (rqstp->rq_nreuse)
+			put_page(rqstp->rq_reuse_pages[--rqstp->rq_nreuse]);
+		kfree(rqstp->rq_reuse_pages);
+	}
 }
 
 static void svc_rqst_free_rcu(struct rcu_head *head)
@@ -934,6 +970,10 @@ EXPORT_SYMBOL_GPL(svc_serv_maxthreads);
  * When replacing a page in rq_respages, batch the release of the
  * replaced pages to avoid hammering the page allocator.
  *
+ * Flags the transaction so that svc_rqst_release_pages() retains
+ * none of this Reply's pages for reuse: it now carries pages this
+ * thread did not allocate.
+ *
  * Return values:
  *   %true: page replaced
  *   %false: array bounds checking failed
@@ -951,12 +991,172 @@ bool svc_rqst_replace_page(struct svc_rqst *rqstp, struct page *page)
 	if (*rqstp->rq_next_page)
 		svc_rqst_page_release(rqstp, *rqstp->rq_next_page);
 
+	/* Avoid an atomic RMW for every page of a spliced READ */
+	if (!test_bit(RQ_RES_REPLACED, &rqstp->rq_flags))
+		set_bit(RQ_RES_REPLACED, &rqstp->rq_flags);
 	get_page(page);
 	*(rqstp->rq_next_page++) = page;
 	return true;
 }
 EXPORT_SYMBOL_GPL(svc_rqst_replace_page);
 
+/*
+ * Take custody of a sent Reply page in place of dropping this
+ * thread's reference. The transport may still hold references, so
+ * the page is not reused until a scan observes ours to be the last
+ * one. That may be the scan at the end of this same release.
+ */
+static bool svc_reuse_page(struct svc_rqst *rqstp, struct page *page)
+{
+	struct folio *folio = page_folio(page);
+
+	if (!rqstp->rq_reuse_pages ||
+	    rqstp->rq_nreuse >= svc_reuse_capacity(rqstp))
+		return false;
+	/* Backstop: never hold a page-cache folio, whatever installed it */
+	if (folio_test_lru(folio) || folio_mapping(folio))
+		return false;
+	rqstp->rq_reuse_pages[rqstp->rq_nreuse++] = page;
+	return true;
+}
+
+/*
+ * Entries svc_reuse_scan() may examine beyond four per free slot.
+ * A scan resumes from rq_reuse_cursor, so this bounds one call and
+ * not overall progress.
+ */
+#define SVC_REUSE_SCAN_SLACK	64
+
+/*
+ * Pages returned to the allocator per scan once every free slot is
+ * filled. Shrinking rq_reuse_pages a few pages at a time lets it
+ * decay as demand falls, while a thread whose demand persists
+ * refills it faster than the trickle drains it.
+ */
+#define SVC_REUSE_TRIM_MAX	8
+
+/*
+ * Fill the free slots in [@first, @last) with held pages that this
+ * thread again exclusively owns. rq_reuse_pages is unordered and
+ * scanned with a cursor: peers acknowledge on independent clocks,
+ * so an ordered queue would let one slow connection block reuse of
+ * every page held after its own. A consumed entry is replaced by
+ * the last entry. The scan ends once every free slot is filled
+ * and any trim budget is spent, after a pass over rq_reuse_pages
+ * in which no entry was ready, or when the per-call examination
+ * budget is spent. Pages that are unsuitable for reuse are
+ * returned to the allocator, and so is a small surplus when
+ * @trim is set.
+ */
+static void svc_reuse_scan(struct svc_rqst *rqstp, struct page **first,
+			   struct page **last, bool trim)
+{
+	unsigned long skipped = 0, trimmed = 0, free = 0, filled = 0;
+	unsigned long i = rqstp->rq_reuse_cursor;
+	unsigned long budget;
+	struct page **slot;
+
+	if (!rqstp->rq_nreuse)
+		return;
+	for (slot = first; slot < last; slot++)
+		if (!*slot)
+			free++;
+	if (!free)
+		return;
+	budget = 4 * free + SVC_REUSE_SCAN_SLACK;
+	slot = first;
+
+	while (budget-- && skipped < rqstp->rq_nreuse) {
+		struct folio *folio;
+		struct page *page;
+
+		if (i >= rqstp->rq_nreuse)
+			i = 0;
+		page = rqstp->rq_reuse_pages[i];
+		folio = page_folio(page);
+
+		/*
+		 * A consumer holding a reference reads this page
+		 * before its fully ordered final put; the control
+		 * dependency orders the overwrite after that put.
+		 * A copying consumer is done when send returns.
+		 * skb_page_frag_refill() reuses on the same test.
+		 */
+		if (folio_ref_count(folio) != 1) {
+			i++;
+			skipped++;
+			continue;
+		}
+		skipped = 0;
+
+		/*
+		 * rq_reuse_pages is unordered, so the last entry
+		 * backfills the vacated one. @i is left alone so the
+		 * backfilled entry is examined in its turn; if the
+		 * removed entry was the last, the wrap at the top of
+		 * the loop moves @i back into range.
+		 */
+		rqstp->rq_reuse_pages[i] =
+			rqstp->rq_reuse_pages[--rqstp->rq_nreuse];
+
+		/*
+		 * memory_failure() can flag a page this thread owns
+		 * without holding a reference, so poison is checked
+		 * at reuse time. Remote and pfmemalloc pages are
+		 * released rather than reused, as the network stack
+		 * does when recycling receive buffers. A large folio
+		 * is released too: folio_ref_count() counts the whole
+		 * folio, so one subpage cannot be shown to be ours
+		 * alone.
+		 */
+		if (unlikely(folio_test_hwpoison(folio) ||
+			     folio_test_large(folio) ||
+			     folio_is_pfmemalloc(folio) ||
+			     folio_nid(folio) != numa_mem_id())) {
+			folio_put(folio);
+			continue;
+		}
+
+		while (slot < last && *slot)
+			slot++;
+		if (slot != last) {
+			*slot = page;
+			filled++;
+			continue;
+		}
+
+		/* Every free slot is filled; decay a small surplus */
+		if (trim && trimmed < SVC_REUSE_TRIM_MAX) {
+			folio_put(folio);
+			trimmed++;
+			continue;
+		}
+		rqstp->rq_reuse_pages[rqstp->rq_nreuse++] = page;
+		break;
+	}
+	rqstp->rq_reuse_cursor = i;
+	trace_svc_reuse_scan(rqstp, free, filled, trimmed);
+}
+
+/**
+ * svc_rqst_refill_pages - Fill free buffer slots from held pages
+ * @rqstp: RPC transaction context
+ * @first: first slot in the range to fill
+ * @last: one past the last slot in the range
+ *
+ * Fill the free slots in [@first, @last) with Reply pages the
+ * network has finished with, so that a thread consults the pages
+ * it already owns before asking the page allocator for more. Only
+ * as many slots are filled as one scan's budget allows.
+ * rq_reuse_pages is not trimmed here; a surplus is trimmed by
+ * svc_rqst_release_pages() instead, as each Reply is released.
+ */
+void svc_rqst_refill_pages(struct svc_rqst *rqstp,
+			   struct page **first, struct page **last)
+{
+	svc_reuse_scan(rqstp, first, last, false);
+}
+
 /**
  * svc_rqst_release_pages - Release Reply buffer pages
  * @rqstp: RPC transaction context
@@ -964,21 +1164,50 @@ EXPORT_SYMBOL_GPL(svc_rqst_replace_page);
  * Release response pages in the range [rq_respages, rq_next_page).
  * NULL entries in this range are skipped, allowing transports to
  * transfer pages to a send context before this function runs.
+ *
+ * Where possible, pages the thread allocated itself are held for
+ * reuse instead of released: the transport's final put_page() then
+ * runs against a page that still has a reference and stays out of
+ * the page allocator entirely. A Reply that contains pages
+ * installed by nfsd_splice_actor(), or one sent by a transport that
+ * has not declared its Reply-page references
+ * (XCL_FL_REPLY_PAGE_REUSE), is released as before, as is any page
+ * that does not fit within svc_reuse_capacity() or that proves to
+ * be page-cache-backed. Free slots in the released range are then
+ * refilled, as far as one scan's budget allows, from held pages
+ * the network has finished with, and a small surplus is returned
+ * to the allocator.
  */
 void svc_rqst_release_pages(struct svc_rqst *rqstp)
 {
+	struct svc_xprt *xprt = rqstp->rq_xprt;
 	struct page **pp;
+	bool hold;
+
+	if (test_bit(RQ_RES_REPLACED, &rqstp->rq_flags)) {
+		clear_bit(RQ_RES_REPLACED, &rqstp->rq_flags);
+		hold = false;
+	} else {
+		hold = xprt &&
+		       (xprt->xpt_class->xcl_flags & XCL_FL_REPLY_PAGE_REUSE);
+	}
 
 	for (pp = rqstp->rq_respages; pp < rqstp->rq_next_page; pp++) {
 		if (*pp) {
-			if (!folio_batch_add(&rqstp->rq_fbatch,
-					     page_folio(*pp)))
-				__folio_batch_release(&rqstp->rq_fbatch);
+			if (!hold || !svc_reuse_page(rqstp, *pp)) {
+				if (!folio_batch_add(&rqstp->rq_fbatch,
+						     page_folio(*pp)))
+					__folio_batch_release(&rqstp->rq_fbatch);
+			}
 			*pp = NULL;
 		}
 	}
 	if (rqstp->rq_fbatch.nr)
 		__folio_batch_release(&rqstp->rq_fbatch);
+
+	if (rqstp->rq_next_page > rqstp->rq_respages)
+		svc_reuse_scan(rqstp, rqstp->rq_respages,
+			       rqstp->rq_next_page, true);
 }
 
 /**
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 40040af588fb2..88b744c324eb0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -690,6 +690,13 @@ static bool svc_fill_pages(struct svc_rqst *rqstp, struct page **pages,
 	unsigned long filled, ret;
 
 	for (filled = 0; filled < npages; filled = ret) {
+		/*
+		 * alloc_pages_bulk() populates only the slots that are
+		 * NULL on entry and counts the rest in its return
+		 * value, so a slot filled here is a page not allocated
+		 * below.
+		 */
+		svc_rqst_refill_pages(rqstp, pages, pages + npages);
 		ret = alloc_pages_bulk(GFP_KERNEL, npages, pages);
 		if (ret > filled)
 			/* Made progress, don't sleep yet */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7a423e9ee74d4..6041be33cb076 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -910,6 +910,7 @@ static struct svc_xprt_class svc_udp_class = {
 	.xcl_ops = &svc_udp_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 	.xcl_ident = XPRT_TRANSPORT_UDP,
+	.xcl_flags = XCL_FL_REPLY_PAGE_REUSE,
 };
 
 static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
@@ -1426,6 +1427,7 @@ static struct svc_xprt_class svc_tcp_class = {
 	.xcl_ops = &svc_tcp_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 	.xcl_ident = XPRT_TRANSPORT_TCP,
+	.xcl_flags = XCL_FL_REPLY_PAGE_REUSE,
 };
 
 void svc_init_xprt_sock(void)
-- 
2.53.0

