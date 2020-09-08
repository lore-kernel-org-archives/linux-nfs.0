Return-Path: <SRS0=kBQ9=CR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.3 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBA11C43461
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Sep 2020 16:48:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8B662206E6
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Sep 2020 16:48:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Uxdn9ra0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731442AbgIHQ0S (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Sep 2020 12:26:18 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58750 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731901AbgIHQZj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2020 12:25:39 -0400
Received: from mail-io1-xd43.google.com (mail-io1-xd43.google.com [IPv6:2607:f8b0:4864:20::d43])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 980D2C061797
        for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2020 09:25:23 -0700 (PDT)
Received: by mail-io1-xd43.google.com with SMTP id d190so17754353iof.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Sep 2020 09:25:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wp5SKBozu7cWhnGG7XLzLGXTHYmhOkgCPiKlw5Gsgd0=;
        b=Uxdn9ra0AWYEIBz4HcLQ8Lnk4Ylh5IoGNYwirAoQUkvx0VW6Jj1jHuWwjAlb0QaYMS
         FFhofH1X2jfdQ5lRL1brgI0sqM8wkFQGKRu67+pkyGZJ9o4ITkTJNkMnhapMoS61tjQL
         cPTi3AusDF1xBixQ/nSzChpb3arIViJFzls+HWuMkz6JqphGQkBnDz7TJ7jEQd1cGtpc
         EALCZUfOmNxO7TVnpOfWtYAYmS4KEUVw+rIxZdwCOy9V8OknqbX9+9/gK6fkWfgnxGDz
         gESI3Aiv762Jli8ru3JQJWDOwB3e32aS4P0m28+sFOatXbMqHYb8n+LfczHaUDoVsSUR
         lyAw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=wp5SKBozu7cWhnGG7XLzLGXTHYmhOkgCPiKlw5Gsgd0=;
        b=W9mlpRQuCd7+tuRP9ReowWk0HiJEDdke0Y0Bttrcs1TiYMgtgC0lQQr/uYTLk/7erI
         8RRvF5SqEIFBKsuWZf/BWLqph+GjUYZyHJESn+RBmkwKcm7NaeGnqJjdLcWaF9U9nSSP
         YoRJyXOEO+4dNkElOR+UTs2X6Pw6CoO9ofa3uaGHZsaFA+44bkCNMpOmBJYN7MR60l5x
         1YHviSO9ZSNcbTkDoLR1Ijx3IExdWGzDwHl0SQ7mNpa/eatL3rEkFleJXVvaMduS+J2p
         RZLOoMahc8GPKSnnFWmNNZNuC3sDUzMcI2Ou67RxNAEO6sC+ub1vQB5cWVzA0KpTKVO6
         TDPA==
X-Gm-Message-State: AOAM530Km6etHceLK8QDYQveiRwZNNpp8x5VIKbv+BAqWJe2Dfyubcps
        DQDZFaCOq+CDdCkib5Tx+N+CpBe1hSM=
X-Google-Smtp-Source: ABdhPJzekbwb1CkMdlKtoYWyKIn1r9UnrgSAW6ByEY3ZbudfzRgc/LgxF26DyLQUB8hAKHOdtyrm1Q==
X-Received: by 2002:a02:a1d3:: with SMTP id o19mr25321233jah.90.1599582322635;
        Tue, 08 Sep 2020 09:25:22 -0700 (PDT)
Received: from gouda.nowheycreamery.com (c-68-32-74-190.hsd1.mi.comcast.net. [68.32.74.190])
        by smtp.gmail.com with ESMTPSA id 2sm10291375ilj.24.2020.09.08.09.25.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 08 Sep 2020 09:25:22 -0700 (PDT)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH v5 08/10] NFS: Add READ_PLUS hole segment decoding
Date:   Tue,  8 Sep 2020 12:25:11 -0400
Message-Id: <20200908162513.508991-9-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20200908162513.508991-1-Anna.Schumaker@Netapp.com>
References: <20200908162513.508991-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

We keep things simple for now by only decoding a single hole or data
segment returned by the server, even if they returned more to us.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42xdr.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 930b4ca212c1..9720fedd2e57 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -53,7 +53,7 @@
 #define decode_read_plus_maxsz		(op_decode_hdr_maxsz + \
 					 1 /* rpr_eof */ + \
 					 1 /* rpr_contents count */ + \
-					 NFS42_READ_PLUS_SEGMENT_SIZE)
+					 2 * NFS42_READ_PLUS_SEGMENT_SIZE)
 #define encode_seek_maxsz		(op_encode_hdr_maxsz + \
 					 encode_stateid_maxsz + \
 					 2 /* offset */ + \
@@ -1045,6 +1045,28 @@ static int decode_read_plus_data(struct xdr_stream *xdr, struct nfs_pgio_res *re
 	return 0;
 }
 
+static int decode_read_plus_hole(struct xdr_stream *xdr, struct nfs_pgio_res *res,
+				 uint32_t *eof)
+{
+	uint64_t offset, length, recvd;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 8 + 8);
+	if (unlikely(!p))
+		return -EIO;
+
+	p = xdr_decode_hyper(p, &offset);
+	p = xdr_decode_hyper(p, &length);
+	recvd = xdr_expand_hole(xdr, 0, length);
+	res->count += recvd;
+
+	if (recvd < length) {
+		*eof = 0;
+		return 1;
+	}
+	return 0;
+}
+
 static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 {
 	uint32_t eof, segments, type;
@@ -1071,6 +1093,8 @@ static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 	type = be32_to_cpup(p++);
 	if (type == NFS4_CONTENT_DATA)
 		status = decode_read_plus_data(xdr, res, &eof);
+	else if (type == NFS4_CONTENT_HOLE)
+		status = decode_read_plus_hole(xdr, res, &eof);
 	else
 		return -EINVAL;
 
-- 
2.28.0

