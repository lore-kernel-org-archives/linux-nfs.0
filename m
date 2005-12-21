From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils 1.0.8-rc2
Date: Wed, 21 Dec 2005 14:22:18 +1100
Message-ID: <17320.51818.921672.429852@cse.unsw.edu.au>
References: <17314.22172.913247.595571@cse.unsw.edu.au>
	<17319.46982.772021.518625@cse.unsw.edu.au>
	<43A7DA2F.8090902@ext.bull.net>
	<17320.50441.923081.501789@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EouYh-00048p-7R
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 19:22:31 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EouYg-0006ET-9U
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 19:22:31 -0800
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>,
	nfs@lists.sourceforge.net
In-Reply-To: message from Neil Brown on Wednesday December 21
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wednesday December 21, neilb@suse.de wrote:
> 
> I guess I'd better fix it....
> 

Does this patch
  a/ look ok (if a bit heavy handed).
  b/ compile for you?

Thanks,
NeilBrown


Index: utils/rquotad/rquota_server.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/rquotad/rquota_server.c,v
retrieving revision 1.9
diff -u -r1.9 rquota_server.c
--- utils/rquotad/rquota_server.c	20 Dec 2005 04:12:47 -0000	1.9
+++ utils/rquotad/rquota_server.c	21 Dec 2005 03:21:09 -0000
@@ -22,14 +22,20 @@
 #ifdef HAVE_CONFIG_H
 #include <config.h>
 #endif
-#define _LINUX_QUOTA_VERSION 1
 
 #include <rpc/rpc.h>
 #include "rquota.h"
 #include <sys/file.h>
 #include <sys/stat.h>
 #include <sys/param.h>
+/* Unfortunately we cannot trust sys/quota.h to have
+ * what we need, either the old interface could be missing
+ * (SLES9) or the new (SLES8 and others).
+ * So we will just put it explicitly below
+ */
+#if 0
 #include <sys/quota.h>
+#endif
 #include <sys/mount.h>
 #include <dirent.h>
 #include <paths.h>
@@ -50,6 +56,47 @@
 #define BLOCK_SIZE 1024
 #endif
 
+#define MAXQUOTAS 2
+#define USRQUOTA  0		/* element used for user quotas */
+#define GRPQUOTA  1		/* element used for group quotas */
+
+struct dqblk {
+	u_int32_t dqb_bhardlimit;   /* absolute limit on disk blks alloc */
+	u_int32_t dqb_bsoftlimit;   /* preferred limit on disk blks */
+	u_int32_t dqb_curblocks;    /* current block count */
+	u_int32_t dqb_ihardlimit;   /* maximum # allocated inodes */
+	u_int32_t dqb_isoftlimit;   /* preferred inode limit */
+	u_int32_t dqb_curinodes;    /* current # allocated inodes */
+	time_t dqb_btime;           /* time limit for excessive disk use */
+	time_t dqb_itime;           /* time limit for excessive files */
+};
+
+struct if_dqblk {
+        u_int64_t dqb_bhardlimit;
+        u_int64_t dqb_bsoftlimit;
+        u_int64_t dqb_curspace;
+        u_int64_t dqb_ihardlimit;
+        u_int64_t dqb_isoftlimit;
+        u_int64_t dqb_curinodes;
+        u_int64_t dqb_btime;
+        u_int64_t dqb_itime;
+        u_int32_t dqb_valid;
+};
+
+#define SUBCMDMASK  0x00ff
+#define SUBCMDSHIFT 8
+#define QCMD(cmd, type)  (((cmd) << SUBCMDSHIFT) | ((type) & SUBCMDMASK))
+
+#define Q_GETQUOTA 0x0300	/* get limits and usage */
+#define Q_SETQUOTA 0x0400	/* set limits and usage */
+
+#define Q_GETFMT   0x800004     /* get quota format used on given filesystem */
+#define Q_GETQUOTA_NEW 0x800007 /* get user quota structure */
+#define Q_SETQUOTA_NEW 0x800008 /* set user quota structure */
+#define dqoff(UID)      ((loff_t)((UID) * sizeof (struct dqblk)))
+
+extern int quotactl (int __cmd, const char *__special, int __id,
+		     caddr_t __addr) __THROW;
 /*
  * Global unix authentication credentials.
  */
@@ -75,12 +122,12 @@
       ext_getquota_args *ext_args;
    } arguments;
    FILE *fp;
-   struct dqblk dq_dqb;
    struct mntent *mnt;
    char *pathname, *qfpathname;
    int fd, err, id, type;
    struct stat stm, stn;
    struct rquota *rquota;
