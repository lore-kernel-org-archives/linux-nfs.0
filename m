From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] fix comment parsing
Date: Thu, 22 Jun 2006 19:51:56 -0400
Message-ID: <20060622235156.GA8263@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, kwc@citi.umich.edu
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtYxy-00047q-CX
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 16:52:06 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FtYxy-0002gA-CZ
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 16:52:06 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Recently exportfs started ignoring my /etc/exports file.

It looks like the culprit is 89572e8416..., after which xgettok returns 0
whenever it encounters '#' as the first character of a token.  Callers seem to
treat that as meaning end of file.

I think the "break" here was intended to be a "continue"; with that change,
xgettok will continue reading and return the next token instead.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 support/nfs/xio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/nfs/xio.c b/support/nfs/xio.c
index 1ce5157..9bc57ef 100644
--- a/support/nfs/xio.c
+++ b/support/nfs/xio.c
@@ -98,7 +98,7 @@ xgettok(XFILE *xfp, char sepa, char *tok
 		if (!quoted && i == 0 && c == '#') {
 			c = xskipcomment(xfp);
 			xfp->x_line++;
-			break;
+			continue;
 		}
 		if (c == '"') {
 			quoted = !quoted;
-- 
1.4.0.g5fdc


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
