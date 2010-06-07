Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([198.187.190.101]:65091 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498Ab0FGWlG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 18:41:06 -0400
From: Kevin Constantine <Kevin.Constantine@disneyanimation.com>
To: chuck.lever@oracle.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org,
        Kevin Constantine <Kevin.Constantine@disney.com>
Subject: [PATCH 1/1] nfs-iostat.py: divide by zero with fresh mount
Date: Mon,  7 Jun 2010 15:40:27 -0700
Message-Id: <1275950427-10200-1-git-send-email-kevin.constantine@disneyanimation.com>
In-Reply-To: <4C06913A.7090608@disney.com>
References: <4C06913A.7090608@disney.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When an export is freshly mounted, /proc/self/mountstats displays age = 0.
This causes nfs-iostat.py to divide by zero throwing an error.  When we
have age = 0, other stats are greater than 0, so we'll set age = 1 and
print the relevant stats.

Signed-off-by: Kevin Constantine <kevin.constantine@disneyanimation.com>
---
 tools/nfs-iostat/nfs-iostat.py |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 2d0b143..1207674 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -366,6 +366,12 @@ class DeviceData:
         sends = float(self.__rpc_data['rpcsends'])
         if sample_time == 0:
             sample_time = float(self.__nfs_data['age'])
+        #  sample_time could still be zero if the export was just mounted.
+        #  Set it to 1 to avoid divide by zero errors in this case since we'll
+        #  likely still have relevant mount statistics to show.
+        #
+        if sample_time == 0:
+            sample_time = 1;
         if sends != 0:
             backlog = (float(self.__rpc_data['backlogutil']) / sends) / sample_time
         else:
-- 
1.6.5.2

