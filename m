From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 4 of 10 - Replaced a memcopy with explicit assignment
Date: Fri, 23 Sep 2005 10:45:06 -0400
Message-ID: <433414F2.6000007@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040802050800070203090907"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIonl-0005ox-Tb
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:45:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIoni-0006bv-MO
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:45:23 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEjCvg014336
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:45:12 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEj6V13043
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:45:07 -0400
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

This is a multi-part message in MIME format.
--------------040802050800070203090907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------040802050800070203090907
Content-Type: text/x-patch;
 name="nfs-utils-1.0.6-rquotad-overflow.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-rquotad-overflow.patch"

Replaced a memcopy with explicit assignments
in getquotainfo() of rquotad to fix potential overflow
that can occur on 64bit machines. (bz 138068)

Details can be found in:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=138063

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- nfs-utils-1.0.6/utils/rquotad/rquota_server.c.org	2001-06-27 12:45:56.000000000 -0400
+++ nfs-utils-1.0.6/utils/rquotad/rquota_server.c	2004-11-08 16:06:11.000000000 -0500
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

--------------040802050800070203090907--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
