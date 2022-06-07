Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27804C43334
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Jun 2022 08:19:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238100AbiFGITf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 7 Jun 2022 04:19:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46318 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S238118AbiFGITe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2022 04:19:34 -0400
Received: from mail.linux-ng.de (srv.linux-ng.de [5.9.18.165])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id 8F2E825C6D
        for <linux-nfs@vger.kernel.org>; Tue,  7 Jun 2022 01:19:32 -0700 (PDT)
Received: from rpi4.linux-ng.de (unknown [192.168.1.79])
        by mail.linux-ng.de (Postfix) with ESMTPS id 6839283DE6D0;
        Tue,  7 Jun 2022 10:19:31 +0200 (CEST)
Received: by rpi4.linux-ng.de (Postfix, from userid 1000)
        id 275C2BBEC0; Tue,  7 Jun 2022 10:19:31 +0200 (CEST)
From:   marcel@linux-ng.de
To:     linux-nfs@vger.kernel.org
Cc:     Marcel Ritter <marcel@linux-ng.de>
Subject: [PATCH 1/3] cifs-utils/svcgssd: Fix use-after-free bug (config variables)
Date:   Tue,  7 Jun 2022 10:19:07 +0200
Message-Id: <20220607081909.1216287-1-marcel@linux-ng.de>
X-Mailer: git-send-email 2.34.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Marcel Ritter <marcel@linux-ng.de>

This patch fixes a bug when trying to set "principal" in /etc/nfs.conf.
Memory gets freed by conf_cleanup() before being used - moving cleanup
code resolves that.

---
 utils/gssd/svcgssd.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 881207b3..a242b789 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -211,9 +211,6 @@ main(int argc, char *argv[])
 	rpc_verbosity = conf_get_num("svcgssd", "RPC-Verbosity", rpc_verbosity);
 	idmap_verbosity = conf_get_num("svcgssd", "IDMAP-Verbosity", idmap_verbosity);
 
-	/* We don't need the config anymore */
-	conf_cleanup();
-
 	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
 		switch (opt) {
 			case 'f':
@@ -328,6 +325,9 @@ main(int argc, char *argv[])
 
 	daemon_ready();
 
+	/* We don't need the config anymore */
+	conf_cleanup();
+
 	nfs4_init_name_mapping(NULL); /* XXX: should only do this once */
 
 	rc = event_base_dispatch(evbase);
-- 
2.34.1

