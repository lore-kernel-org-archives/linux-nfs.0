Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:38151 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932547AbbDHQre (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 12:47:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <steved@redhat.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 2/2] mountstats: Only count operations that have names
Date: Wed, 8 Apr 2015 12:47:27 -0400
Message-ID: <1428511647-14920-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

GETDEVICELIST was removed from the kernel, but due to the way the client
is coded it still shows up in /proc/self/mountstats as "51".  This
causes mountstats to crash when asked to output "raw" statistics, so
this patch teaches mountsats to ignore any operations that only have
numeric names.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 tools/mountstats/mountstats.py | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 8f2e26e..5f243ac 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -284,8 +284,9 @@ class DeviceData:
             self.__rpc_data['per-op'] = words
         else:
             op = words[0][:-1]
-            self.__rpc_data['ops'] += [op]
-            self.__rpc_data[op] = [int(word) for word in words[1:]]
+            if not op.isnumeric():
+                self.__rpc_data['ops'] += [op]
+                self.__rpc_data[op] = [int(word) for word in words[1:]]
 
     def parse_stats(self, lines):
         """Turn a list of lines from a mount stat file into a 
-- 
2.3.5

