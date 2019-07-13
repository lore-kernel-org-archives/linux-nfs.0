Return-Path: <SRS0=tbzZ=VK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.8 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FB34C742A7
	for <linux-nfs@archiver.kernel.org>; Sat, 13 Jul 2019 04:12:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E77C208E4
	for <linux-nfs@archiver.kernel.org>; Sat, 13 Jul 2019 04:12:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727488AbfGMEMn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 13 Jul 2019 00:12:43 -0400
Received: from nibbler.cm4all.net ([82.165.145.151]:37169 "EHLO
        nibbler.cm4all.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726395AbfGMEMm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jul 2019 00:12:42 -0400
Received: from localhost (localhost [127.0.0.1])
        by nibbler.cm4all.net (Postfix) with ESMTP id BC931C018A
        for <linux-nfs@vger.kernel.org>; Sat, 13 Jul 2019 06:12:19 +0200 (CEST)
X-Virus-Scanned: Debian amavisd-new at nibbler.cm4all.net
Received: from nibbler.cm4all.net ([127.0.0.1])
        by localhost (nibbler.cm4all.net [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id BiINKmHZdAb0 for <linux-nfs@vger.kernel.org>;
        Sat, 13 Jul 2019 06:12:19 +0200 (CEST)
Received: from zero.intern.cm-ag (zero.intern.cm-ag [172.30.16.10])
        by nibbler.cm4all.net (Postfix) with SMTP id 915FCC01AA
        for <linux-nfs@vger.kernel.org>; Sat, 13 Jul 2019 06:12:19 +0200 (CEST)
Received: (qmail 30898 invoked from network); 13 Jul 2019 06:43:57 +0200
Received: from unknown (HELO rabbit.intern.cm-ag) (172.30.3.1)
  by zero.intern.cm-ag with SMTP; 13 Jul 2019 06:43:57 +0200
Received: by rabbit.intern.cm-ag (Postfix, from userid 1023)
        id 50825460C4C; Sat, 13 Jul 2019 06:12:14 +0200 (CEST)
From:   Max Kellermann <mk@cm4all.com>
To:     linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@hammerspace.com, bfields@redhat.com, tytso@mit.edu,
        adilger.kernel@dilger.ca, hughd@google.com,
        anna.schumaker@netapp.com
Cc:     linux-kernel@vger.kernel.org, Max Kellermann <mk@cm4all.com>,
        stable@vger.kernel.org
Subject: [PATCH v2 1/4] fs/posix_acl: apply umask if superblock disables ACL support
Date:   Sat, 13 Jul 2019 06:11:57 +0200
Message-Id: <20190713041200.18566-1-mk@cm4all.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The function posix_acl_create() applies the umask only if the inode
has no ACL (= NULL) or if ACLs are not supported by the filesystem
driver (= -EOPNOTSUPP).

However, this happens only after after the IS_POSIXACL() check
succeeeded.  If the superblock doesn't enable ACL support, umask will
never be applied.  A filesystem which has no ACL support will of
course not enable SB_POSIXACL, rendering the umask-applying code path
unreachable.

This fixes a bug which causes the umask to be ignored with O_TMPFILE
on tmpfs:

 https://github.com/MusicPlayerDaemon/MPD/issues/558
 https://bugs.gentoo.org/show_bug.cgi?id=686142#c3
 https://bugzilla.kernel.org/show_bug.cgi?id=203625

Signed-off-by: Max Kellermann <mk@cm4all.com>
Cc: stable@vger.kernel.org
---
 fs/posix_acl.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 84ad1c90d535..4071c66f234a 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -589,9 +589,14 @@ posix_acl_create(struct inode *dir, umode_t *mode,
 	*acl = NULL;
 	*default_acl = NULL;
 
-	if (S_ISLNK(*mode) || !IS_POSIXACL(dir))
+	if (S_ISLNK(*mode))
 		return 0;
 
+	if (!IS_POSIXACL(dir)) {
+		*mode &= ~current_umask();
+		return 0;
+	}
+
 	p = get_acl(dir, ACL_TYPE_DEFAULT);
 	if (!p || p == ERR_PTR(-EOPNOTSUPP)) {
 		*mode &= ~current_umask();
-- 
2.20.1

