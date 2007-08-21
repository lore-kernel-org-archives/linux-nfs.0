From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] mount.nfs: mount's background daemon should
	free	"mount_point" properly
Date: Tue, 21 Aug 2007 12:19:02 -0400
Message-ID: <20070821161902.4373.67197.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INWRk-0003SW-L3
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 09:19:12 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INWRm-0000YY-W9
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 09:19:15 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index d299358..40e7958 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -557,7 +557,7 @@ int main(int argc, char *argv[])
 
 		/*
 		 * Parent exits immediately with success.  Make
-		 * sure not to free "mount_point"
+		 * sure parent doesn't free "mount_point".
 		 */
 		if (fork() > 0)
 			exit(0);
@@ -568,6 +568,7 @@ int main(int argc, char *argv[])
 		if (verbose && mnt_err)
 			printf(_("%s: giving up \"%s\"\n"),
 				progname, spec);
+		free(mount_point);
 		exit(0);
 	}
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
