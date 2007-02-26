From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 02/11] nfs-utils: mount: Fixed umount -l
Date: Mon, 26 Feb 2007 06:17:31 -0500
Message-ID: <45E2C1CB.70401@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070504080901030400040903"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdom-0000Cf-Ef
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:14:56 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdoo-0006Cg-7D
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:14:58 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBEvH2000555
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:57 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBEuTC005419
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:56 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBEtKu025455
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:14:56 -0500
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
--------------070504080901030400040903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070504080901030400040903
Content-Type: text/x-patch;
 name="patch-02.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-02.dif"

commit eaa8dade2651ec9df1c9513e63ef2d9ae5c5d980
Author: Amit Gud <agud@redhat.com>
Date:   Sat Feb 24 15:02:36 2007 -0500

    Eliminated calls to the remote RPC call to
    the portmapper and mountd with the -l
    flag on umounts.
    
    Signed-off-by: Amit Gud <agud@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index dfbcb7c..5894e3a 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -100,9 +100,9 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
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
@@ -251,9 +251,6 @@ int add_mtab2(const char *spec, const char *node, const char *type,
         return 1;
 }
 
-/*
- * Returns 1 if everything went well, else 0.
- */
 int _nfsumount(const char *spec, const char *opts)
 {
 	char *hostname;
@@ -309,8 +306,8 @@ int _nfsumount(const char *spec, const char *opts)
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
 

--------------070504080901030400040903
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------070504080901030400040903
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070504080901030400040903--
