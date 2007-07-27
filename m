From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd4: idmap upcalls should use unsigned uid and gid
Date: Fri, 27 Jul 2007 17:17:59 -0400
Message-ID: <10743.150735698$1185571101@news.gmane.org>
References: <11855710801310-git-send-email->
 <1185571080322-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEXCD-0006BV-NT
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:18:06 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEXCF-0004j9-26
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:18:05 -0700
In-Reply-To: <1185571080322-git-send-email->
Message-Id: <8986f34ba2666fa587255d2fe3778d38b5f7dfe3.1185570967.git.bfields@citi.umich.edu>
In-Reply-To: <3870106f1229e5c62ef479ec85cc9ca21b81d090.1185570967.git.bfields@citi.umich.edu>
References: <3870106f1229e5c62ef479ec85cc9ca21b81d090.1185570967.git.bfields@citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>

We shouldn't be using negative uid's and gid's in the idmap upcalls.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4idmap.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 2cf9a9a..2ccffde 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -138,7 +138,7 @@ idtoname_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
 	char idstr[11];
 
 	qword_add(bpp, blen, ent->authname);
-	snprintf(idstr, sizeof(idstr), "%d", ent->id);
+	snprintf(idstr, sizeof(idstr), "%u", ent->id);
 	qword_add(bpp, blen, ent->type == IDMAP_TYPE_GROUP ? "group" : "user");
 	qword_add(bpp, blen, idstr);
 
@@ -165,7 +165,7 @@ idtoname_show(struct seq_file *m, struct cache_detail *cd, struct cache_head *h)
 		return 0;
 	}
 	ent = container_of(h, struct ent, h);
-	seq_printf(m, "%s %s %d", ent->authname,
+	seq_printf(m, "%s %s %u", ent->authname,
 			ent->type == IDMAP_TYPE_GROUP ? "group" : "user",
 			ent->id);
 	if (test_bit(CACHE_VALID, &h->flags))
@@ -349,7 +349,7 @@ nametoid_show(struct seq_file *m, struct cache_detail *cd, struct cache_head *h)
 			ent->type == IDMAP_TYPE_GROUP ? "group" : "user",
 			ent->name);
 	if (test_bit(CACHE_VALID, &h->flags))
-		seq_printf(m, " %d", ent->id);
+		seq_printf(m, " %u", ent->id);
 	seq_printf(m, "\n");
 	return 0;
 }
-- 
1.5.3.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
