From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS iostats - add RDMA statistics
Date: Mon, 09 Jun 2008 12:47:44 -0400
Message-ID: <20080609164744.5461.95795.stgit@ellison.1015granger.net>
References: <20080609163029.5461.35699.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:27089 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbYFIQtT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2008 12:49:19 -0400
In-Reply-To: <20080609163029.5461.35699.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Talpey <tmt@netapp.com>

Add RDMA as a supported transport for reporting statistics

Signed-off-by: Tom Talpey <tmt@netapp.com>
Acked-by: Chuck Lever <chuck.lever@oracle.com>
---

 tools/nfs-iostat/nfs-iostat.py |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)


diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 794d4a8..649c1bd 100755
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -134,6 +134,26 @@ class DeviceData:
                 self.__rpc_data['badxids'] = int(words[9])
                 self.__rpc_data['inflightsends'] = long(words[10])
                 self.__rpc_data['backlogutil'] = long(words[11])
+            elif words[1] == 'rdma':
+                self.__rpc_data['port'] = words[2]
+                self.__rpc_data['bind_count'] = int(words[3])
+                self.__rpc_data['connect_count'] = int(words[4])
+                self.__rpc_data['connect_time'] = int(words[5])
+                self.__rpc_data['idle_time'] = int(words[6])
+                self.__rpc_data['rpcsends'] = int(words[7])
+                self.__rpc_data['rpcreceives'] = int(words[8])
+                self.__rpc_data['badxids'] = int(words[9])
+                self.__rpc_data['backlogutil'] = int(words[10])
+                self.__rpc_data['read_chunks'] = int(words[11])
+                self.__rpc_data['write_chunks'] = int(words[12])
+                self.__rpc_data['reply_chunks'] = int(words[13])
+                self.__rpc_data['total_rdma_req'] = int(words[14])
+                self.__rpc_data['total_rdma_rep'] = int(words[15])
+                self.__rpc_data['pullup'] = int(words[16])
+                self.__rpc_data['fixup'] = int(words[17])
+                self.__rpc_data['hardway'] = int(words[18])
+                self.__rpc_data['failed_marshal'] = int(words[19])
+                self.__rpc_data['bad_reply'] = int(words[20])
         elif words[0] == 'per-op':
             self.__rpc_data['per-op'] = words
         else:

