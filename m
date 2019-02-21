Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C16F6C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 20:47:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 91C40206C0
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 20:47:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="j7M7cTBl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725891AbfBUUrI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 15:47:08 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:43612 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725866AbfBUUrH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2019 15:47:07 -0500
Received: by mail-io1-f67.google.com with SMTP id y6so3547300ioq.10
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2019 12:47:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=roSH0dxLJtYvsgvr0RfnIDg8XkznY0JX22/hNncAaTk=;
        b=j7M7cTBlCMZe4Ao0DAe2y2Dr4H877GweBf7KCxe1uvnqzwLy4mnTdP6lypPs54D39p
         aaLjThH5LgGihRvdoirwtJTR+N2vrUPwcUyEC2dEG/y7hphgyly/8pg87yIXMvk8Vnlm
         LMIYv8a+3No/qjI6eoM1XoJZZlQEI6u/lHdB1rSCezfr5YY6oJB0wb9CB3yyQ5D3cqg9
         +yWCXyAnQIMXgsitsOuvl1LpYiMPKmkCBlAKTatjmDgZs3OiT4u68czG82fR5auHZXu7
         M7S2M2UBOv2jvl1rSEdq0c6zhVZIzBehkM59rFUg9gr/4Gj890PFaenmUebXBEQhQRcH
         N3Vw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=roSH0dxLJtYvsgvr0RfnIDg8XkznY0JX22/hNncAaTk=;
        b=IQdQVnlbU6zW/DTS9wAZzJKPDgQnsmHK1xocwsq8EzWSZyAODzObBsjzWeI3ZCxXWQ
         PT9Ryp+1jO9VBc8YoQ1BOZZ2z3gdF5bMt8E/ieqK/YtPbCAV1/ot5wW5IYCf7HxTzC/Z
         iqQPe60NZc06BLV8IJCFDyMN+zXpqZKe30g8xVrTba1pV00qVgmFY1H6j8i2L5auMjRn
         97gOAdQI59o3qmbDI+egVizu2DE9k8yt2+S9yz0WnbjyytemqJbb5dMQQZImNe8xlw28
         tWKa8Km0/MDQfB5LhYEulYl/RskKA54AAthVC2QBLlgRdpXhIlpsrtKChGwkNHwWwFq4
         +Vsg==
X-Gm-Message-State: AHQUAuZv4rJpLYbDb2qpA4Hvf8rrVdfBhuFSuc4y+el1n5TzJ1gxCv7v
        oewEdGehe12KG167ghmVjMQ5KUM=
X-Google-Smtp-Source: AHgI3IYlaKYgR7Lihg4pYJZhZ0q5GrItbEIbtWxRFRc0H7fWUJkWYuyxZ6dsM6EhbZ2e9o+19ahCdg==
X-Received: by 2002:a6b:b644:: with SMTP id g65mr311814iof.198.1550782026113;
        Thu, 21 Feb 2019 12:47:06 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r17sm4896643ita.31.2019.02.21.12.47.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Feb 2019 12:47:05 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix a soft lockup in the delegation recovery code
Date:   Thu, 21 Feb 2019 15:45:58 -0500
Message-Id: <20190221204558.30590-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fix a soft lockup when NFS client delegation recovery is attempted
but the inode is in the process of being freed. When the
igrab(inode) call fails, and we have to restart the recovery process,
we need to ensure that we won't attempt to recover the same delegation
again.

Fixes: 45870d6909d5a ("NFSv4.1: Test delegation stateids when server...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c | 20 ++++++++++++--------
 fs/nfs/delegation.h |  1 +
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 70e5931f3c60..2f6b447cdd82 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -229,6 +229,8 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
 	spin_lock(&delegation->lock);
 	if (delegation->inode != NULL)
 		inode = igrab(delegation->inode);
+	if (!inode)
+		set_bit(NFS_DELEGATION_INODE_FREEING, &delegation->flags);
 	spin_unlock(&delegation->lock);
 	return inode;
 }
@@ -944,10 +946,11 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry_rcu(delegation, &server->delegations,
 								super_list) {
-			if (test_bit(NFS_DELEGATION_RETURNING,
-						&delegation->flags))
-				continue;
-			if (test_bit(NFS_DELEGATION_NEED_RECLAIM,
+			if (test_bit(NFS_DELEGATION_INODE_FREEING,
+						&delegation->flags) ||
+			    test_bit(NFS_DELEGATION_RETURNING,
+						&delegation->flags) ||
+			    test_bit(NFS_DELEGATION_NEED_RECLAIM,
 						&delegation->flags) == 0)
 				continue;
 			if (!nfs_sb_active(server->super))
@@ -1053,10 +1056,11 @@ void nfs_reap_expired_delegations(struct nfs_client *clp)
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry_rcu(delegation, &server->delegations,
 								super_list) {
-			if (test_bit(NFS_DELEGATION_RETURNING,
-						&delegation->flags))
-				continue;
-			if (test_bit(NFS_DELEGATION_TEST_EXPIRED,
+			if (test_bit(NFS_DELEGATION_INODE_FREEING,
+						&delegation->flags) ||
+			    test_bit(NFS_DELEGATION_RETURNING,
+						&delegation->flags) ||
+			    test_bit(NFS_DELEGATION_TEST_EXPIRED,
 						&delegation->flags) == 0)
 				continue;
 			if (!nfs_sb_active(server->super))
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index dcbf3394ba0e..35b4b02c1ae0 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -34,6 +34,7 @@ enum {
 	NFS_DELEGATION_RETURNING,
 	NFS_DELEGATION_REVOKED,
 	NFS_DELEGATION_TEST_EXPIRED,
+	NFS_DELEGATION_INODE_FREEING,
 };
 
 int nfs_inode_set_delegation(struct inode *inode, const struct cred *cred,
-- 
2.20.1

