From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] Use __fpurge to ensure single-line writes to cache
	files
Date: Thu, 26 Jul 2007 16:30:46 -0400
Message-ID: <20070726203046.GG8125@fieldses.org>
References: <20070725223723.GH7943@fieldses.org>
	<20070726000700.GK7943@fieldses.org>
	<18088.3581.647761.879253@notabene.brown>
	<20070726031755.GB19901@fieldses.org>
	<18088.7847.592861.408080@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE9yu-0001Rn-TG
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 13:30:48 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IE9yy-0004Rd-7c
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 13:30:48 -0700
In-Reply-To: <18088.7847.592861.408080@notabene.brown>
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

On a recent Debian/Sid machine, I saw libc retrying stdio writes that
returned write errors.  The result is that if an export downcall returns
an error (which it can in normal operation, since it currently
(incorrectly) returns -ENOENT on any negative downcall), then subsequent
downcalls will write multiple lines (including the original line that
received the error).

The result is that the server fails to respond to any rpc call that
refers to an unexported mount point (such as a readdir of a directory
containing such a mountpoint), so client commands hang.

I don't know whether this libc behavior is correct or expected, but it
seems safest to add the __fpurge() (suggested by Neil) to ensure data is
thrown away.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 support/nfs/cacheio.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

On Thu, Jul 26, 2007 at 02:10:15PM +1000, Neil Brown wrote:
> 	__fpurge(f)
> 
> seems to do the trick.

Yep, thanks!

> But we want to build a line up from multiple words, and so we need
> buffering for that.  If we toss stdio, we will need to allocate a
> buffer, keep track of the end point, and append to the buffer in
> various places.  It feels like reinventing the wheel.

Reinventing a rather simple part of the wheel, I'd say.  Oh well,
another day.

--b.


diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index a76915b..9d271cd 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -17,6 +17,7 @@
 
 #include <nfslib.h>
 #include <stdio.h>
+#include <stdio_ext.h>
 #include <ctype.h>
 #include <unistd.h>
 #include <sys/types.h>
@@ -111,7 +112,18 @@ void qword_printint(FILE *f, int num)
 
 int qword_eol(FILE *f)
 {
+	int err;
+
 	fprintf(f,"\n");
+	err = fflush(f);
+	/*
+	 * We must send one line (and one line only) in a single write
+	 * call.  In case of a write error, libc may accumulate the
+	 * unwritten data and try to write it again later, resulting in a
+	 * multi-line write.  So we must explicitly ask it to throw away
+	 * any such cached data:
+	 */
+	__fpurge(f);
 	return fflush(f);
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
