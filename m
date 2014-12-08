Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755223AbaLHUwd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:52:33 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KqSoQ017481
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:52:33 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB8KF9IO018387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 15:17:38 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sB8JvRe6010181
	for <linux-nfs@vger.kernel.org>; Mon, 8 Dec 2014 14:57:27 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sB8JvRRt010180
	for linux-nfs@vger.kernel.org; Mon, 8 Dec 2014 14:57:27 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 03/17] mountstats: Refactor __parse_nfs_line and __parse_rpc_line
Date: Mon,  8 Dec 2014 14:57:11 -0500
Message-Id: <1418068645-10134-4-git-send-email-smayhew@redhat.com>
In-Reply-To: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
References: <1418068645-10134-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Iterate over the newly added counter lists instead of having a ton of
assignment statements.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 92 +++++++++++-------------------------------
 1 file changed, 23 insertions(+), 69 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index bf98813..a129d61 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -238,40 +238,18 @@ class DeviceData:
             if self.__nfs_data['flavor'] == 6:
                 self.__nfs_data['pseudoflavor'] = int(keys[1].split('=')[1])
         elif words[0] == 'events:':
-            self.__nfs_data['inoderevalidates'] = int(words[1])
-            self.__nfs_data['dentryrevalidates'] = int(words[2])
-            self.__nfs_data['datainvalidates'] = int(words[3])
-            self.__nfs_data['attrinvalidates'] = int(words[4])
-            self.__nfs_data['vfsopen'] = int(words[5])
-            self.__nfs_data['vfslookup'] = int(words[6])
-            self.__nfs_data['vfspermission'] = int(words[7])
-            self.__nfs_data['vfsupdatepage'] = int(words[8])
-            self.__nfs_data['vfsreadpage'] = int(words[9])
-            self.__nfs_data['vfsreadpages'] = int(words[10])
-            self.__nfs_data['vfswritepage'] = int(words[11])
-            self.__nfs_data['vfswritepages'] = int(words[12])
-            self.__nfs_data['vfsreaddir'] = int(words[13])
-            self.__nfs_data['vfssetattr'] = int(words[14])
-            self.__nfs_data['vfsflush'] = int(words[15])
-            self.__nfs_data['vfsfsync'] = int(words[16])
-            self.__nfs_data['vfslock'] = int(words[17])
-            self.__nfs_data['vfsrelease'] = int(words[18])
-            self.__nfs_data['congestionwait'] = int(words[19])
-            self.__nfs_data['setattrtrunc'] = int(words[20])
-            self.__nfs_data['extendwrite'] = int(words[21])
-            self.__nfs_data['sillyrenames'] = int(words[22])
-            self.__nfs_data['shortreads'] = int(words[23])
-            self.__nfs_data['shortwrites'] = int(words[24])
-            self.__nfs_data['delay'] = int(words[25])
-            self.__nfs_data['pnfsreads'] = int(words[26])
-            self.__nfs_data['pnfswrites'] = int(words[27])
+            i = 1
+            for key in NfsEventCounters:
+                try:
+                    self.__nfs_data[key] = int(words[i])
+                except IndexError as err:
+                    self.__nfs_data[key] = 0
+                i += 1
         elif words[0] == 'bytes:':
-            self.__nfs_data['normalreadbytes'] = int(words[1])
-            self.__nfs_data['normalwritebytes'] = int(words[2])
-            self.__nfs_data['directreadbytes'] = int(words[3])
-            self.__nfs_data['directwritebytes'] = int(words[4])
-            self.__nfs_data['serverreadbytes'] = int(words[5])
-            self.__nfs_data['serverwritebytes'] = int(words[6])
+            i = 1
+            for key in NfsByteCounters:
+                self.__nfs_data[key] = int(words[i])
+                i += 1
 
     def __parse_rpc_line(self, words):
         if words[0] == 'RPC':
@@ -280,44 +258,20 @@ class DeviceData:
         elif words[0] == 'xprt:':
             self.__rpc_data['protocol'] = words[1]
             if words[1] == 'udp':
-                self.__rpc_data['port'] = int(words[2])
-                self.__rpc_data['bind_count'] = int(words[3])
-                self.__rpc_data['rpcsends'] = int(words[4])
-                self.__rpc_data['rpcreceives'] = int(words[5])
-                self.__rpc_data['badxids'] = int(words[6])
-                self.__rpc_data['inflightsends'] = int(words[7])
-                self.__rpc_data['backlogutil'] = int(words[8])
+                i = 2
+                for key in XprtUdpCounters:
+                    self.__rpc_data[key] = int(words[i])
+                    i += 1
             elif words[1] == 'tcp':
-                self.__rpc_data['port'] = words[2]
-                self.__rpc_data['bind_count'] = int(words[3])
-                self.__rpc_data['connect_count'] = int(words[4])
-                self.__rpc_data['connect_time'] = int(words[5])
-                self.__rpc_data['idle_time'] = int(words[6])
-                self.__rpc_data['rpcsends'] = int(words[7])
-                self.__rpc_data['rpcreceives'] = int(words[8])
-                self.__rpc_data['badxids'] = int(words[9])
-                self.__rpc_data['inflightsends'] = int(words[10])
-                self.__rpc_data['backlogutil'] = int(words[11])
+                i = 2
+                for key in XprtTcpCounters:
+                    self.__rpc_data[key] = int(words[i])
+                    i += 1
             elif words[1] == 'rdma':
-                self.__rpc_data['port'] = words[2]
-                self.__rpc_data['bind_count'] = int(words[3])
-                self.__rpc_data['connect_count'] = int(words[4])
-                self.__rpc_data['connect_time'] = int(words[5])
-                self.__rpc_data['idle_time'] = int(words[6])
-                self.__rpc_data['rpcsends'] = int(words[7])
-                self.__rpc_data['rpcreceives'] = int(words[8])
-                self.__rpc_data['badxids'] = int(words[9])
-                self.__rpc_data['backlogutil'] = int(words[10])
-                self.__rpc_data['read_chunks'] = int(words[11])
-                self.__rpc_data['write_chunks'] = int(words[12])
-                self.__rpc_data['reply_chunks'] = int(words[13])
-                self.__rpc_data['total_rdma_req'] = int(words[14])
-                self.__rpc_data['total_rdma_rep'] = int(words[15])
-                self.__rpc_data['pullup'] = int(words[16])
-                self.__rpc_data['fixup'] = int(words[17])
-                self.__rpc_data['hardway'] = int(words[18])
-                self.__rpc_data['failed_marshal'] = int(words[19])
-                self.__rpc_data['bad_reply'] = int(words[20])
+                i = 2
+                for key in XprtRdmaCounters:
+                    self.__rpc_data[key] = int(words[i])
+                    i += 1
         elif words[0] == 'per-op':
             self.__rpc_data['per-op'] = words
         else:
-- 
1.9.3

