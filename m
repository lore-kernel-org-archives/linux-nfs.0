Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46265 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab2BAPpN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 10:45:13 -0500
Received: by mail-qy0-f174.google.com with SMTP id w6so740319qcq.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Feb 2012 07:45:13 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 9/9] nfsdcld: update the README
Date: Wed,  1 Feb 2012 10:44:56 -0500
Message-Id: <1328111096-28430-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
References: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add info to the README about when this daemon should be started, and
its build and runtime requirements.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 README |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/README b/README
index e7588cf..cb1d2f5 100644
--- a/README
+++ b/README
@@ -15,6 +15,8 @@ libraries.  They are available from
    http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/
 Otherwise use --disable-nfsv4
 
+To use the nfsdcld tracking daemon, nfsv4 support must be enabled,
+and the libsqlite3 development libraries must be installed.
 
 1. COMPILING
 
@@ -106,12 +108,31 @@ scripts can be written to work correctly.
        the lock.
        rpc.statd is only needed for NFSv2 and NFSv3 support.
 
-   E/ rpc.nfsd
+   E/ nfsdcld
+       This daemon is only needed on kernels that support the nfsdcld
+       upcall, and only if the legacy client ID tracking isn't used. It
+       is also not needed if the server does not support NFSv4.
+
+       To determine whether you need this or not, do the following:
+
+           # cat /proc/fs/nfsd/versions
+
+       That should yield a list of NFS versions that this kernel supports,
+       if "4" or later is not in that list, or they are prefixed with a "-"
+       then you don't need to run this daemon. Next:
+
+           # cat /proc/fs/nfsd/nfsv4recoverydir
+
+       If that file is not present, or the directory that the above command
+       outputs is not present, then this daemon is required in order to
+       support lock recovery by the clients when the server reboots.
+
+   F/ rpc.nfsd
        Starting nfsd will automatically start lockd.  The nfs server
        will now be fully active and respond to any requests from
        clients.
        
-   F/ sm-notify
+   G/ sm-notify
        This will notify any client which might have locks from before
        a reboot to try to reclaim their locks.  This should start
        immediately after rpc.nfsd is started so that clients have a
-- 
1.7.7.6

