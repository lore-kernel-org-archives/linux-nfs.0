Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38742 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718AbbLJRHE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Dec 2015 12:07:04 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 7397FC001274
	for <linux-nfs@vger.kernel.org>; Thu, 10 Dec 2015 17:07:04 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 2/2] mountstats: add missing v4.2 operations
Date: Thu, 10 Dec 2015 12:07:03 -0500
Message-Id: <1449767223-52696-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1449767223-52696-1-git-send-email-smayhew@redhat.com>
References: <1449767223-52696-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 1e2811f..4ca4bc4 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -150,6 +150,8 @@ Nfsv3ops = [
     'COMMIT'
 ]
 
+# This list should be kept in-sync with the NFSPROC4_CLNT_* enum in
+# include/linux/nfs4.h in the kernel.
 Nfsv4ops = [
     'NULL',
     'READ',
@@ -204,7 +206,12 @@ Nfsv4ops = [
     'FREE_STATEID',
     'GETDEVICELIST',
     'BIND_CONN_TO_SESSION',
-    'DESTROY_CLIENTID'
+    'DESTROY_CLIENTID',
+    'SEEK',
+    'ALLOCATE',
+    'DEALLOCATE',
+    'LAYOUTSTATS',
+    'CLONE'
 ]
 
 class DeviceData:
-- 
2.4.3

