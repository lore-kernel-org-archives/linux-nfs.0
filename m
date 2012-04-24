Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57422 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab2DXFs0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 01:48:26 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Tue, 24 Apr 2012 15:46:38 +1000
Subject: [PATCH 6/6] v4_root_add_parents: remove a possible buffer overflow.
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20120424054638.20130.42383.stgit@notabene.brown>
In-Reply-To: <20120424054003.20130.16209.stgit@notabene.brown>
References: <20120424054003.20130.16209.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The loop in v4root_add_parents() is a little odd.
The first time through, 'ptr' points immediately "beyond"
a '/' character (the first).  For every other iterration it points
directly "at" a '/' character.
Such inconsistency is error prone and infact there is an error.
If "path" is precisely "/", then the first call to
   ptr = strchr(ptr, '/')

will be given a 'ptr' which is beyond the '\0' at the end of
"path".  This could potentially contain anything and the strchr()
could search well beyond a buffer (though this depends on exactly how
the string is set up which depends on separate code).

So change the loop to have 'ptr' always point at a '/', and
handle the special case of "/" explicitly.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 utils/mountd/v4root.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 57ee0b2..708eb61 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -150,13 +150,13 @@ static int v4root_add_parents(nfs_export *exp)
 				"pseudo export for '%s'", exp->m_export.e_path);
 		return -ENOMEM;
 	}
-	for (ptr = path + 1; ptr; ptr = strchr(ptr, '/')) {
+	for (ptr = path; ptr; ptr = strchr(ptr, '/')) {
 		int ret;
 		char saved;
 
 		saved = *ptr;
 		*ptr = '\0';
-		ret = pseudofs_update(hostname, path, exp);
+		ret = pseudofs_update(hostname, *path ? path : "/", exp);
 		if (ret)
 			return ret;
 		*ptr = saved;


