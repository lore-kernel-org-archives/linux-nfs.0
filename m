Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbbBTSt3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2015 13:49:29 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1KInSnw016321
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 20 Feb 2015 13:49:28 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mountd: Fix memory leak in getexportent
Date: Fri, 20 Feb 2015 13:49:27 -0500
Message-Id: <1424458167-58324-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Valgrind shows that the memory allocated for ee.e_hostname in
getexportent() is being leaked.  While there _is_ a call to xfree(), by
the time it gets called the leak's already happened.  Moving the xfree()
call so that it occurs before the assignment that overwrites ee fixes
this.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/nfs/exports.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index eb782b9..4b17d3c 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -154,6 +154,7 @@ getexportent(int fromkernel, int fromexports)
 		}
 	}
 
+	xfree(ee.e_hostname);
 	ee = def_ee;
 
 	/* Check for default client */
@@ -176,7 +177,6 @@ getexportent(int fromkernel, int fromexports)
 		if (!has_default_opts)
 			xlog(L_WARNING, "No options for %s %s: suggest %s(sync) to avoid warning", ee.e_path, exp, exp);
 	}
-	xfree(ee.e_hostname);
 	ee.e_hostname = xstrdup(hostname);
 
 	if (parseopts(opt, &ee, fromexports && !has_default_subtree_opts, NULL) < 0)
-- 
1.9.3

