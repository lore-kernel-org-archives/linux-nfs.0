Return-Path: <SRS0=m2wh=5B=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C71F9C0044D
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Mar 2020 21:01:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 95DE5206C0
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Mar 2020 21:01:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732632AbgCPVBr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 16 Mar 2020 17:01:47 -0400
Received: from fieldses.org ([173.255.197.46]:54828 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732601AbgCPVBq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Mar 2020 17:01:46 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 8C2AC1C7B; Mon, 16 Mar 2020 17:01:46 -0400 (EDT)
Date:   Mon, 16 Mar 2020 17:01:46 -0400
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] exports man page: warn about subdirectory exports
Message-ID: <20200316210146.GJ6938@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Subdirectory exports have a number of problems which have been poorly
documented.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/exportfs/exports.man | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index e3a16f6b276a..1d1718494e83 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -494,6 +494,33 @@ export entry for
 .B /home/joe
 in the example section below, which maps all requests to uid 150 (which
 is supposedly that of user joe).
+
+.SS Subdirectory Exports
+
+Normally you should only export only the root of a filesystem.  The NFS
+server will also allow you to export a subdirectory of a filesystem,
+however, this has drawbacks:
+
+First, it may be possible for a malicious user to access files on the
+filesystem outside of the exported subdirectory, by guessing filehandles
+for those other files.  The only way to prevent this is by using the
+.IR no_subtree_check
+option, which can cause other problems.
+
+Second, export options may not be enforced in the way that you would
+expect.  For example, the
+.IR security_label
+option will not work on subdirectory exports, and if nested subdirectory
+exports change the
+.IR security_label
+or
+.IR sec=
+options, NFSv4 clients will normally see only the options on the parent
+export.  Also, where security options differ, a malicious client may use
+filehandle-guessing attacks to access the files from one subdirectory
+using the options from another.
+
+
 .SS Extra Export Tables
 After reading 
 .I /etc/exports 
-- 
2.24.1

