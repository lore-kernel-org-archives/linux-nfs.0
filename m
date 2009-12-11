From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] libexport.a: fix a long-standing typo in name_cmp()
Date: Fri, 11 Dec 2009 16:27:31 -0500
Message-ID: <20091211212608.29241.27167.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:20529 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933120AbZLKV1r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Dec 2009 16:27:47 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not sure what "(!*a || !a == ',')" means... but just a few lines later is
"(!*a || *a == ',')".  I think "a is '\0' or ','" is what was intended.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Neil --

Looks like a typo.  Comments?

 support/export/client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index b08dda2..cb6e659 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -266,7 +266,7 @@ name_cmp(char *a, char *b)
 	/* compare strings a and b, but only upto ',' in a */
 	while (*a && *b && *a != ',' && *a == *b)
 		a++, b++;
-	if (!*b && (!*a || !a == ',') )
+	if (!*b && (!*a || *a == ','))
 		return 0;
 	if (!*b) return 1;
 	if (!*a || *a == ',') return -1;

