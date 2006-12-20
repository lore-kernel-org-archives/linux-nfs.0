From: Ian Kent <raven@themaw.net>
Subject: Re: [RFC:PATCH] nfs-utils - showmount RPC timeout
	handling	-	second attempt
Date: Wed, 20 Dec 2006 13:01:59 +0900
Message-ID: <1166587319.4364.8.camel@raven.themaw.net>
References: <1166499757.3482.40.camel@raven.themaw.net>
	<17799.25999.584498.734073@cse.unsw.edu.au>
	<1166526978.4400.8.camel@raven.themaw.net>
	<1166587161.4364.5.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwseQ-0005Ga-P1
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 20:01:54 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GwseS-0001mE-2L
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 20:01:56 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <1166587161.4364.5.camel@raven.themaw.net>
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

On Wed, 2006-12-20 at 12:59 +0900, Ian Kent wrote:
> On Tue, 2006-12-19 at 20:16 +0900, Ian Kent wrote:
> > 
> > I've made the changes suggested.
> > 
> > Removing the NULL PROC calls had no adverse affect on timing that I
> > could tell. My thoughts on that must have been due to some confusion in
> > the past. That's good.
> > 
> > I still like the bind so I've left in in but ultimately it's up to you
> > to decide whether to include it.
> > 
> > Anything else, anything I missed?
> 
> Something I got wrong.
> 
> A bit more testing shows that the write file descriptor is actually
> needed.
> 
> I found that without it select will timeout even when the connection
> should succeed, not sure why. Anyone?
> 
> Ian

Oops, I think that last one might have wrap.
Try this one.

---
--- nfs-utils-1.0.9/utils/showmount/showmount.c.reduce-timeout-2	2006-12-20 12:40:04.000000000 +0900
+++ nfs-utils-1.0.9/utils/showmount/showmount.c	2006-12-20 12:41:09.000000000 +0900
@@ -89,7 +89,7 @@
 {
 	int flags, ret;
 	socklen_t len;
-	fd_set rset;
+	fd_set rset, wset;
 
 	flags = fcntl(fd, F_GETFL, 0);
 	if (flags < 0)
@@ -117,8 +117,9 @@
 	/* now wait */
 	FD_ZERO(&rset);
 	FD_SET(fd, &rset);
+	wset = rset;
 
-	ret = select(fd + 1, &rset, NULL, NULL, tout);
+	ret = select(fd + 1, &rset, &wset, NULL, tout);
 	if (ret <= 0) {
 		if (ret == 0)
 			ret = -ETIMEDOUT;



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