+   struct if_dqblk dqb;
 
    /*
     * First check authentication.
@@ -134,32 +181,53 @@
       result.getquota_rslt_u.gqr_rquota.rq_bsize = BLOCK_SIZE;
 
       if (hasquota(mnt, type, &qfpathname)) {
-         if ((err = quotactl(QCMD(Q_GETQUOTA, type), mnt->mnt_fsname,
-	 		     id, (caddr_t)&dq_dqb)) == -1
-	     && !(flags & ACTIVE)) {
-            if ((fd = open(qfpathname, O_RDONLY)) < 0)
-	    {
-	       free(qfpathname);
-               continue;
-	    }
-            free(qfpathname);
-            lseek(fd, (long) dqoff(id), L_SET);
-            switch (read(fd, &dq_dqb, sizeof(struct dqblk))) {
-               case 0:/* EOF */
-                  /*
-                   * Convert implicit 0 quota (EOF) into an
-                   * explicit one (zero'ed dqblk)
-                   */
-                  memset((caddr_t)&dq_dqb, 0, sizeof(struct dqblk));
-                  break;
-               case sizeof(struct dqblk):   /* OK */
-                  break;
-               default:   /* ERROR */
-                  close(fd);
-                  continue;
-            }
-            close(fd);
-         }
+	      int fmt;
+	      if (quotactl(QCMD(Q_GETFMT, type), mnt->mnt_fsname, 0, (caddr_t)&fmt)==0) {
+		      /* new style interface
+		       * Don't bother trying to read from the file
+		       */
+		      err = quotactl(QCMD(Q_GETQUOTA_NEW, type),
+				     mnt->mnt_fsname, id, (caddr_t)&dqb);
+		      if (err) memset(&dqb, 0, sizeof(dqb));
+	      } else {
+		      /* old style */
+		      struct dqblk dq_dqb;
+
+		      if ((err = quotactl(QCMD(Q_GETQUOTA, type), mnt->mnt_fsname,
+					  id, (caddr_t)&dq_dqb)) == -1
+			  && !(flags & ACTIVE)) {
+			      if ((fd = open(qfpathname, O_RDONLY)) < 0)
+			      {
+				      free(qfpathname);
+				      continue;
+			      }
+			      free(qfpathname);
+			      lseek(fd, (long) dqoff(id), L_SET);
+			      switch (read(fd, &dq_dqb, sizeof(struct dqblk))) {
+			      case 0:/* EOF */
+				      /*
+				       * Convert implicit 0 quota (EOF) into an
+				       * explicit one (zero'ed dqblk)
+				       */
+				      memset((caddr_t)&dq_dqb, 0, sizeof(struct dqblk));
+				      break;
+			      case sizeof(struct dqblk):   /* OK */
+				      break;
+			      default:   /* ERROR */
+				      close(fd);
+				      continue;
+			      }
+			      close(fd);
+		      }
+		      dqb.dqb_bhardlimit = dq_dqb.dqb_bhardlimit;
+		      dqb.dqb_bsoftlimit = dq_dqb.dqb_bsoftlimit;
+		      dqb.dqb_curspace = dq_dqb.dqb_curblocks * 1024;
+		      dqb.dqb_ihardlimit = dq_dqb.dqb_ihardlimit;
+		      dqb.dqb_isoftlimit = dq_dqb.dqb_isoftlimit;
+		      dqb.dqb_curinodes = dq_dqb.dqb_curinodes;
+		      dqb.dqb_btime = dq_dqb.dqb_btime;
+		      dqb.dqb_itime = dq_dqb.dqb_itime;
+	      }
          endmntent(fp);
 
          if (err && (flags & ACTIVE)) {
@@ -175,14 +243,14 @@
           */
 
          rquota = &result.getquota_rslt_u.gqr_rquota;
-         rquota->rq_bhardlimit = dq_dqb.dqb_bhardlimit;
-         rquota->rq_bsoftlimit = dq_dqb.dqb_bsoftlimit;;
-         rquota->rq_curblocks = dq_dqb.dqb_curblocks;
-         rquota->rq_fhardlimit = dq_dqb.dqb_ihardlimit;
-         rquota->rq_fsoftlimit = dq_dqb.dqb_isoftlimit;
-         rquota->rq_curfiles = dq_dqb.dqb_curinodes;
-         rquota->rq_btimeleft = dq_dqb.dqb_btime;
-         rquota->rq_ftimeleft = dq_dqb.dqb_itime;
+         rquota->rq_bhardlimit = dqb.dqb_bhardlimit;
+         rquota->rq_bsoftlimit = dqb.dqb_bsoftlimit;;
+         rquota->rq_curblocks = dqb.dqb_curspace/1024;
+         rquota->rq_fhardlimit = dqb.dqb_ihardlimit;
+         rquota->rq_fsoftlimit = dqb.dqb_isoftlimit;
+         rquota->rq_curfiles = dqb.dqb_curinodes;
+         rquota->rq_btimeleft = dqb.dqb_btime;
+         rquota->rq_ftimeleft = dqb.dqb_itime;
 
          return(&result);
       }


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
