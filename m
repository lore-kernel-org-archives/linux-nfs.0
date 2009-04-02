From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/2] cacheio: return any original error from qword_eol
Date: Wed, 01 Apr 2009 20:05:52 -0400
Message-ID: <20090402000551.3234.66699.stgit@rock.citi.umich.edu>
References: <20090402000430.3234.81110.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:41261 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233AbZDBAgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2009 20:36:00 -0400
In-Reply-To: <20090402000430.3234.81110.stgit-Cm81N35Y91hZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

If the initial fflush() fails in qword_eol, log the failure
and return the indication of the original failure, not the
successful cover-up.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 support/nfs/cacheio.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)


diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index f303734..6a6ed5a 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -154,15 +154,21 @@ int qword_eol(FILE *f)
 
 	fprintf(f,"\n");
 	err = fflush(f);
+	if (err) {
+		xlog_warn("qword_eol: fflush failed: errno %d (%s)",
+			    errno, strerror(errno));
+	}
 	/*
 	 * We must send one line (and one line only) in a single write
 	 * call.  In case of a write error, libc may accumulate the
 	 * unwritten data and try to write it again later, resulting in a
 	 * multi-line write.  So we must explicitly ask it to throw away
-	 * any such cached data:
+	 * any such cached data.  But we return any original error
+	 * indication to the caller.
 	 */
 	__fpurge(f);
-	return fflush(f);
+	fflush(f);
+	return err;
 }
 
 

