From: Josh Triplett <josht@us.ibm.com>
Subject: [PATCH] [nfsd] Add lock annotations to e_start and e_stop
Date: Tue, 25 Jul 2006 08:20:24 -0700
Message-ID: <1153840824.12517.9.camel@josh-work.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5Ohw-00067w-AQ
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 08:20:28 -0700
Received: from e36.co.us.ibm.com ([32.97.110.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5Ohw-0005cG-7h
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 08:20:28 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6PFKMJU004714
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Tue, 25 Jul 2006 11:20:22 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k6PFKMrH300928
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 25 Jul 2006 09:20:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k6PFKMEs025651
	for <nfs@lists.sourceforge.net>; Tue, 25 Jul 2006 09:20:22 -0600
To: linux-kernel@vger.kernel.org
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

e_start acquires svc_export_cache.hash_lock, and e_stop releases it.  Add lock
annotations to these two functions so that sparse can check callers for lock
pairing, and so that sparse will not complain about these functions since they
intentionally use locks in this manner.

Signed-off-by: Josh Triplett <josh@freedesktop.org>
---
 fs/nfsd/export.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 01bc68c..6fe54eb 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1078,6 +1078,7 @@ exp_pseudoroot(struct auth_domain *clp, 
 /* Iterator */
 
 static void *e_start(struct seq_file *m, loff_t *pos)
+	__acquires(svc_export_cache.hash_lock)
 {
 	loff_t n = *pos;
 	unsigned hash, export;
@@ -1131,6 +1132,7 @@ static void *e_next(struct seq_file *m, 
 }
 
 static void e_stop(struct seq_file *m, void *p)
+	__releases(svc_export_cache.hash_lock)
 {
 	read_unlock(&svc_export_cache.hash_lock);
 	exp_readunlock();



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
