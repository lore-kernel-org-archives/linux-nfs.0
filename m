From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH] Fix a couple of problems that crept into mount
Date: Tue, 20 Mar 2007 18:52:17 -0400
Message-ID: <20070320225217.24284.19896.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTnBi-0005hb-Dj
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 15:52:18 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HTnBj-0004Ot-I8
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 15:52:20 -0700
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

From: Kevin Coffman <kwc@citi.umich.edu>

Commit 6facb22402a0bd8cd49be2ed1a0856b24fef42f4 changed the allocation
of len to no longer get 20 extra bytes.  It needs to get at least one
extra byte for a null character, otherwise a single extra option such
as "sec=krb5" is never copied in parse_opt() and is dropped.

Commit 44a3727a3243e674a1f1fdad5cbbc639aa25d01c added a typo when
checking the program name.
---

 utils/mount/mount.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 487c0a6..b367b64 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -262,7 +262,7 @@ static void parse_opts (const char *opti
 	if (options != NULL) {
 		char *opts = xstrdup(options);
 		char *opt, *p;
-		int len = strlen(opts);
+		int len = strlen(opts) + 1;		/* include room for a null */
 		int open_quote = 0;
 
 		*extra_opts = xmalloc(len);
@@ -437,7 +437,7 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
-	if (strcmp(progname, "mount.nfsv4") == 0)
+	if (strcmp(progname, "mount.nfs4") == 0)
 		nfs_mount_vers = 4;
 
 	if (uid != 0) {

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
