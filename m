Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B7E6492E58
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048505; cv=none; b=A8WOZPQofq4cORuGw6oz4fKG/biS5ir6AXUXYEyNfNdNLGhiq6KJ6kjP5SG1oCViLksISjI6UGvciqbA9Bp91+dEHWbZZFOoIJOjnzqUUHETAcPNzdp9gNcF12RYVbDxPQqgo7Wk2BRNLcbrgWWywxHxuplcvU/F6bjh9oHvT8g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048505; c=relaxed/simple;
	bh=2C8oD1mw+16O3x85t/NPj4GBOZIPDeB+upv893yD0U4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=mjqoQsrHgvP85fN9hC2slTNN4VyZfC9R9wZCsb5g59DnpWWZuWgU5CypxTt+k6Qng/6n8ckzh6FEyYscmzL1RK11Gc6WT4+++VsolxP7qj5g0b7fipElBajmKmuPgxTNM1TarKPlLRwfHAGX+J5llJhDL5WJTAbLiVReHiZW5e8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XZJ1wXi5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XZJ1wXi5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 90E841F00899;
	Thu, 10 Sep 2026 13:55:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048504;
	bh=SZLMkOW0p4XAqrmDNT9IdS4He34xZnwhfL0+a9yKyz0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XZJ1wXi5C0qd7/RkqKv/G2dI2O28rKKIFgsywqmLnv9v7XKgSqQ+4xxYnw5WxGN7R
	 SxhsiIxanFmfvtiHD4yyFDKlb/UmZ2GtdprJtWkwXcwEl1h8TC/U5ezMwYPUlo7AKm
	 bPKvWw+TgSWj0gsOo2NWvFvwLOcHlA1JOhOjL0hAVmpmlaKPMtNvPh0tHxarTOrer3
	 7D0bsoU7NmdSDNWmvRfQyzqnOnrhJj15zDz6A4+2muhIAgu6+99aUuF6G5NAvCLRp2
	 TO3jmQysnmO+A5OvheU7iyDt4HmlJGbr/s1DUWM3roCUwRBLvdYSDCwA3W+ndU7UgU
	 zCLsl6wFZ7v/Q==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:48 -0400
Subject: [PATCH v3 08/12] svcrdma: Fire reply-acknowledged callback on Send
 completion
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-8-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3687; i=cel@kernel.org;
 h=from:subject:message-id; bh=2C8oD1mw+16O3x85t/NPj4GBOZIPDeB+upv893yD0U4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqorawtGpWYm5b7hvzAbFUV/8NiAB2ePFLxUD6n
 lNJo0VyEkSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2sAAKCRAzarMzb2Z/
 l7EfD/9lN0atP6r4AJ6cIRV7nDyyeGoEppaKXgALuiwR97gdsj0ucSv8TAOAhdL8PUJYsvFITFQ
 d5zSTAVb20SG+4m4DPcaaAj5u+QGP96IK+MKK39ZLfOiQi4QtLxYnWgAM19O6KknLmBXDJlK34V
 DTbH+pUG6UmWLMxIjSU4X7d52s84fDnzLN4PK9NCP1TkNKHqkXF6joVgYzh3xkaLaYWbAeTPfKl
 /7CKQL0bWrXoPeARfEt07OkxBoGGAWYRRFoSGeYaV+AGr3wl1UY9M4RfquQii43aHSwZb++03XY
 Nkiqk7MZddmC3Tq4c/R1r9JU8N64fQwsNJcSEYNpDTB+jNnOx8ZCIY3C8kEY3KihemGeeOpHkSk
 4Im/LuCvdy6X8No8yEIAr38OxxQdxyQjsxhfWE+2phXvMKfsQr/bYvp0PMQq22EhVu6A2RHoKhM
 JKSlU5ONgxGGaPD7e+RMvVARvQmSiu/gN9GYmLqGCOZIDYBh+NTT5mjJmR20/V5L8JoWMaJrILR
 kHHTefoZw9SoT+ZZI/PrVcyfbpLMrP1eVs6ZQt52c/dfOd1lJv0oHEyhurQ+tLNwz2Srd0gDHKX
 GGc4EfSS+wU1UYNL6j9VkTcfVDK6kG/5DPL0Om6ZTECpQZ93mItsuoZgeUvEbcCetr4HYscfm98
 Jm/Ynmc+1VX6AIA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svcrdma posts RDMA Write work requests ahead of the Send, so a
