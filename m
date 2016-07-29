Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35058 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbcG2FEn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 01:04:43 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 29 Jul 2016 15:03:36 +1000
Subject: [PATCH 1/7] nfs.man: clarify effect of 'retry' option.
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <146976861647.20186.11572870441721752708.stgit@noble>
In-Reply-To: <146976807524.20186.8871903418718212567.stgit@noble>
References: <146976807524.20186.8871903418718212567.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The total timeout for a "mount" attempt to a non-responsive server
will always be a multiple of the time a single mount attempt in the
kernel takes, which for TCP defaults to about 4 minutes.

The documentation for the "retry" option seems to suggest that this can be used
to set a maximum but it really sets a time after which to stop retrying.
The total can be as much as "retry" plus the time for a single attempt.

So clarify the documentation a bit, and also note that retrans
defaults are different for UDP and TCP:
   #define NFS_DEF_UDP_RETRANS	(3)
   #define NFS_DEF_TCP_RETRANS	(2)

Reported-by: Howard Guo<hguo@suse.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/nfs.man |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index e541cdc95cb1..a0f790a5961b 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -158,8 +158,8 @@ up to a maximum timeout length of 60 seconds.
 The number of times the NFS client retries a request before
 it attempts further recovery action. If the
 .B retrans
-option is not specified, the NFS client tries each request
-three times.
+option is not specified, the NFS client tries each UDP request
+three times and each TCP request twice.
 .IP
 The NFS client generates a "server not responding" message
 after
@@ -391,6 +391,16 @@ is 2 minutes, and the default value for background mounts is 10000 minutes
 If a value of zero is specified, the
 .BR mount (8)
 command exits immediately after the first failure.
+.IP
+Note that this only affects how many retries are made and doesn't
+affect the delay caused by each retry.  For UDP each retry takes the
+time determined by the
+.BR timeo
+and
+.BR retrans
+options, which by default will be about 7 seconds.  For TCP the
+default is 3 minutes, but system TCP connection timeouts will
+sometimes limit the timeout of each retransmission to around 2 minutes.
 .TP 1.5i
 .BI sec= flavors
 A colon-separated list of one or more security flavors to use for accessing


