Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA22DC43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 892012084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="neans00q"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726053AbfCAT1E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:04 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:33963 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725905AbfCAT1E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:04 -0500
Received: by mail-yw1-f65.google.com with SMTP id u205so14959694ywe.1
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CfIgfRwB62LaSh21CxfRf+KU59A5noof7N7czZV+o9U=;
        b=neans00qPE/wK8E1yjiKMsEqx0L5Le1c7I9VQTZRMoTa1gqaX3p8pT9KMStaWNFDSc
         l8Bi7FVE6uZVVCTFX+87zut1tmUWgRclkWdhJJ64AvbDJCUHclFJKbHIjsJfVNUaGIIT
         NDnMVs55aj23VWwxf1FLa+IEbiowZ/pAFRPZajrnv0MqAzwb6ijbwCAVbOhaDXjuwOO0
         N9bP4f0WtU+w4KTKL/6Fn3YyHFBEGLpYJfj+UyReyapQ6x2LkTOLDZLuLDy3BuMJBQqv
         xQyohT7rmp12QH5hhrihtWpb7wSEOGHKBKEf7X7cGC38+mx+Z4cnROS+LEEGvUD+2vi4
         2T/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=CfIgfRwB62LaSh21CxfRf+KU59A5noof7N7czZV+o9U=;
        b=V7QMnCtwY1lAbTcBbuOZE2Sy3RjB0kyTHaMYpI07RDbH9MBNz6YQZG0v1+hmOiwLAe
         eujuNvn7WLWUSSvClHmLQC4nbsKFsJQvrjsXBCc6dzdaWsBjRAzN2Sde+dWOy+2Bs7C7
         jWAXmPTKsUjV/KT6qgnLCaBeADFXKV+2kFMrUmoQe4Ed/nWuvfPjkXX233ifOC5mUQzc
         WhCe+5ZIrcCq/6QY3vGVtTp3PjeZMb7IIezTmgR94Si78k/Rpq5cioDFwe11NUeUqpLW
         JfBGtob4W02dIbhFVqqpZw8Q6TMe5kFdQo9qC4v+EQwGwi3rdqt94epV7Rj8wugUGNI2
         lRJg==
X-Gm-Message-State: APjAAAW6kAwXHY+cW8Mp28lA/CAdyLhN4JaP/w+r3anSZ5t84BWm5uiJ
        m54mGNkqOaLkt2UUeb3fgy8Kt3M=
X-Google-Smtp-Source: APXvYqxf95OAeWkMkFlOiAUHNqllqPL3lX+RJ9vaN7JmCbYwhpzSyzVuCkjL63TSq6IWGBqbuHzZNw==
X-Received: by 2002:a81:9b44:: with SMTP id s65mr5129840ywg.483.1551468422800;
        Fri, 01 Mar 2019 11:27:02 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.02
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:02 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 11/19] NFS/flexfiles: Don't invalidate DS deviceids for being unresponsive
Date:   Fri,  1 Mar 2019 14:24:47 -0500
Message-Id: <20190301192455.104943-12-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-11-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
 <20190301192455.104943-7-trond.myklebust@hammerspace.com>
 <20190301192455.104943-8-trond.myklebust@hammerspace.com>
 <20190301192455.104943-9-trond.myklebust@hammerspace.com>
 <20190301192455.104943-10-trond.myklebust@hammerspace.com>
 <20190301192455.104943-11-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the DS is unresponsive, we want to just mark it as such, while
reporting the errors. If the server later returns the same deviceid
in a new layout, then we don't want to have to look it up again.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.h    | 18 ------------------
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  6 +++---
 2 files changed, 3 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 93508112486a..2e3c606625ef 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -180,24 +180,6 @@ ff_layout_no_read_on_rw(struct pnfs_layout_segment *lseg)
 	return FF_LAYOUT_LSEG(lseg)->flags & FF_FLAGS_NO_READ_IO;
 }
 
-static inline bool
-ff_layout_test_devid_unavailable(struct nfs4_deviceid_node *node)
-{
-	/*
-	 * Flexfiles should never mark a DS unavailable, but if it does
-	 * print a (ratelimited) warning as this can affect performance.
-	 */
-	if (nfs4_test_deviceid_unavailable(node)) {
-		u32 *p = (u32 *)node->deviceid.data;
-
-		pr_warn_ratelimited("NFS: flexfiles layout referencing an "
-				"unavailable device [%x%x%x%x]\n",
-				p[0], p[1], p[2], p[3]);
-		return true;
-	}
-	return false;
-}
-
 static inline int
 nfs4_ff_layout_ds_version(struct pnfs_layout_segment *lseg, u32 ds_idx)
 {
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 9d56926f4845..a52b31417fab 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -186,7 +186,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 static void ff_layout_mark_devid_invalid(struct pnfs_layout_segment *lseg,
 		struct nfs4_deviceid_node *devid)
 {
-	nfs4_delete_deviceid(devid->ld, devid->nfs_client, &devid->deviceid);
+	nfs4_mark_deviceid_unavailable(devid);
 	if (!ff_layout_has_available_ds(lseg))
 		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
 				lseg);
@@ -606,7 +606,7 @@ static bool ff_read_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 			if (IS_ERR(mirror->mirror_ds))
 				continue;
 			devid = &mirror->mirror_ds->id_node;
-			if (!ff_layout_test_devid_unavailable(devid))
+			if (!nfs4_test_deviceid_unavailable(devid))
 				return true;
 		}
 	}
@@ -627,7 +627,7 @@ static bool ff_rw_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 		if (!mirror->mirror_ds)
 			continue;
 		devid = &mirror->mirror_ds->id_node;
-		if (ff_layout_test_devid_unavailable(devid))
+		if (nfs4_test_deviceid_unavailable(devid))
 			return false;
 	}
 
-- 
2.20.1

