From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/23] umount.nfs: make umount.nfs use UDP by default
Date: Sat, 28 Jul 2007 17:49:33 -0400
Message-ID: <20070728214933.21871.51118.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAM-0007Pv-Gr
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:38 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAO-000344-7b
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:42 -0700
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

mount.nfs currently uses UDP by default when calling a MNT server.  Make
umount.nfs do the same.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 55e1c28..19e9be3 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -200,7 +200,6 @@ int _nfsumount(const char *spec, char *opts)
 
 	pmap->pm_prog = MOUNTPROG;
 	pmap->pm_vers = MOUNTVERS_NFSV3;
-	pmap->pm_prot = IPPROTO_TCP;
 	if (opts && (p = strstr(opts, "mountprog=")) && isdigit(*(p+10)))
 		pmap->pm_prog = atoi(p+10);
 	if (opts && (p = strstr(opts, "mountport=")) && isdigit(*(p+10)))


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
