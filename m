Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:38151 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932444AbbDHQrd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 12:47:33 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <steved@redhat.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 1/2] mountstats: Resync NFSv4 Operations List
Date: Wed, 8 Apr 2015 12:47:26 -0400
Message-ID: <1428511647-14920-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've added several operations and removed GETDEVICELIST,  Let's keep
the Nfsv4ops list up to date with the kernel.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tools/mountstats/mountstats.py | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 38943eb..8f2e26e 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -195,16 +195,18 @@ Nfsv4ops = [
     'SEQUENCE',
     'GET_LEASE_TIME',
     'RECLAIM_COMPLETE',
-    'LAYOUTGET',
     'GETDEVICEINFO',
+    'LAYOUTGET',
     'LAYOUTCOMMIT',
     'LAYOUTRETURN',
     'SECINFO_NO_NAME',
     'TEST_STATEID',
     'FREE_STATEID',
-    'GETDEVICELIST',
     'BIND_CONN_TO_SESSION',
-    'DESTROY_CLIENTID'
+    'DESTROY_CLIENTID',
+    'SEEK',
+    'ALLOCATE',
+    'DEALLOCATE',
 ]
 
 class DeviceData:
-- 
2.3.5

