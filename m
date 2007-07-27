From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] knfsd: eliminate unnecessary -ENOENT returns on
	export downcalls
Date: Fri, 27 Jul 2007 17:18:00 -0400
Message-ID: <36177.0493597307$1185571104@news.gmane.org>
References: <11855710801310-git-send-email-> <1185571080322-git-send-email->
	<11855710802313-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEXCD-0006BT-Lg
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:18:06 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEXCF-0004j5-2A
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:18:05 -0700
In-Reply-To: <11855710802313-git-send-email->
Message-Id: <b4559368b4cfd7e85751e7ada974d73e5f529a4f.1185570967.git.bfields@citi.umich.edu>
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

A succesful downcall with a negative result (which indicates that the
given filesystem is not exported to the given user) should not return an
error.

Currently mountd is depending on stdio to write these downcalls.  With
some versions of libc this appears to cause subsequent writes to attempt
to write all accumulated data (for which writes previously failed) along
with any new data.  This can prevent the kernel from seeing responses to
later downcalls.  Symptoms will be that nfsd fails to respond to certain
requests.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/export.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 2d295dd..cba899a 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -564,9 +564,10 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 
 	/* flags */
 	err = get_int(&mesg, &an_int);
-	if (err == -ENOENT)
+	if (err == -ENOENT) {
+		err = 0;
 		set_bit(CACHE_NEGATIVE, &exp.h.flags);
-	else {
+	} else {
 		if (err || an_int < 0) goto out;	
 		exp.ex_flags= an_int;
 	
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
