Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57863 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752127AbaLWVoy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2014 16:44:54 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBNListD014801
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 16:44:54 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBNLira4025074
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 16:44:53 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sBNLirFT018073
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 16:44:53 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sBNLiqIx018072
	for linux-nfs@vger.kernel.org; Tue, 23 Dec 2014 16:44:52 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] rpc.idmapd: Add a reference to nfsidmap(8) on the man page
Date: Tue, 23 Dec 2014 16:44:52 -0500
Message-Id: <1419371092-18037-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Even though the 'new' idmapper used by the client has been around for
several years, a lot of users seem to be unaware of its existence.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/idmapd/idmapd.man | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
index 185cd1b..c809f78 100644
--- a/utils/idmapd/idmapd.man
+++ b/utils/idmapd/idmapd.man
@@ -20,6 +20,16 @@ is the NFSv4 ID <-> name mapping daemon.  It provides functionality to
 the NFSv4 kernel client and server, to which it communicates via
 upcalls, by translating user and group IDs to names, and vice versa.
 .Pp
+Note that on more recent kernels only the NFSv4 server uses
+.Nm .
+The NFSv4 client instead uses
+.Xr nfsidmap 8 ,
+and only falls back to 
+.Nm 
+if there was a problem running the
+.Xr nfsidmap 8
+program.
+.Pp
 The options are as follows:
 .Bl -tag -width Ds_imagedir
 .It Fl v
@@ -58,7 +68,8 @@ messages to console, and with a verbosity level of 3.
 .Sh FILES
 .Pa /etc/idmapd.conf
 .Sh SEE ALSO
-.Xr idmapd.conf 5
+.Xr idmapd.conf 5 ,
+.Xr nfsidmap 8
 .\".Sh SEE ALSO
 .\".Xr nylon.conf 4
 .\" .Sh COMPATIBILITY
-- 
1.9.3

