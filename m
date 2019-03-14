Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48922C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 18:56:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1EF2B217F5
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 18:56:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552589805;
	bh=ft2SeFa17CcNFTN19G/fHahY4DS5/12bEHodVW4v+nA=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=Pyq5wpB9iGTEDi6mldHmKNizmtPei//ZwDAmZ4jHKT/Eeot1d5CjsHTCzg5lapEl6
	 lDXIqkMbWpuaf8b2Y0bzYG8TxQWyfye8yWLehU9WqggCyB3HHbWV8U1Fv0vs8Sod9H
	 kjv7c7iWAHHx0DI7ZPantdGG9doHKyH8JYCKPzhA=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727608AbfCNS4o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 14:56:44 -0400
Received: from mail.kernel.org ([198.145.29.99]:46092 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727606AbfCNS4n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 14:56:43 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A6215217F5;
        Thu, 14 Mar 2019 18:56:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1552589803;
        bh=ft2SeFa17CcNFTN19G/fHahY4DS5/12bEHodVW4v+nA=;
        h=From:To:Cc:Subject:Date:From;
        b=LBrlHYZ3DMw6johmlsEqyhe/tdWq5tXHdAx2ChjISuKib9BK/yldDdTAaxrOdDRMo
         yhvdssHNODZLe2GVfF8aw35n9Cv3H7Bc0LqIdupEsDOn1ZmEL4PkO6RbEFDdN31Kr1
         emDiwF1NTzcUZDni6Kat1NJQ0zoFS+8ZSP/RsTZo=
From:   Jeff Layton <jlayton@kernel.org>
To:     bfields@fieldses.net
Cc:     linux-nfs@vger.kernel.org
Subject: [pynfs PATCH] nfs4.1: clean up the session and client created in Environment.init()
Date:   Thu, 14 Mar 2019 14:56:41 -0400
Message-Id: <20190314185641.1048-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Once we've returned from this function the session and client will be
abandoned on the server. Clean them up since we're finished with them
at this point.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/environment.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 0ce6943b19a5..bdfd52d3a171 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -156,6 +156,8 @@ class Environment(testmod.Environment):
         # Make sure it is empty
         clean_dir(sess, self.opts.home)
         sess.c.null()
+        self.clean_sessions()
+        self.clean_clients()
 
     def _maketree(self, sess):
         """Make test tree"""
-- 
2.20.1

