From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/4] Use correct UMNT version to do umount
Date: Fri, 16 Mar 2007 13:59:32 +1100
Message-ID: <17914.2068.446442.474747@notabene.brown>
References: <45F79A3E.6000504@nanjing-fnst.com>
	<45F7A98A.20503@nanjing-fnst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wei Yongjun <yjwei@nanjing-fnst.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HS2fU-0000Su-C0
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 19:59:48 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HS2fV-00075v-17
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 19:59:50 -0700
In-Reply-To: message from Wei Yongjun on Wednesday March 14
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


Thanks for these patches.  I have applied them.

I subsequently realised that reading from /proc/mounts first is not
such a good idea as some options such as mount_vers do not appear in
/proc/mounts, only in /etc/mtab.  So I removed that part of the patch.
I made some other changes as you can see at 

 http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=commitdiff;h=1e42be20a3283994d0ffd6c5f80c36fab5a887a8

or below.

Thanks,
NeilBrown


From: Neil Brown <neilb@suse.de>
Date: Fri, 16 Mar 2007 02:56:25 +0000 (+1100)
Subject: Further tidyup of nfs_umount.
X-Git-Url: http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=commitdiff;h=1e42be20a3283994d0ffd6c5f80c36fab5a887a8

Further tidyup of nfs_umount.

- remove non-used arguments from del_mtab.
- Don't try to pass a "host:/path" string to umount.
  It used to be possible to umount("/dev/whatever"). It has never
  been possible to umount("host:/path").
- Don't try to read /proc/mounts first.  Some mount options (mount_vers)
  are only stored in /etc/mtab, not in /proc/mounts.  So we have to
  prefer /etc/mtab as getmntXbackwards do.
- Only every call one of getmnt{dir,dev}backwards, depending on whether
  'spec' looks like a path name or a host:/path.
- Don't call _nfsumount unless we have a host:/path, or del_mtab unless we
  have a path name.
---

--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -91,30 +91,6 @@ int nfs_call_umount(clnt_addr_t *mnt_ser
 	return res;
 }
 
-struct mntentchn *
-getmntentchn(const char *dir)
-{
-	mntFILE *mfp;
-	nfs_mntent_t *mnt;
-	struct mntentchn *mc = NULL;
-
-	mfp = nfs_setmntent ("/proc/mounts", "r");
-	if (mfp == NULL || mfp->mntent_fp == NULL)
-		return NULL;
-
-	while ((mnt = nfs_getmntent(mfp)) != NULL) {
-		if(strcmp(mnt->mnt_fsname, dir) && strcmp(mnt->mnt_dir, dir))
-			continue;
-
-		if (!mc)
-			mc = (struct mntentchn *)xmalloc(sizeof(*mc));
-		mc->m = *mnt;
-	}
-
-	nfs_endmntent(mfp);
-	return mc;
-}
-
 /* complain about a failed umount */
 static void complain(int err, const char *dev) {
   switch (err) {
@@ -139,12 +115,11 @@ static void complain(int err, const char
   }
 }
 
-int del_mtab(const char *spec, const char *node, const char *type,
-		const char *opts, struct mntentchn *mc)
+int del_mtab(const char *spec, const char *node)
 {
-	int umnt_err, umnt_err2, res;
+	int umnt_err, res;
 
-        umnt_err = umnt_err2 = 0;
+        umnt_err = 0;
         if (lazy) {
                 res = umount2 (node, MNT_DETACH);
                 if (res < 0)
@@ -167,27 +142,7 @@ int del_mtab(const char *spec, const cha
         } else
                 res = umount (node);
 
-        if (res < 0) {
-                umnt_err = errno;
-                /* A device might have been mounted on a node that has since
-                   been deleted or renamed, so if node fails, also try spec. */
-                /* Note that this is incorrect in case spec was mounted
-                   several times. */
-                /* if (umnt_err == ENOENT || umnt_err == EINVAL) */
-                if (umnt_err != EBUSY && strcmp(node, spec)) {
-                        if (verbose)
-                                printf (_("could not umount %s - trying %s instead\n"),
-                                        node, spec);
-                        res = umount (spec);
-                        if (res < 0)
-                                umnt_err2 = errno;
-                       /* Do not complain about remote NFS mount points */
-                        if (errno == ENOENT && index(spec, ':'))
-                                umnt_err2 = 0;
-                }
-        }
-
-        if (res < 0 && remount && (umnt_err == EBUSY || umnt_err2 == EBUSY)) {
+        if (res < 0 && remount && errno == EBUSY && spec) {
                 /* Umount failed - let us try a remount */
                 res = mount(spec, node, NULL,
                             MS_MGC_VAL | MS_REMOUNT | MS_RDONLY, NULL);
@@ -213,21 +168,19 @@ int del_mtab(const char *spec, const cha
         if (res >= 0) {
                 /* Umount succeeded */
                 if (verbose)
-                        printf (_("%s umounted\n"), spec);
+                        printf (_("%s umounted\n"), spec ? spec : node);
         }
 
  writemtab:
         if (!nomtab &&
             (umnt_err == 0 || umnt_err == EINVAL || umnt_err == ENOENT)) {
-               update_mtab (node, NULL);
+               update_mtab(node, NULL);
         }
 
         if (res >= 0)
                 return 0;
 
-        if (umnt_err2)
-                complain(umnt_err2, spec);
-        if (umnt_err && umnt_err != umnt_err2)
+        if (umnt_err)
                 complain(umnt_err, node);
         return 1;
 }
@@ -364,24 +317,22 @@ int nfsumount(int argc, char *argv[])
 		return 0;
 	}
 
-	mc = getmntentchn(spec);
-	if (!mc)
+	if (*spec == '/')
 		mc = getmntdirbackward(spec, NULL);
-	if (!mc)
+	else
 		mc = getmntdevbackward(spec, NULL);
 	if (!mc && verbose)
 		printf(_("Could not find %s in mtab\n"), spec);
 
-	if(mc) {
+	if (mc) {
 		ret = _nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
 		if(ret)
-			ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir,
-				mc->m.mnt_type, mc->m.mnt_opts, mc);
-	}
-	else {
-		ret = _nfsumount(spec, NULL);
-		if(ret)
-			ret = del_mtab(spec, spec, spec, spec, NULL);
+			ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
+	} else {
+		if (*spec != '/')
+			ret = _nfsumount(spec, "tcp,v3");
+		else
+			ret = del_mtab(NULL, spec);
 	}
 
 	return(ret);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
