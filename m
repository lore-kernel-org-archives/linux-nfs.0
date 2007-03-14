From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH 1/4] Use correct UMNT version to do umount
Date: Wed, 14 Mar 2007 15:51:38 +0800
Message-ID: <45F7A98A.20503@nanjing-fnst.com>
References: <45F79A3E.6000504@nanjing-fnst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HROLT-0000CF-U6
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 00:56:28 -0700
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HROLV-0002MU-JV
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 00:56:30 -0700
In-Reply-To: <45F79A3E.6000504@nanjing-fnst.com>
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

Sorry to send old patch. This is the new patch.

> This patch let umount to use correct UMNT version to do umount.
> In latest kernel, the version format is "vers=3" etc., and in old kernel 
> the version format is "v3","v4" etc.
>   
Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- utils/mount/nfsumount.c.orig.rel	2007-03-04 04:46:22.000000000 -0500
+++ utils/mount/nfsumount.c	2007-03-04 04:47:20.000000000 -0500
@@ -257,6 +257,7 @@
 	char *hostname;
 	char *dirname;
 	clnt_addr_t mnt_server = { &hostname, };
+	struct mntent mnt = { .mnt_opts = opts };
 	struct pmap *pmap = &mnt_server.pmap;
 	char *p;
 
@@ -290,14 +291,20 @@
 	}
 
 	pmap->pm_prog = MOUNTPROG;
-	pmap->pm_vers = MOUNTVERS;
+	pmap->pm_vers = MOUNTVERS_NFSV3;
 	pmap->pm_prot = get_mntproto(spec);
 	if (opts && (p = strstr(opts, "mountprog=")) && isdigit(*(p+10)))
 		pmap->pm_prog = atoi(p+10);
 	if (opts && (p = strstr(opts, "mountport=")) && isdigit(*(p+10)))
 		pmap->pm_port = atoi(p+10);
-	if (opts && (p = strstr(opts, "nfsvers=")) && isdigit(*(p+8)))
-		pmap->pm_vers = nfsvers_to_mnt(atoi(p+8));
+	if (opts && hasmntopt(&mnt, "v2"))
+		pmap->pm_vers = nfsvers_to_mnt(2);
+	if (opts && hasmntopt(&mnt, "v3"))
+		pmap->pm_vers = nfsvers_to_mnt(3);
+	if (opts && hasmntopt(&mnt, "v4"))
+		pmap->pm_vers = nfsvers_to_mnt(4);
+	if (opts && (p = strstr(opts, "vers=")) && isdigit(*(p+5)))
+		pmap->pm_vers = nfsvers_to_mnt(atoi(p+5));
 	if (opts && (p = strstr(opts, "mountvers=")) && isdigit(*(p+10)))
 		pmap->pm_vers = atoi(p+10);
 



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
