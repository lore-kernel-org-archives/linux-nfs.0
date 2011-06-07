Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751540Ab1FGP43 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 11:56:29 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p57FuT3C004897
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Jun 2011 11:56:29 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p57FuTmG025079
	for <linux-nfs@vger.kernel.org>; Tue, 7 Jun 2011 11:56:29 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] mountd: group length not being set correctly in auth_unix_gid
Date: Tue,  7 Jun 2011 11:56:28 -0400
Message-Id: <1307462188-13122-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Rinat Bikov <becase@altlinux.org>

Commit 9274e94d introduce dynamic buffering for gids lists.
In that patch there was a bug that only used the dynamic
length on the first call, resulting in the dynamic length
not being dynamic at all.

Reported-by: Rinat Bikov <becase@altlinux.org>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/cache.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 0c4a03d..6084893 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -147,8 +147,9 @@ static void auth_unix_gid(FILE *f)
 		if (!groups)
 			return;
 
-		groups_len = ngroups = INITIAL_MANAGED_GROUPS;
+		groups_len = INITIAL_MANAGED_GROUPS;
 	}
+	ngroups = groups_len;
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
-- 
1.7.5.1

