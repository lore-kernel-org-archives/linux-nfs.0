Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755648AbaGQJ60 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2014 05:58:26 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s6H9wQVO016941
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2014 05:58:26 -0400
From: Slavek Kabrda <bkabrda@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Slavek Kabrda <bkabrda@redhat.com>
Subject: [PATCH] Fix Python 3 compatibility of mountstats and nfs-iostat
Date: Thu, 17 Jul 2014 11:57:32 +0200
Message-Id: <1405591052-17456-1-git-send-email-bkabrda@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Slavek Kabrda <bkabrda@redhat.com>
---
 tools/mountstats/mountstats.py | 2 +-
 tools/nfs-iostat/nfs-iostat.py | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index e46105d..1fb3e2f 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -371,7 +371,7 @@ def parse_stats_file(filename):
     ms_dict = dict()
     key = ''
 
-    f = file(filename)
+    f = open(filename)
     for line in f.readlines():
         words = line.split()
         if len(words) == 0:
diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index b324cd8..61d15a5 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -213,7 +213,8 @@ class DeviceData:
         # the reference to them.  so we build new lists here
         # for the result object.
         for op in result.__rpc_data['ops']:
-            result.__rpc_data[op] = map(difference, self.__rpc_data[op], old_stats.__rpc_data[op])
+            result.__rpc_data[op] = list(map(
+                difference, self.__rpc_data[op], old_stats.__rpc_data[op]))
 
         # update the remaining keys we care about
         result.__rpc_data['rpcsends'] -= old_stats.__rpc_data['rpcsends']
-- 
2.0.1

