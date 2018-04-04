Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:51330 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752246AbeDDWH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:07:26 -0400
Subject: [PATCH 06/12] fscache: Detect multiple relinquishment of a cookie
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:07:24 +0100
Message-ID: <152287964415.14760.2996398134900556495.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Report if an fscache cookie is relinquished multiple times by the netfs.

Signed-off-by: David <dhowells@redhat.com>
---

 fs/fscache/cookie.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index d705125665f0..98d22f495cd8 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -602,7 +602,8 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
 	       atomic_read(&cookie->n_active), retire);
 
 	/* No further netfs-accessing operations on this cookie permitted */
-	set_bit(FSCACHE_COOKIE_RELINQUISHED, &cookie->flags);
+	if (test_and_set_bit(FSCACHE_COOKIE_RELINQUISHED, &cookie->flags))
+		BUG();
 
 	__fscache_disable_cookie(cookie, retire);
 

