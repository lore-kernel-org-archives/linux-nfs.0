Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45757 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbbHXUol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2015 16:44:41 -0400
Date: Mon, 24 Aug 2015 16:44:40 -0400
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Jeff Layton <jlayton@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH] nfsd: Add Jeff Layton as co-maintainer
Message-ID: <20150824204440.GA835@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Jeff has been doing a lot of development (including much of the
state-locking rewrite just as one example) plus lots of review and other
miscellaneous nfsd work, so let's acknowledge the status quo.

I'll continue to be the one to send regular pull requests but Jeff will
should be available to cover there occasionally too.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

I intend to apply this for 4.3.

diff --git a/MAINTAINERS b/MAINTAINERS
index a2264167791a..77628d12d3ce 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5836,6 +5836,7 @@ S:	Odd Fixes
 
 KERNEL NFSD, SUNRPC, AND LOCKD SERVERS
 M:	"J. Bruce Fields" <bfields@fieldses.org>
+M:	Jeff Layton <jlayton@poochiereds.net>
 L:	linux-nfs@vger.kernel.org
 W:	http://nfs.sourceforge.net/
 S:	Supported
-- 
2.4.3

