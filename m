Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37979ECDE47
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 17:37:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 01520208A3
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 17:37:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Lpz4jBAR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01520208A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727027AbeKIDNd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 22:13:33 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:53757 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727005AbeKIDNd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Nov 2018 22:13:33 -0500
Received: by mail-it1-f193.google.com with SMTP id r12-v6so2775734ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 08 Nov 2018 09:37:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=co0Vhl0O1U9AJ4ltMtKCVR8fTQuM4YDEuLAVVO9W4G4=;
        b=Lpz4jBARWLafaWuysMyx33BNw4gLIk0F2oXAT/1L9KC2Fa3HNr/FN+kPvs4JZ4UUvc
         dn5LIeeeB0P0/Lv55xm9rYgpO07ruzCaEOexCVJNcfgmLwmgU5aavbJNc85LBoghY1HM
         WnJnb/naZQjC6P31bPl5Sk3qkjjcTCyt39L9b4kTSOB2+jBkRYU2YBs1l0phHufEOe9i
         97s/yoLFjtq+QTf33mGp0pVDKBGjEZ1p19sEHDtzPUhYs6+h3IyNq+Zk3x3iSBAkMYO4
         +axGxGbQqIDNyL44AY2VuXN6lpN+erbMuI5glWVQLHyD/6Yv5djgs7GPbKs9xCO6bdPu
         LfNA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=co0Vhl0O1U9AJ4ltMtKCVR8fTQuM4YDEuLAVVO9W4G4=;
        b=QQRERDqxeXvBg3mptbIdMW5PMd73fPAt1XfXwxf53dUmjKqMDUSSP25K+/kd6Qe9Xg
         VBAOseSvh6VLSIo5x52KhTd8qKl2HdDMys517oHtmPqvuoY6L5jZj6V/W3nUnCXc3VpN
         n26F6GbZ7NAkbhpjoeqlP9zTPnVUktGQmN66AAopqcIHyPAYa3uDycg6osyPfWk105t3
         Maf+ya+W3h/wcZp/dLLkntH+TeKNDL0kaisPFzA06ptcExz7nh4M3seFJqEkNcboGMWJ
         rpsZN1QvFtQdjafisNNlMl/maHZ2IIeRdFe2eXv8gX/UCHBpkhyqo5RLbgXPCZbAj5jF
         r7Hw==
X-Gm-Message-State: AGRZ1gLFr1CkJNBfUvFwj49hSyuWlOxNdOS7U5q+Jd+fni46AYftI9G8
        PvbfqZY23VG6xk8ytSj7UBF06Bs=
X-Google-Smtp-Source: AJdET5fzh59KXYdL0oJhEbsNajJf9mC0LwTa5sOZrRvK665X4XBbZk/TX1oxEprrJ9LXQ6hoZk8zTA==
X-Received: by 2002:a24:1a55:: with SMTP id 82-v6mr2028246iti.1.1541698619569;
        Thu, 08 Nov 2018 09:36:59 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id f64-v6sm1383121ioa.54.2018.11.08.09.36.58
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Nov 2018 09:36:58 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Don't exit the state manager without clearing NFS4CLNT_MANAGER_RUNNING
Date:   Thu,  8 Nov 2018 12:35:55 -0500
Message-Id: <20181108173556.9295-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If we exit the NFSv4 state manager due to a umount, then we can end up
leaving the NFS4CLNT_MANAGER_RUNNING flag set. If another mount causes
the nfs4_client to be rereferenced before it is destroyed, then we end
up never being able to recover state.

Fixes: 47c2199b6eb5 ("NFSv4.1: Ensure state manager thread dies on last ...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: stable@vger.kernel.org # v4.15+
---
 fs/nfs/nfs4state.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 62ae0fd345ad..98d1b6a6646a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2601,11 +2601,12 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		nfs4_clear_state_manager_bit(clp);
 		/* Did we race with an attempt to give us more work? */
 		if (clp->cl_state == 0)
-			break;
+			return;
 		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
-			break;
+			return;
 	} while (refcount_read(&clp->cl_count) > 1);
-	return;
+	goto out_drain;
+
 out_error:
 	if (strlen(section))
 		section_sep = ": ";
@@ -2613,6 +2614,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			" with error %d\n", section_sep, section,
 			clp->cl_hostname, -status);
 	ssleep(1);
+out_drain:
 	nfs4_end_drain_session(clp);
 	nfs4_clear_state_manager_bit(clp);
 }
-- 
2.19.1

