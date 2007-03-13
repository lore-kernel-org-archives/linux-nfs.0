From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] [nfs-utils: mountd] exports too verbose.
Date: Tue, 13 Mar 2007 12:02:13 -0400
Message-ID: <45F6CB05.6010604@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010003040306080906060309"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HR9S4-0006NM-ED
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 09:02:18 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HR9S5-0001ES-Ap
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 09:02:18 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l2DG2Eq2010459
	for <nfs@lists.sourceforge.net>; Tue, 13 Mar 2007 12:02:14 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l2DG2EkX008452
	for <nfs@lists.sourceforge.net>; Tue, 13 Mar 2007 12:02:14 -0400
Received: from [10.12.32.32] (dickson.boston.devel.redhat.com [10.12.32.32])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l2DG2D36014806
	for <nfs@lists.sourceforge.net>; Tue, 13 Mar 2007 12:02:14 -0400
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
--------------010003040306080906060309
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch is relative to the git tree at:
git://git.infradead.org/~steved/nfs-utils.git
which has been updated to the nfs-utils-1.0.12
release.

Please consider...

steved.



--------------010003040306080906060309
Content-Type: text/x-patch;
 name="exports-nonverbose.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="exports-nonverbose.patch"

commit daf1b781bf92177ed616e4ced1a3f90353acde25
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Mar 13 11:55:00 2007 -0400

    This patch tones down the verbosity of exports that export
    the same directory for both read-only and read-write.
    Something similar to:
    
    /var    10.12.32.32(rw,nohide,fsid=1)
    /var    *(ro,nohide,fsid=1)
    
    Every time the export is access, the following syslog
    is logged:
    
    /var exported to both * and 10.12.32.32 in *,10.12.32.32
    
    Since the exports are working as expected, this
    syslog is really not needed. So this patch changes
    that syslog from a warning to a debugging message.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index a14f4f2..3e30a76 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -511,7 +511,7 @@ void nfsd_export(FILE *f)
 			if (!found)
 				found = exp;
 			else {
-				xlog(L_WARNING, "%s exported to both %s and %s in %s",
+				xlog(D_GENERAL, "%s exported to both %s and %s in %s",
 				     path, exp->m_client->m_hostname, found->m_client->m_hostname,
 				     dom);
 			}

--------------010003040306080906060309
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------010003040306080906060309
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010003040306080906060309--
