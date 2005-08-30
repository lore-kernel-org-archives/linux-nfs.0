From: Mike Frysinger <vapier@gentoo.org>
Subject: rquota overflow fix never applied ?
Date: Tue, 30 Aug 2005 01:08:52 -0400
Message-ID: <200508300108.52636.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_kn+ED3CHA2s+1yK"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E9yMg-0000PL-N6
	for nfs@lists.sourceforge.net; Mon, 29 Aug 2005 22:08:54 -0700
Received: from smtp.gentoo.org ([134.68.220.30])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E9yMg-0002qH-Cp
	for nfs@lists.sourceforge.net; Mon, 29 Aug 2005 22:08:54 -0700
Received: from localhost ([127.0.0.1] helo=home.wh0rd.org)
	by smtp.gentoo.org with esmtp (Exim 4.43)
	id 1E9yMZ-00060h-QW
	for nfs@lists.sourceforge.net; Tue, 30 Aug 2005 05:08:47 +0000
To: nfs@lists.sourceforge.net
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

--Boundary-00=_kn+ED3CHA2s+1yK
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Gentoo and Fedora both apply an old patch to resolve an overflow issue ... is 
this just a case of fixes never going upstream or is there a reason this 
hasnt been applied ... if so, can someone please clue me in ;)
-mike

--Boundary-00=_kn+ED3CHA2s+1yK
Content-Type: text/x-diff;
  charset="us-ascii";
  name="nfs-utils-0.3.3-rquotad-overflow.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs-utils-0.3.3-rquotad-overflow.patch"

--- nfs-utils-0.3.3/utils/rquotad/rquota_server.c.orig	Wed Jun 27 12:45:56 2001
+++ nfs-utils-0.3.3/utils/rquotad/rquota_server.c	Thu Nov 11 14:36:39 2004
@@ -76,6 +76,7 @@ getquota_rslt *getquotainfo(int flags, c
    char *pathname, *qfpathname;
    int fd, err, id, type;
    struct stat stm, stn;
+   struct rquota *rquota;
 
    /*
     * First check authentication.
@@ -168,8 +169,16 @@ getquota_rslt *getquotainfo(int flags, c
           * Make a copy of the info into the last part of the remote quota
           * struct which is exactly the same.
           */
-         memcpy((caddr_t *)&result.getquota_rslt_u.gqr_rquota.rq_bhardlimit,
-                (caddr_t *)&dq_dqb, sizeof(struct dqblk));
+
+         rquota = &result.getquota_rslt_u.gqr_rquota;
+         rquota->rq_bhardlimit = dq_dqb.dqb_bhardlimit;
+         rquota->rq_bsoftlimit = dq_dqb.dqb_bsoftlimit;;
+         rquota->rq_curblocks = dq_dqb.dqb_curblocks;
+         rquota->rq_fhardlimit = dq_dqb.dqb_ihardlimit;
+         rquota->rq_fsoftlimit = dq_dqb.dqb_isoftlimit;
+         rquota->rq_curfiles = dq_dqb.dqb_curinodes;
+         rquota->rq_btimeleft = dq_dqb.dqb_btime;
+         rquota->rq_ftimeleft = dq_dqb.dqb_itime;
 
          return(&result);
       }

--Boundary-00=_kn+ED3CHA2s+1yK--


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