successful Send completion confirms that the transport header and the
reply payload have both reached the client.

Store rq_ack_cookie in the send context before posting and report the
reply as delivered from the Send completion handler, so the DRC can
evict the entry without waiting for RC_EXPIRE. Set XPT_REPLY_ACK on
RDMA transports so the upper layer expects these reports. A flushed
Send reports the reply as undelivered: the connection is closing, and
the entry stays cached for a retransmit on the next connection.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_rdma.h          |  1 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    | 14 ++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  1 +
 3 files changed, 16 insertions(+)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 76aa5ec4ab40..7261dd3a892e 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -248,6 +248,7 @@ struct svc_rdma_send_ctxt {
 	struct list_head	sc_write_info_list;
 	struct svc_rdma_write_info sc_reply_info;
 
+	svc_ack_cookie_t	sc_ack_cookie;
 	void			*sc_xprt_buf;
 	int			sc_page_count;
 	int			sc_cur_sge_no;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index c09659b17351..884e2d76cb6f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -220,6 +220,7 @@ struct svc_rdma_send_ctxt *svc_rdma_send_ctxt_get(struct svcxprt_rdma *rdma)
 	ctxt->sc_send_wr.num_sge = 0;
 	ctxt->sc_cur_sge_no = 0;
 	ctxt->sc_page_count = 0;
+	ctxt->sc_ack_cookie = (svc_ack_cookie_t){};
 	ctxt->sc_wr_chain = &ctxt->sc_send_wr;
 	ctxt->sc_sqecount = 1;
 
@@ -470,11 +471,17 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 	if (unlikely(wc->status != IB_WC_SUCCESS))
 		goto flushed;
 
+	if (svc_ack_cookie_present(&ctxt->sc_ack_cookie))
+		svc_reply_acked(rdma->sc_xprt.xpt_server,
+				&ctxt->sc_ack_cookie, true);
 	trace_svcrdma_wc_send(&ctxt->sc_cid);
 	svc_rdma_send_ctxt_put(rdma, ctxt);
 	return;
 
 flushed:
+	if (svc_ack_cookie_present(&ctxt->sc_ack_cookie))
+		svc_reply_acked(rdma->sc_xprt.xpt_server,
+				&ctxt->sc_ack_cookie, false);
 	if (wc->status != IB_WC_WR_FLUSH_ERR)
 		trace_svcrdma_wc_send_err(wc, &ctxt->sc_cid);
 	else
@@ -1198,6 +1205,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	if (ret < 0)
 		goto put_ctxt;
 
+	sctxt->sc_ack_cookie = rqstp->rq_ack_cookie;
 	ret = svc_rdma_send_reply_msg(rdma, sctxt, rctxt, rqstp);
 	if (ret < 0)
 		goto send_err;
@@ -1207,6 +1215,12 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	if (ret != -E2BIG && ret != -EINVAL)
 		goto put_ctxt;
 
+	/* The sctxt is reused for the RDMA_ERROR message. Clear the
+	 * ack cookie so that message's Send completion does not
+	 * report the unsent reply as delivered.
+	 */
+	sctxt->sc_ack_cookie = (svc_ack_cookie_t){};
+
 	/* Send completion releases payload pages that were part
 	 * of previously posted RDMA Writes.
 	 */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 610df78f9176..64e964ac941c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -218,6 +218,7 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 	 * transports are suitable here.
 	 */
 	set_bit(XPT_CONG_CTRL, &cma_xprt->sc_xprt.xpt_flags);
+	set_bit(XPT_REPLY_ACK, &cma_xprt->sc_xprt.xpt_flags);
 
 	return cma_xprt;
 }

-- 
2.55.0

