From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH 3/4] Use correct UMNT protocol to do umount
Date: Wed, 14 Mar 2007 15:56:58 +0800
Message-ID: <45F7AACA.8040009@nanjing-fnst.com>
References: <45F79A58.1080102@nanjing-fnst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HROQg-0000gK-GP
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 01:01:50 -0700
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HROQf-000504-0n
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 01:01:52 -0700
In-Reply-To: <45F79A58.1080102@nanjing-fnst.com>
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

I'm so sorry to say that last post is an old patch. 
This is the new patch.


> This patch do following things:
>
> 1. When unmounting, we should try /proc/mounts first. Only then in 
> /etc/mtab if it wasn't found.
> 2. Reject name passed to us which is not starts with a '/' or not 
> contains a ':'
> 3. Fix the method to get UMNT protocol
>   
Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- utils/mount/nfsumount.c.orig	2007-03-04 04:19:31.000000000 -0500
+++ utils/mount/nfsumount.c	2007-03-04 04:40:38.000000000 -0500
@@ -103,33 +103,28 @@
 	return 0;
 }
 
-u_int get_mntproto(const char *);
-u_int
-get_mntproto(const char *dirname)
+struct mntentchn *
+getmntentchn(const char *dir)
 {
-	FILE *mtab;
-	struct mntent mntbuf;
-	char tmpbuf[BUFSIZ];
-	u_int proto = IPPROTO_TCP; /* assume tcp */
-
-	 mtab = setmntent ("/proc/mounts", "r");
-	 if (mtab == NULL)
-	 	mtab = setmntent (_PATH_MOUNTED, "r");
-	if (mtab == NULL)
-		return proto;
+	mntFILE *mfp;
+	nfs_mntent_t *mnt;
+	struct mntentchn *mc = NULL;
+
+	mfp = nfs_setmntent ("/proc/mounts", "r");
+	if (mfp == NULL || mfp->mntent_fp == NULL)
+		return NULL;
 
-	while(getmntent_r(mtab, &mntbuf, tmpbuf, sizeof (tmpbuf))) {
-		if (strcmp(mntbuf.mnt_type, "nfs"))
+	while ((mnt = nfs_getmntent(mfp)) != NULL) {
+		if(strcmp(mnt->mnt_fsname, dir) && strcmp(mnt->mnt_dir, dir))
 			continue;
-		if (strcmp(dirname,  mntbuf.mnt_fsname))
-			continue;
-		if (hasmntopt(&mntbuf, "udp"))
-			proto = IPPROTO_UDP;
-		break;
+
+		if (!mc)
+			mc = (struct mntentchn *)xmalloc(sizeof(*mc));
+		mc->m = *mnt;
 	}
-	endmntent (mtab);
 
-	return proto;
+	nfs_endmntent(mfp);
+	return mc;
 }
 
 /* complain about a failed umount */
@@ -257,6 +252,7 @@
 	char *hostname;
 	char *dirname;
 	clnt_addr_t mnt_server = { &hostname, };
+	struct mntent mnt = { .mnt_opts = opts };
 	struct pmap *pmap = &mnt_server.pmap;
 	char *p;
 
@@ -291,7 +287,7 @@
 
 	pmap->pm_prog = MOUNTPROG;
 	pmap->pm_vers = MOUNTVERS;
-	pmap->pm_prot = get_mntproto(spec);
+	pmap->pm_prot = IPPROTO_TCP;
 	if (opts && (p = strstr(opts, "mountprog=")) && isdigit(*(p+10)))
 		pmap->pm_prog = atoi(p+10);
 	if (opts && (p = strstr(opts, "mountport=")) && isdigit(*(p+10)))
@@ -300,6 +296,8 @@
 		pmap->pm_vers = nfsvers_to_mnt(atoi(p+8));
 	if (opts && (p = strstr(opts, "mountvers=")) && isdigit(*(p+10)))
 		pmap->pm_vers = atoi(p+10);
+	if (opts && (hasmntopt(&mnt, "udp") || hasmntopt(&mnt, "proto=udp")))
+		pmap->pm_prot = IPPROTO_UDP;
 
 	if (!nfs_gethostbyname(hostname, &mnt_server.saddr))
 		goto out_bad;
@@ -368,8 +366,15 @@
 			return 0;
 		}
 	}
+	
+	if (spec == NULL || (*spec != '/' && strchr(spec,':') == NULL)) {
+		printf(_("umount: %s: not found\n"), spec);
+		return 0;
+	}
 
-	mc = getmntdirbackward(spec, NULL);
+	mc = getmntentchn(spec);
+	if (!mc)
+		mc = getmntdirbackward(spec, NULL);
 	if (!mc)
 		mc = getmntdevbackward(spec, NULL);
 	if (!mc && verbose)



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
