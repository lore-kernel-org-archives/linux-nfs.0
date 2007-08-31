From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: [PATCH] mount.nfs4: don't try to detect a clientaddr if
	clientaddr= option is provided
Date: Fri, 31 Aug 2007 16:01:20 +0200
Message-ID: <11885688803306-git-send-email-gabriel@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR73b-0005py-1Q
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 07:01:07 -0700
Received: from tok69-4-82-236-110-238.fbx.proxad.net ([82.236.110.238]
	helo=masternode.reagi.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR73e-0000w9-Uk
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 07:01:11 -0700
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

If get_my_ipv4addr() fails (dns error, wrong hostname, etc.), nfs4mount would
fail even if the clientaddr= is provided (and with clientaddr=, get_my_ipv4addr
detection is then useless).

Signed-off-by: Gabriel Barazer <gabriel@oxeva.fr>
---
 utils/mount/nfs4mount.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index c4e8bfb..391665b 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -199,8 +199,6 @@ int nfs4mount(const char *spec, const char *node, int flags,
 
 	if (fill_ipv4_sockaddr(hostname, &server_addr))
 		goto fail;
-	if (get_my_ipv4addr(ip_addr, sizeof(ip_addr)))
-		goto fail;
 
 	/* add IP address to mtab options for use when unmounting */
 	s = inet_ntoa(server_addr.sin_addr);
@@ -328,6 +326,14 @@ int nfs4mount(const char *spec, const char *node, int flags,
 		}
 	}
 
+	/* Try to get and resolve the local address only if
+	 * it is not provided by the clientaddr= option.
+	 * Else, nfs4mount could fail if the local hostname is not resolvable
+	 * (poor DNS config or early mount), even if clientaddr= is provided.
+	 */
+	if (!ip_addr_in_opts && get_my_ipv4addr(ip_addr, sizeof(ip_addr)))
+		goto fail;
+
 	data.flags = (soft ? NFS4_MOUNT_SOFT : 0)
 		| (intr ? NFS4_MOUNT_INTR : 0)
 		| (nocto ? NFS4_MOUNT_NOCTO : 0)
-- 
1.5.2.5


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
