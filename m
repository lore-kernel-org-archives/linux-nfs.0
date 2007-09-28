From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] text-based mount.nfs: prepare for more complex
	error exit	handling
Date: Fri, 28 Sep 2007 16:36:45 -0400
Message-ID: <20070928203645.12851.65779.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbMaH-0006b3-Kd
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:37:14 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbMaM-0004T3-4a
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:37:18 -0700
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

I'm about to add an object or two that needs to be freed before the main
functions exit.  Prepare the logic by adding an 'out' label and some
goto's.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   36 +++++++++++++++++++++---------------
 1 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index b2e8d2f..4dbd19e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -307,24 +307,24 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 {
 	struct sockaddr_in saddr;
 	char *hostname;
-	int err;
+	int err, retval = EX_FAIL;
 
 	if (!parse_devname(spec, &hostname))
-		return EX_FAIL;
+		goto out;
 	err = fill_ipv4_sockaddr(hostname, &saddr);
 	free(hostname);
 	if (!err)
-		return EX_FAIL;
+		goto out;
 
 	extract_interesting_options(*extra_opts);
 
 	if (!child && addr_opt) {
 		nfs_error(_("%s: Illegal option: 'addr='"), progname);
-		return EX_FAIL;
+		goto out;
 	}
 
 	if (!append_addr_opt(&saddr, extra_opts))
-		return EX_FAIL;
+		goto out;
 
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
@@ -334,11 +334,14 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 		if (mount(spec, node, "nfs",
 				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
 			mount_error(spec, node, errno);
-			return EX_FAIL;
+			goto out;
 		}
 	}
 
-	return EX_SUCCESS;
+	retval = EX_SUCCESS;
+
+out:
+	return retval;
 }
 
 /*
@@ -360,27 +363,27 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 {
 	struct sockaddr_in saddr;
 	char *hostname;
-	int err;
+	int err, retval = EX_FAIL;
 
 	if (!parse_devname(spec, &hostname))
-		return EX_FAIL;
+		goto out;
 	err = fill_ipv4_sockaddr(hostname, &saddr);
 	free(hostname);
 	if (!err)
-		return EX_FAIL;
+		goto out;
 
 	extract_interesting_options(*extra_opts);
 
 	if (addr_opt) {
 		nfs_error(_("%s: Illegal option: 'addr='"), progname);
-		return EX_FAIL;
+		goto out;
 	}
 
 	if (!append_addr_opt(&saddr, extra_opts))
-		return EX_FAIL;
+		goto out;
 
 	if (!ca_opt && !append_clientaddr_opt(&saddr, extra_opts))
-		return EX_FAIL;
+		goto out;
 
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
@@ -390,9 +393,12 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 		if (mount(spec, node, "nfs4",
 				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
 			mount_error(spec, node, errno);
-			return EX_FAIL;
+			goto out;
 		}
 	}
 
-	return EX_SUCCESS;
+	retval = EX_SUCCESS;
+
+out:
+	return retval;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
