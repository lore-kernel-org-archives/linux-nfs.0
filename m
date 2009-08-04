From: NeilBrown <neilb@suse.de>
Subject: [PATCH 10/12] sunrpc: fix memory leak in unix_gid cache.
Date: Tue, 04 Aug 2009 15:22:39 +1000
Message-ID: <20090804052239.15929.71459.stgit@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52237 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754383AbZHDFZT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 01:25:19 -0400
In-Reply-To: <20090804051145.15929.11356.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we look up an entry in the uid->gidlist cache, we take
a reference to the content but don't drop the reference to the
cache entry.  So it never gets freed.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/svcauth_unix.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index f2de152..0afeb30 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -660,6 +660,7 @@ static int unix_gid_find(uid_t uid, struct group_info **gip,
 	case 0:
 		*gip = ug->gi;
 		get_group_info(*gip);
+		cache_put(&ug->h, &unix_gid_cache);
 		return 0;
 	case -ETIMEDOUT:
 		prevug = ug;


