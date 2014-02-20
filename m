Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42757 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbaBTGjC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:39:02 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:36:48 +1100
Subject: [PATCH 3/4] nfsd: set nlm grace time to make NFSv4 grace time
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220063648.6548.44668.stgit@notabene.brown>
In-Reply-To: <20140220063616.6548.42556.stgit@notabene.brown>
References: <20140220063616.6548.42556.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These two values are conceptually very similar, so it probably makes
sense to set them to the same value at the same time.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/nfsd/nfsd.man |    3 ++-
 utils/nfsd/nfssvc.c |    8 ++++++++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 58b53cbff009..c6d3ffbd3675 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -89,7 +89,8 @@ clients need to confirm their state with the server. Valid range is
 from 10 to 3600 seconds.
 .TP
 .B \-G " or " \-\-grace-time seconds
-Set the grace-time used for NFSv4.  New file open requests will not be
+Set the grace-time used for NFSv4 and NLM (for NFSv2 and NFSv3).
+New file open requests (NFSv4) and new file locks (NLM) will not be
 allowed until after this time has passed to allow clients to recover state.
 .TP
 .I nproc
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 337ab169c194..5e14cce58053 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -317,6 +317,14 @@ nfssvc_set_time(const char *type, const int seconds)
 			xlog(L_ERROR, "Unable to set nfsv4%stime: %m", type);
 		close(fd);
 	}
+	if (strcmp(type, "grace") == 0) {
+		/* set same value for lockd */
+		fd = open("/proc/sys/fs/nfs/nlm_grace_period", O_WRONLY);
+		if (fd >= 0) {
+			write(fd, nbuf, strlen(nbuf));
+			close(fd);
+		}
+	}
 }
 
 void


