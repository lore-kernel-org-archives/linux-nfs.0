From: Neil Brown <neilb@suse.de>
Subject: Re: Possible bugs in nfs-utils
Date: Fri, 23 Jun 2006 17:12:16 +1000
Message-ID: <17563.37968.169337.128997@cse.unsw.edu.au>
References: <20060619203025.GA7102@us.ibm.com>
	<17563.28793.736537.826927@cse.unsw.edu.au>
	<1151044398.20487.592.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Michael Halcrow <mhalcrow@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ftfq8-0005X3-B0
	for nfs@lists.sourceforge.net; Fri, 23 Jun 2006 00:12:28 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ftfq5-000849-Ok
	for nfs@lists.sourceforge.net; Fri, 23 Jun 2006 00:12:28 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Friday June 23
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


Thanks for the review!!

I've created this addendum patch.

NeilBrown

>From 0523fd513c6baa8dbf45d1a7afea2044262aeb3d Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Fri, 23 Jun 2006 17:10:56 +1000
Subject: [PATCH] Further coverity related cleanups.

Greg Banks suggested some variations, particularly improved
use of xmalloc/xstrdup functions.  Thanks.
---
 support/misc/mountpoint.c |    5 ++---
 utils/idmapd/idmapd.c     |    7 +++++--
 utils/statd/notlist.c     |   12 +++---------
 3 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/support/misc/mountpoint.c b/support/misc/mountpoint.c
index 2cf1324..750b6e8 100644
--- a/support/misc/mountpoint.c
+++ b/support/misc/mountpoint.c
@@ -22,9 +22,8 @@ is_mountpoint(char *path)
 	struct stat stb, pstb;
 	int rv;
 
-	dotdot = malloc(strlen(path)+4);
-	if (!dotdot)
-		return 0;
+	dotdot = xmalloc(strlen(path)+4);
+
 	strcat(strcpy(dotdot, path), "/..");
 	if (lstat(path, &stb) != 0 ||
 	    lstat(dotdot, &pstb) != 0)
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 1231db4..5fc7811 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -1003,12 +1003,15 @@ mydaemon(int nochdir, int noclose)
 
 	if (noclose == 0) {
 		tempfd = open("/dev/null", O_RDWR);
+		if (tempfd < 0)
+			tempfd = open("/", O_RDONLY);
 		if (tempfd >= 0) {
 			dup2(tempfd, 0);
 			dup2(tempfd, 1);
 			dup2(tempfd, 2);
-		}
-		closeall(3);
+			closeall(3);
+		} else
+			closeall(0);
 	}
 
 	return;
diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
index 98aa6e2..b74d9df 100644
--- a/utils/statd/notlist.c
+++ b/utils/statd/notlist.c
@@ -54,19 +54,13 @@ nlist_new(char *my_name, char *mon_name,
 {
 	notify_list	*new;
 
-	if (!(new = (notify_list *) xmalloc(sizeof(notify_list))))
-		return NULL;
+	new = (notify_list *) xmalloc(sizeof(notify_list));
 	memset(new, 0, sizeof(*new));
 
 	NL_TIMES(new) = MAX_TRIES;
 	NL_STATE(new) = state;
-	if (!(NL_MY_NAME(new) = xstrdup(my_name))
-	    || !(NL_MON_NAME(new) = xstrdup(mon_name))) {
-		if (NL_MY_NAME(new))
-			free(NL_MY_NAME(new));
-		free(new);
-		return NULL;
-	}
+	NL_MY_NAME(new) = xstrdup(my_name);
+	NL_MON_NAME(new) = xstrdup(mon_name);
 
 	return new;
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
