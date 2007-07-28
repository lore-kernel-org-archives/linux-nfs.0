From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/23] umount.nfs: make del_mtab() a static function
Date: Sat, 28 Jul 2007 17:49:54 -0400
Message-ID: <20070728214954.21871.77136.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAf-0007Ri-Pb
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:57 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAj-0003AQ-Hx
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:50:01 -0700
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

Clean-up: del_mtab() isn't used outside of nfsumount.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 2d68e7e..db22c11 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -53,7 +53,7 @@ int force;
 int lazy;
 int remount;
 
-int del_mtab(const char *spec, const char *node)
+static int del_mtab(const char *spec, const char *node)
 {
 	int umnt_err, res;
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
