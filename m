Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:38295 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab2JALw5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 07:52:57 -0400
Received: by mail-gh0-f174.google.com with SMTP id g15so1356084ghb.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2012 04:52:57 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] nfsdcltrack: update the README about server startup order
Date: Mon,  1 Oct 2012 07:52:45 -0400
Message-Id: <1349092365-23920-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
References: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we eventually deprecate nfsdcld, then we can just remove this
section I think.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 README | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/README b/README
index e55b2dd..f997783 100644
--- a/README
+++ b/README
@@ -110,8 +110,9 @@ scripts can be written to work correctly.
 
    E/ nfsdcld
        This daemon is only needed on kernels that support the nfsdcld
-       upcall, and only if the legacy client ID tracking isn't used. It
-       is also not needed if the server does not support NFSv4.
+       upcall, and only if the legacy client ID tracking and nfsdcltrack
+       aren't used. It is also not needed if the server does not support
+       NFSv4.
 
        To determine whether you need this or not, do the following:
 
@@ -124,7 +125,12 @@ scripts can be written to work correctly.
            # cat /proc/fs/nfsd/nfsv4recoverydir
 
        If that file is not present, or the directory that the above command
-       outputs is not present, then this daemon is required in order to
+       outputs is not present, then check this:
+
+	   # modinfo nfsd | grep cltrack_prog
+
+       to see whether the kernel supports the nfsdcltrack upcall. If
+       none of those are configured then this daemon is required in order to
        support lock recovery by the clients when the server reboots.
 
    F/ rpc.nfsd
-- 
1.7.11.4

