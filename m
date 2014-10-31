Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:41682 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaJaVTT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Oct 2014 17:19:19 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn18so1694006igb.15
        for <linux-nfs@vger.kernel.org>; Fri, 31 Oct 2014 14:19:18 -0700 (PDT)
Subject: [PATCH] mountstats: Don't display retrans stats unless there are
 re-xmits
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 31 Oct 2014 17:19:17 -0400
Message-ID: <20141031211917.13278.61844.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up display of RPC statistics by omitting retransmit statistics
when there have been no retransmissions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 tools/mountstats/mountstats.py |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index 1fb3e2f..9a6ec43 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -272,8 +272,11 @@ class DeviceData:
                 print('%s:' % op)
                 print('\t%d ops (%d%%)' % \
                     (count, ((count * 100) / sends)), end=' ')
-                print('\t%d retrans (%d%%)' % (retrans, ((retrans * 100) / count)), end=' ')
-                print('\t%d major timeouts' % stats[2])
+                if retrans != 0:
+                    print('\t%d retrans (%d%%)' % (retrans, ((retrans * 100) / count)), end=' ')
+                    print('\t%d major timeouts' % stats[2])
+                else:
+                    print('')
                 print('\tavg bytes sent per op: %d\tavg bytes received per op: %d' % \
                     (stats[3] / count, stats[4] / count))
                 print('\tbacklog wait: %f' % (float(stats[5]) / count), end=' ')

