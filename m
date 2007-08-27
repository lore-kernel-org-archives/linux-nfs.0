From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 07/15] knfsd: nfs4 name->id mapping not correctly
	parsing negative downcall
Date: Mon, 27 Aug 2007 16:22:48 -0400
Message-ID: <11882461773396-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
	<11882461771774-git-send-email-bfields@fieldses.org>
	<1188246177195-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl6v-0004gl-7j
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:22:57 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl6y-0000TS-4K
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:01 -0700
In-Reply-To: <1188246177195-git-send-email-bfields@fieldses.org>
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

Note that qword_get() returns length or -1, not an -ERROR.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4idmap.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 2ccffde..4c0c683 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -207,6 +207,7 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
 {
 	struct ent ent, *res;
 	char *buf1, *bp;
+	int len;
 	int error = -EINVAL;
 
 	if (buf[buflen - 1] != '\n')
@@ -248,10 +249,11 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
 		goto out;
 
 	/* Name */
-	error = qword_get(&buf, buf1, PAGE_SIZE);
-	if (error == -EINVAL)
+	error = -EINVAL;
+	len = qword_get(&buf, buf1, PAGE_SIZE);
+	if (len < 0)
 		goto out;
-	if (error == -ENOENT)
+	if (len == 0)
 		set_bit(CACHE_NEGATIVE, &ent.h.flags);
 	else {
 		if (error >= IDMAP_NAMESZ) {
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
