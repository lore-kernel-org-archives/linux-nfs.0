Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35321 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751901AbdLSQff (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Dec 2017 11:35:35 -0500
Received: by mail-io0-f194.google.com with SMTP id 14so7722338iou.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Dec 2017 08:35:34 -0800 (PST)
Subject: [PATCH] mountstats: Use correct RDMA terminology
From: Chuck Lever <chuck.lever@oracle.com>
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 19 Dec 2017 11:35:32 -0500
Message-ID: <20171219163529.10803.82407.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel is counting RDMA segments, not chunks. Correct the units
labels displayed by "mountstats -x", and fix up the internal names
of the counters.

Fixes: 6742ba53ae79 ("mountstats: Add option to pretty-print ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 tools/mountstats/mountstats.py |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 440aa72..c7fb8bb 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -120,9 +120,9 @@ XprtRdmaCounters = [
     'badxids',
     'inflightsends',
     'backlogutil',
-    'read_chunks',
-    'write_chunks',
-    'reply_chunks',
+    'read_segments',
+    'write_segments',
+    'reply_segments',
     'total_rdma_req',
     'total_rdma_rep',
     'pullup',
@@ -718,9 +718,9 @@ class DeviceData:
             if self.__rpc_data['rpcsends'] != 0:
                 print('\tAvg backlog length: %d' % \
                     (float(self.__rpc_data['backlogutil']) / self.__rpc_data['rpcsends']))
-            print('\tRead chunks: %d' % self.__rpc_data['read_chunks'])
-            print('\tWrite chunks: %d' % self.__rpc_data['write_chunks'])
-            print('\tReply chunks: %d' % self.__rpc_data['reply_chunks'])
+            print('\tRead segments: %d' % self.__rpc_data['read_segments'])
+            print('\tWrite segments: %d' % self.__rpc_data['write_segments'])
+            print('\tReply segments: %d' % self.__rpc_data['reply_segments'])
             print('\tRegistered: %d bytes' % self.__rpc_data['total_rdma_req'])
             print('\tRDMA received: %d bytes' % self.__rpc_data['total_rdma_rep'])
             print('\tTotal pull-up: %d bytes' % self.__rpc_data['pullup'])

