From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] fix comment parsing
Date: Fri, 23 Jun 2006 14:08:39 +1000
Message-ID: <17563.26951.908793.369125@cse.unsw.edu.au>
References: <20060622235156.GA8263@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, kwc@citi.umich.edu
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ftcya-0007ng-7P
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 21:09:00 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FtcyY-00035t-LS
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 21:09:00 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Thursday June 22
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

On Thursday June 22, bfields@fieldses.org wrote:
> Recently exportfs started ignoring my /etc/exports file.
> 
> It looks like the culprit is 89572e8416..., after which xgettok returns 0
> whenever it encounters '#' as the first character of a token.  Callers seem to
> treat that as meaning end of file.
> 
> I think the "break" here was intended to be a "continue"; with that change,
> xgettok will continue reading and return the next token instead.

Thanks - blush....

However I don't think that patch is quite right.
It will make a comment through to the EOL parse as nothing at all,
not even an EOL, so

/foo bar() #comment
/baz *()

will parse like

/for bar() /baz *()

which isn't what we want.

On reflect, I got it completely wrong.  Having reviewed how parsing
really works, I think this is the right patch.

Thanks,
NeilBrown

>From ff42180930a444cea7f19e55e2cd2bfe6d3f108b Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Fri, 23 Jun 2006 14:06:00 +1000
Subject: [PATCH] Fix comment parsing (again)

Bruce Fields noticed that I broke comment parsing...

as xskip() is always called before xgettok(), that is the
best place to put xskipcomment and still maintain proper
semantics of xskip and xgettok.
---
 support/nfs/xio.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/support/nfs/xio.c b/support/nfs/xio.c
index 1ce5157..221cce6 100644
--- a/support/nfs/xio.c
+++ b/support/nfs/xio.c
@@ -95,11 +95,6 @@ xgettok(XFILE *xfp, char sepa, char *tok
 
 	while (i < len && (c = xgetc(xfp)) != EOF &&
 	       (quoted || (c != sepa && !isspace(c)))) {
-		if (!quoted && i == 0 && c == '#') {
-			c = xskipcomment(xfp);
-			xfp->x_line++;
-			break;
-		}
 		if (c == '"') {
 			quoted = !quoted;
 			continue;
@@ -164,7 +159,12 @@ xskip(XFILE *xfp, char *str)
 {
 	int	c;
 
-	while ((c = xgetc(xfp)) != EOF && strchr(str, c));
+	while ((c = xgetc(xfp)) != EOF) {
+		if (c == '#')
+			c = xskipcomment(xfp);
+		if (strchr(str, c) == NULL)
+			break;
+	}
 	xungetc(c, xfp);
 }
 
-- 
1.4.0


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
