Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:41421 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934931Ab2JXP0R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 11:26:17 -0400
Received: by mail-ye0-f174.google.com with SMTP id m12so88823yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 08:26:17 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/10] nfsdcltrack: update the README about server startup order
Date: Wed, 24 Oct 2012 11:25:58 -0400
Message-Id: <1351092359-25842-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
References: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that nfsdcld is gone, remove the section about starting it up.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 README | 23 ++---------------------
 1 file changed, 2 insertions(+), 21 deletions(-)

diff --git a/README b/README
index e55b2dd..61702f7 100644
--- a/README
+++ b/README
@@ -108,31 +108,12 @@ scripts can be written to work correctly.
        the lock.
        rpc.statd is only needed for NFSv2 and NFSv3 support.
 
-   E/ nfsdcld
-       This daemon is only needed on kernels that support the nfsdcld
-       upcall, and only if the legacy client ID tracking isn't used. It
-       is also not needed if the server does not support NFSv4.
-
-       To determine whether you need this or not, do the following:
-
-           # cat /proc/fs/nfsd/versions
-
-       That should yield a list of NFS versions that this kernel supports,
-       if "4" or later is not in that list, or they are prefixed with a "-"
-       then you don't need to run this daemon. Next:
-
-           # cat /proc/fs/nfsd/nfsv4recoverydir
-
-       If that file is not present, or the directory that the above command
-       outputs is not present, then this daemon is required in order to
-       support lock recovery by the clients when the server reboots.
-
-   F/ rpc.nfsd
+   E/ rpc.nfsd
        Starting nfsd will automatically start lockd.  The nfs server
        will now be fully active and respond to any requests from
        clients.
        
-   G/ sm-notify
+   F/ sm-notify
        This will notify any client which might have locks from before
        a reboot to try to reclaim their locks.  This should start
        immediately after rpc.nfsd is started so that clients have a
-- 
1.7.11.7

