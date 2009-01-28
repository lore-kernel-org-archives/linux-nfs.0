From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] umount command: remove do_nfs_umount23 function
Date: Wed, 28 Jan 2009 18:07:54 -0500
Message-ID: <20090128230754.21484.42620.stgit@ingres.1015granger.net>
References: <20090128225938.21484.82096.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:23754 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754780AbZA1XJJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 18:09:09 -0500
In-Reply-To: <20090128225938.21484.82096.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove do_nfs_umount23() now that it is unused.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |   93 -----------------------------------------------
 1 files changed, 0 insertions(+), 93 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 04990f0..78ebd4a 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -228,99 +228,6 @@ static int nfs_umount23(const char *devname, char *string)
 	return result;
 }
 
-/*
- * Pick up certain mount options used during the original mount
- * from /etc/mtab.  The basics include the server's IP address and
- * the server pathname of the share to unregister.
- *
- * These options might also describe the mount port, mount protocol
- * version, and transport protocol used to punch through a firewall.
- * We will need this information to get through the firewall again
- * to do the umount.
- */
-static int do_nfs_umount23(const char *spec, char *opts)
-{
-	char *hostname;
-	char *dirname;
-	clnt_addr_t mnt_server = { &hostname, };
-	struct mntent mnt = { .mnt_opts = opts };
-	struct pmap *pmap = &mnt_server.pmap;
-	char *p;
-	int result = EX_USAGE;
-
-	if (!nfs_parse_devname(spec, &hostname, &dirname))
-		return result;
-
-#ifdef NFS_MOUNT_DEBUG
-	printf(_("host: %s, directory: %s\n"), hostname, dirname);
-#endif
-
-	if (opts && (p = strstr(opts, "addr="))) {
-		char *q;
-
-		free(hostname);
-		p += 5;
-		q = p;
-		while (*q && *q != ',') q++;
-		hostname = xstrndup(p,q-p);
-	}
-
-	if (opts && (p = strstr(opts, "mounthost="))) {
-		char *q;
-
-		free(hostname);
-		p += 10;
-		q = p;
-		while (*q && *q != ',') q++;
-		hostname = xstrndup(p,q-p);
-	}
-
-	pmap->pm_prog = MOUNTPROG;
-	pmap->pm_vers = 0; /* unknown */
-	if (opts && (p = strstr(opts, "mountprog=")) && isdigit(*(p+10)))
-		pmap->pm_prog = atoi(p+10);
-	if (opts && (p = strstr(opts, "mountport=")) && isdigit(*(p+10)))
-		pmap->pm_port = atoi(p+10);
-	if (opts && hasmntopt(&mnt, "v2"))
-		pmap->pm_vers = nfsvers_to_mnt(2);
-	if (opts && hasmntopt(&mnt, "v3"))
-		pmap->pm_vers = nfsvers_to_mnt(3);
-	if (opts && (p = strstr(opts, "vers=")) && isdigit(*(p+5)))
-		pmap->pm_vers = nfsvers_to_mnt(atoi(p+5));
-	if (opts && (p = strstr(opts, "mountvers=")) && isdigit(*(p+10)))
-		pmap->pm_vers = atoi(p+10);
-	if (opts && (hasmntopt(&mnt, "udp")
-		     || hasmntopt(&mnt, "proto=udp")
-		     || hasmntopt(&mnt, "mountproto=udp")
-		    ))
-		pmap->pm_prot = IPPROTO_UDP;
-	if (opts && (hasmntopt(&mnt, "tcp")
-		     || hasmntopt(&mnt, "proto=tcp")
-		     || hasmntopt(&mnt, "mountproto=tcp")
-		    ))
-		pmap->pm_prot = IPPROTO_TCP;
-
-	if (!nfs_gethostbyname(hostname, &mnt_server.saddr)) {
-		nfs_error(_("%s: DNS resolution of '%s' failed"),
-				progname, hostname);
-		goto out;
-	}
-
-	if (!nfs_call_umount(&mnt_server, &dirname)) {
-		nfs_error(_("%s: Server failed to unmount '%s'"),
-				progname, spec);
-		result = EX_FAIL;
-		goto out;
-	}
-
-	result = EX_SUCCESS;
-
-out:
-	free(hostname);
-	free(dirname);
-	return result;
-}
-
 static struct option umount_longopts[] =
 {
   { "force", 0, 0, 'f' },

