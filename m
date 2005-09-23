From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 9 of 10 - Changed xlog to use LOG_INFO instead
 of LOG_DEBUG
Date: Fri, 23 Sep 2005 10:50:03 -0400
Message-ID: <4334161B.8050106@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020405010208060006040604"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIosM-000672-6V
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:50:10 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIosL-0003wz-W9
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:50:10 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEo4br016008
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:50:04 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEo4V14645
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:50:04 -0400
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
--------------020405010208060006040604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------020405010208060006040604
Content-Type: text/x-patch;
 name="nfs-utils-1.0.7-xlog-loginfo.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.7-xlog-loginfo.patch"

Changed xlog to use LOG_INFO instead of LOG_DEBUG
so debug messages will appear w/out any config
changes to syslog.conf.

Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- nfs-utils-1.0.7/support/nfs/xlog.c.xlog	2005-09-13 15:18:02.626241000 -0400
+++ nfs-utils-1.0.7/support/nfs/xlog.c	2005-09-13 15:22:07.690652000 -0400
@@ -161,7 +161,7 @@ xlog(int kind, const char *fmt, ...)
 			break;
 		default:
 			if (!log_stderr)
-				syslog(LOG_DEBUG, "%s", buff);
+				syslog(LOG_INFO, "%s", buff);
 			break;
 		}
 	}

--------------020405010208060006040604--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
