Return-Path: <SRS0=jyOK=CF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77E18C433E1
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Aug 2020 16:08:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5C2B52080C
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Aug 2020 16:08:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726147AbgH0QII (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 27 Aug 2020 12:08:08 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45374 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726087AbgH0QIH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2020 12:08:07 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7E5FEC061264
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2020 09:08:07 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id DCE716EED; Thu, 27 Aug 2020 12:08:05 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org DCE716EED
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] MAINTAINERS: Add Documentation/ to files we maintain
Date:   Thu, 27 Aug 2020 12:08:02 -0400
Message-Id: <1598544483-14296-1-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

It struck me while watching Jon Corbet ask how to keep kernel
Documentation up to date, that it might help if we were actually cc'd on
Documentation/filesystems/nfs/ changes.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 MAINTAINERS | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index deaafb617361..5fd2b9990fa6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9482,6 +9482,7 @@ F:	include/linux/sunrpc/
 F:	include/uapi/linux/nfsd/
 F:	include/uapi/linux/sunrpc/
 F:	net/sunrpc/
+F:	Documentation/filesystems/nfs/
 
 KERNEL SELFTEST FRAMEWORK
 M:	Shuah Khan <shuah@kernel.org>
@@ -12233,6 +12234,7 @@ F:	include/linux/sunrpc/
 F:	include/uapi/linux/nfs*
 F:	include/uapi/linux/sunrpc/
 F:	net/sunrpc/
+F:	Documentation/filesystems/nfs/
 
 NILFS2 FILESYSTEM
 M:	Ryusuke Konishi <konishi.ryusuke@gmail.com>
-- 
2.26.2

