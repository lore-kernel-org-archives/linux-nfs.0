Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B5EDC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3F5EA2147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WzZ4nq4Q"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726221AbfBSNzQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:16 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:53562 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725767AbfBSNzQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:16 -0500
Received: by mail-it1-f196.google.com with SMTP id x131so6131558itc.3
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1rEZ/xqNSEhTI7upYi3VMhoDwpPz/PE6FG7J3ekDwQI=;
        b=WzZ4nq4Q+YRY+cOJ4RCmWO51NtqeFXsnS5h6mjfp4wCAF2xlhjsvU0ScoWiIiAn+BN
         p3kD6I6FqtTamr5zl8+/xowCzL1leZvpVCZbuIfqhErTU3y7JkYmG/xKohdm3mdtvJVC
         5yK69DPL2fsZol2C5GplIW7SgP4PPMVuDqIWVemfEWcIXv6dlShlFxYZMrELERhekYep
         JEmsRg9WC2i6MtnqvoveXFHvWAZfHZ0uyjsJEr2K+yYLhz0k9etUBiRnuIPRzEsJK/nA
         RGMIYS3rhsuqQdXw6ccuCQtdszoa0T4OIfKKPQH5PJ9YklJuc/lDnfQF1grlTDxQWJ1i
         IesQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=1rEZ/xqNSEhTI7upYi3VMhoDwpPz/PE6FG7J3ekDwQI=;
        b=VtkFHd3N4P6W1qV5dqGwmoB0WxwRHROarRWGXcJKM6pP9WhiX9nY+E90i5a2NsRFLw
         xedlh1S61z+l9yojGJdZhYaljnlUOzlyxjlj/OXDIJDdnb3eL8/+AqlhXhHfjCnAv7Yd
         3iWHqLlkaqNg/wVTAQa/M4ffR2KW9zxiIFLbfswn0dZpz/byFBq0andV9JibNRsCBCKu
         it69pEuzLAomogPHsMGgrbf737whkSuWB2MDGx1EuxT1PcjMy2R+5vae+MobUA/L2+hz
         4ZZ0fT7oDCdt5wUTR9DvCk6Z2elf6sD1WQm6uOZYM0hc6626RFwA3D5hefQQWp2nYRxp
         4byw==
X-Gm-Message-State: AHQUAuYjPD5F2fluIDpjo5ppgZxzsi9CDyYNABC53BPxNR+JmZ5FkpIC
        cro170ns28R7/1fny96YsxG4E64=
X-Google-Smtp-Source: AHgI3IZvmzS6wtyrWynlOSzzrpFIgV/b2UUfgmLEjFNADoJyVehAu+cGuzJM/CiQMolhhi7qtCGGNw==
X-Received: by 2002:a24:3512:: with SMTP id k18mr2042055ita.83.1550584514933;
        Tue, 19 Feb 2019 05:55:14 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.13
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:13 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/8] NFS: Fix I/O request leakages
Date:   Tue, 19 Feb 2019 08:53:04 -0500
Message-Id: <20190219135311.119300-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
References: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When we fail to add the request to the I/O queue, we currently leave it
to the caller to free the failed request. However since some of the
requests that fail are actually created by nfs_pageio_add_request()
itself, and are not passed back the caller, this leads to a leakage
issue, which can again cause page locks to leak.

This commit addresses the leakage by freeing the created requests on
error, using desc->pg_completion_ops->error_cleanup()

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Fixes: a7d42ddb30997 ("nfs: add mirroring support to pgio layer")
Cc: stable@vger.kernel.org # v4.0: c18b96a1b862: nfs: clean up rest of reqs
Cc: stable@vger.kernel.org # v4.0: d600ad1f2bdb: NFS41: pop some layoutget
Cc: stable@vger.kernel.org # v4.0+
---
 fs/nfs/pagelist.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e54d899c1848..301880a3ad8e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -988,6 +988,17 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 	}
 }
 
+static void
+nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
+		struct nfs_page *req)
+{
+	LIST_HEAD(head);
+
+	nfs_list_remove_request(req);
+	nfs_list_add_request(req, &head);
+	desc->pg_completion_ops->error_cleanup(&head);
+}
+
 /**
  * nfs_pageio_add_request - Attempt to coalesce a request into a page list.
  * @desc: destination io descriptor
@@ -1025,10 +1036,8 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			nfs_page_group_unlock(req);
 			desc->pg_moreio = 1;
 			nfs_pageio_doio(desc);
-			if (desc->pg_error < 0)
-				return 0;
-			if (mirror->pg_recoalesce)
-				return 0;
+			if (desc->pg_error < 0 || mirror->pg_recoalesce)
+				goto out_cleanup_subreq;
 			/* retry add_request for this subreq */
 			nfs_page_group_lock(req);
 			continue;
@@ -1061,6 +1070,10 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	desc->pg_error = PTR_ERR(subreq);
 	nfs_page_group_unlock(req);
 	return 0;
+out_cleanup_subreq:
+	if (req != subreq)
+		nfs_pageio_cleanup_request(desc, subreq);
+	return 0;
 }
 
 static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
@@ -1168,11 +1181,14 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 		if (nfs_pgio_has_mirroring(desc))
 			desc->pg_mirror_idx = midx;
 		if (!nfs_pageio_add_request_mirror(desc, dupreq))
-			goto out_failed;
+			goto out_cleanup_subreq;
 	}
 
 	return 1;
 
+out_cleanup_subreq:
+	if (req != dupreq)
+		nfs_pageio_cleanup_request(desc, dupreq);
 out_failed:
 	nfs_pageio_error_cleanup(desc);
 	return 0;
-- 
2.20.1

