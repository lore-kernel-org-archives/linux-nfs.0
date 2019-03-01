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
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBE45C10F03
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BB09A2070B
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Izihflrz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726042AbfCAT1M (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:12 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:43589 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726080AbfCAT1L (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:11 -0500
Received: by mail-yw1-f68.google.com with SMTP id u200so14916208ywu.10
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z8YWuqW4j6l/n2F5awZfHcboHOcI9H4TroUeUfhL47g=;
        b=IzihflrzeSH4Dx3qBm3sgwogRZ0eFTbFIPiLBpMI+iHbHOVpAcYcK2ZHaYLdVA99jk
         wSadUKcEA/vsCOHDnA8qD9dlug4RL1AG4rdafwHeeC67bca+xynA8WbL7kB1zxkmGgQ9
         ZqnQwg8gOxoD0CoBp4mHKMVwdpgAIad5KtYoyRTd6DoHcBnGzwXZp0w70F+OBv00flYo
         XFVPJLI3i0MseZXzVe0xlCucNWt9RwLCEsu9bQCtXI5tDApE3a34bY6Tw0M81O4+mJ6d
         hHZi51Eh6iS6lnTK+roBvkp2BpgiHDovptw98ADwuuHTkUOaFVAwo1kYxXWK0gQ+P2b2
         Z2IQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Z8YWuqW4j6l/n2F5awZfHcboHOcI9H4TroUeUfhL47g=;
        b=uj0svWaELEgeZEqI05i+T3JJgggiJMMH3LHOWSqoMhbbIRHsolGz98PIyplcmHHg6X
         254DZXsEVtrMV4RmKB2nVLxe2il2aPAtdueuxI4hx9sAJOI6zXuqELlltsmSJ3HCivBd
         pzveCJ5W+VBEqqyjwoGY2KpCI8LWGCy+rE+OFfeFZedb4tbbYR/j6lCoEzcUQZs3izMh
         NK1JuM+w3OpQvThTumZPh6sFgYkGL/Oy4dLtC0PQ/DQh8NonhNbHGK4YwDEH5fpm920y
         qyt0TSNngTSYWn2K5m1eEzJvjzkLgRqrntvWVVQU+Kx20v0HEATImD4X7liLnvYRhUw9
         /T+Q==
X-Gm-Message-State: APjAAAVKGvdCqSVQ56e6p76a1fZHzupBiDUX1fPwoj/01LXwmZIpZY5u
        Cu7st/7qazAwXpqhbZUtnPVxtaU=
X-Google-Smtp-Source: APXvYqwr8HVUlMTLK8Fc2l2AdeP798cTrn+RRJTP0BImJFbSqoEpHwkbOk0pTuWJ7v3+6J1GN8ksOw==
X-Received: by 2002:a0d:d006:: with SMTP id s6mr2895188ywd.386.1551468430041;
        Fri, 01 Mar 2019 11:27:10 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.09
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:09 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 19/19] NFS/flexfiles: Clean up mirror DS initialisation
Date:   Fri,  1 Mar 2019 14:24:55 -0500
Message-Id: <20190301192455.104943-20-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-19-trond.myklebust@hammerspace.com>
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
 <20190301192455.104943-12-trond.myklebust@hammerspace.com>
 <20190301192455.104943-13-trond.myklebust@hammerspace.com>
 <20190301192455.104943-14-trond.myklebust@hammerspace.com>
 <20190301192455.104943-15-trond.myklebust@hammerspace.com>
 <20190301192455.104943-16-trond.myklebust@hammerspace.com>
 <20190301192455.104943-17-trond.myklebust@hammerspace.com>
 <20190301192455.104943-18-trond.myklebust@hammerspace.com>
 <20190301192455.104943-19-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Get rid of the redundant parameter and rename the function
ff_layout_mirror_valid() to ff_layout_init_mirror_ds() for clarity.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 66 +++++++++++------------
 1 file changed, 31 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index da3b65373db1..52777396b097 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -183,40 +183,6 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 	return NULL;
 }
 
-static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
-				   struct nfs4_ff_layout_mirror *mirror,
-				   bool create)
-{
-	if (mirror == NULL)
-		goto outerr;
-	if (mirror->mirror_ds == NULL) {
-		if (create) {
-			struct nfs4_deviceid_node *node;
-			struct pnfs_layout_hdr *lh = lseg->pls_layout;
-			struct nfs4_ff_layout_ds *mirror_ds = ERR_PTR(-ENODEV);
-
-			node = nfs4_find_get_deviceid(NFS_SERVER(lh->plh_inode),
-					&mirror->devid, lh->plh_lc_cred,
-					GFP_KERNEL);
-			if (node)
-				mirror_ds = FF_LAYOUT_MIRROR_DS(node);
-
-			/* check for race with another call to this function */
-			if (cmpxchg(&mirror->mirror_ds, NULL, mirror_ds) &&
-			    mirror_ds != ERR_PTR(-ENODEV))
-				nfs4_put_deviceid_node(node);
-		} else
-			goto outerr;
-	}
-
-	if (IS_ERR(mirror->mirror_ds))
-		goto outerr;
-
-	return true;
-outerr:
-	return false;
-}
-
 static void extend_ds_error(struct nfs4_ff_layout_ds_err *err,
 			    u64 offset, u64 length)
 {
@@ -350,6 +316,36 @@ nfs4_ff_layout_select_ds_stateid(const struct nfs4_ff_layout_mirror *mirror,
 		nfs4_stateid_copy(stateid, &mirror->stateid);
 }
 
+static bool
+ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
+			 struct nfs4_ff_layout_mirror *mirror)
+{
+	if (mirror == NULL)
+		goto outerr;
+	if (mirror->mirror_ds == NULL) {
+		struct nfs4_deviceid_node *node;
+		struct nfs4_ff_layout_ds *mirror_ds = ERR_PTR(-ENODEV);
+
+		node = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode),
+				&mirror->devid, lo->plh_lc_cred,
+				GFP_KERNEL);
+		if (node)
+			mirror_ds = FF_LAYOUT_MIRROR_DS(node);
+
+		/* check for race with another call to this function */
+		if (cmpxchg(&mirror->mirror_ds, NULL, mirror_ds) &&
+		    mirror_ds != ERR_PTR(-ENODEV))
+			nfs4_put_deviceid_node(node);
+	}
+
+	if (IS_ERR(mirror->mirror_ds))
+		goto outerr;
+
+	return true;
+outerr:
+	return false;
+}
+
 /**
  * nfs4_ff_layout_prepare_ds - prepare a DS connection for an RPC call
  * @lseg: the layout segment we're operating on
@@ -379,7 +375,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	unsigned int max_payload;
 	int status;
 
-	if (!ff_layout_mirror_valid(lseg, mirror, true))
+	if (!ff_layout_init_mirror_ds(lseg->pls_layout, mirror))
 		goto noconnect;
 
 	ds = mirror->mirror_ds->ds;
-- 
2.20.1

