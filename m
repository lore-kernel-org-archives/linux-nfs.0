Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AD68C2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:10:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C7B852080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:10:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7B852080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725931AbeJaFFh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:05:37 -0400
Received: from mx1.redhat.com ([209.132.183.28]:35172 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725926AbeJaFFg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 01:05:36 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 242CF300157B;
        Tue, 30 Oct 2018 20:10:42 +0000 (UTC)
Received: from hut.sorenson.redhat.com (ovpn-116-149.phx2.redhat.com [10.3.116.149])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id ADC855E7C1;
        Tue, 30 Oct 2018 20:10:41 +0000 (UTC)
From:   Frank Sorenson <sorenson@redhat.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org, jlayton@kernel.org
Subject: [PATCH] sunrpc: correct the computation for page_ptr when truncating
Date:   Tue, 30 Oct 2018 15:10:40 -0500
Message-Id: <20181030201040.2024882-1-sorenson@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 30 Oct 2018 20:10:42 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When truncating the encode buffer, the page_ptr is getting
advanced, causing the next page to be skipped while encoding.
The page is still included in the response, so the response
contains a page of bogus data.

We need to adjust the page_ptr backwards to ensure we encode
the next page into the correct place.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 net/sunrpc/xdr.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 2bbb8d38d2bf..5cfb9e0a18dc 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -673,11 +673,10 @@ void xdr_truncate_encode(struct xdr_stream *xdr, size_t len)
 		WARN_ON_ONCE(xdr->iov);
 		return;
 	}
-	if (fraglen) {
+	if (fraglen)
 		xdr->end = head->iov_base + head->iov_len;
-		xdr->page_ptr--;
-	}
 	/* (otherwise assume xdr->end is already set) */
+	xdr->page_ptr--;
 	head->iov_len = len;
 	buf->len = len;
 	xdr->p = head->iov_base + head->iov_len;
-- 
2.14.5

