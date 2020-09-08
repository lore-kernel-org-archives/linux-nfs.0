Return-Path: <SRS0=kBQ9=CR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01398C433E2
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Sep 2020 21:22:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B035D2145D
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Sep 2020 21:22:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1599600131;
	bh=xjGHLZ644R5X1ZIl/BOJou1nJG4aRxf6oUivukUN47Y=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=IBw+WEM+BTTHaGNy26RCVT0YCSKU8AYcxPnDIZx0vDuBT17ecsKz+ZuxjmxODNDtT
	 LqOoaKDzw5ATluteMjy8GZugvqPKW/ObeYWqSIKSW2LJnWWvjjwOGKoc/TV8tehW73
	 apwyVoFtAkmEqpWc1zhWn94YPqhasmCklOk2MhFg=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728458AbgIHVWK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Sep 2020 17:22:10 -0400
Received: from mail.kernel.org ([198.145.29.99]:50178 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728390AbgIHVWI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Sep 2020 17:22:08 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A2AFE2087C;
        Tue,  8 Sep 2020 21:22:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1599600127;
        bh=xjGHLZ644R5X1ZIl/BOJou1nJG4aRxf6oUivukUN47Y=;
        h=From:To:Cc:Subject:Date:From;
        b=jwiJ0E22INV4/swU/NgewPUJ4jLbJLeaQIt4vIOT8NtEQU+ic0FSW9/v05sQudtmX
         PSp7hT3RyMTUwMmpxzl8FEEj7VtqaJblDhPnW9dSBfTAe6AaZuhATY9nbVqALss17e
         ejBPciOkXPAMFi0URUhbES5PPQlb/nVdhszIdlg0=
From:   trondmy@kernel.org
To:     Steve Dickson <SteveD@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] mountd: Ignore transient and non-fatal filesystem errors in nfsd_export
Date:   Tue,  8 Sep 2020 17:19:58 -0400
Message-Id: <20200908211958.38741-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

If the mount point check in nfsd_export fails due to a transient error,
then ignore it to avoid spurious NFSERR_STALE errors being returned by
knfsd.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 utils/mountd/cache.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 6cba2883026f..93e868341d15 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -1411,7 +1411,10 @@ static void nfsd_export(int f)
 
 		if (mp && !*mp)
 			mp = found->m_export.e_path;
-		if (mp && !is_mountpoint(mp))
+		errno = 0;
+		if (mp && !is_mountpoint(mp)) {
+			if (errno != 0 && !path_lookup_error(errno))
+				goto out;
 			/* Exportpoint is not mounted, so tell kernel it is
 			 * not available.
 			 * This will cause it not to appear in the V4 Pseudo-root
@@ -1420,9 +1423,12 @@ static void nfsd_export(int f)
 			 * And filehandle for this mountpoint from an earlier
 			 * mount will block in nfsd.fh lookup.
 			 */
+			xlog(L_WARNING,
+			     "Cannot export path '%s': not a mountpoint",
+			     path);
 			dump_to_cache(f, buf, sizeof(buf), dom, path,
 				      NULL, 60);
-		else if (dump_to_cache(f, buf, sizeof(buf), dom, path,
+		} else if (dump_to_cache(f, buf, sizeof(buf), dom, path,
 					 &found->m_export, 0) < 0) {
 			xlog(L_WARNING,
 			     "Cannot export %s, possibly unsupported filesystem"
-- 
2.26.2

