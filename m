From: Amit Gud <agud@redhat.com>
Subject: [PATCH] fix lazy and force umounts for mount.nfs
Date: Fri, 28 Jul 2006 11:54:06 -0400
Message-ID: <44CA331E.2080004@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090800000609080401010205"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6UbP-0002eb-3p
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 08:50:15 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G6UbI-0001jJ-Hf
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 08:50:15 -0700
To: Neil Brown <neilb@suse.de>
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

This is a multi-part message in MIME format.
--------------090800000609080401010205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


--------------090800000609080401010205
Content-Type: text/plain;
 name="lazy-umount-fix-v1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lazy-umount-fix-v1.patch"

Fixes lazy umount freezing when NFS server is down or unreachable. This
enables lazy and force umounting possible without bothering the server.
This is useful when NFS server is down or unreachable.


Signed-off-by: Amit Gud <agud@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>

---

--- nfs-utils/utils/mount/nfsumount.c	2006-07-25 11:10:45.000000000 -0400
+++ nfs-utils-ag/utils/mount/nfsumount.c	2006-07-25 16:03:32.000000000 -0400
@@ -100,9 +100,9 @@ int nfs_call_umount(clnt_addr_t *mnt_ser
 	}
 	mnt_closeclnt(clnt, msock);
 	if (res == RPC_SUCCESS)
-		return 1;
+		return 0;
  out_bad:
-	return 0;
+	return 1;
 }
 
 u_int get_mntproto(const char *);
@@ -251,9 +251,6 @@ int add_mtab2(const char *spec, const ch
         return 1;
 }
 
-/*
- * Returns 1 if everything went well, else 0.
- */
 int _nfsumount(const char *spec, const char *opts)
 {
 	char *hostname;
@@ -309,8 +306,8 @@ int _nfsumount(const char *spec, const c
 		goto out_bad;
 	return nfs_call_umount(&mnt_server, &dirname);
  out_bad:
-	fprintf(stderr, "%s: %s: not found or not mounted\n", progname, spec);
-	return 0;
+	fprintf(stderr, "%s: %s: not found / mounted or server not reachable\n", progname, spec);
+	return 1;
 }
 
 static struct option umount_longopts[] =
@@ -393,14 +390,18 @@ int nfsumount(int argc, char *argv[])
 			}
 		}
 
-		ret = _nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
-		if(ret)
+		ret = 0;
+		if(!force && !lazy)
+			ret = _nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
+		if(!ret)
 			ret = add_mtab2(mc->m.mnt_fsname, mc->m.mnt_dir,
 				mc->m.mnt_type, mc->m.mnt_opts, mc);
 	}
 	else {
-		ret = _nfsumount(spec, NULL);
-		if(ret)
+		ret = 0;
+		if(!force && !lazy)
+			ret = _nfsumount(spec, NULL);
+		if(!ret)
 			ret = add_mtab2(spec, spec, spec, spec, NULL);
 	}
 

--------------090800000609080401010205
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------090800000609080401010205
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090800000609080401010205--
