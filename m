Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750933AbaARRLh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Jan 2014 12:11:37 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0IHBbqD026732
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 18 Jan 2014 12:11:37 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-60-134.rdu2.redhat.com [10.10.60.134])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s0IHBack016972
	for <linux-nfs@vger.kernel.org>; Sat, 18 Jan 2014 12:11:36 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc.idmapd: Remove no longer supported flags from man page.
Date: Sat, 18 Jan 2014 12:13:27 -0500
Message-Id: <1390065207-11888-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.man | 22 ++--------------------
 1 file changed, 2 insertions(+), 20 deletions(-)

diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
index 58ea9f2..185cd1b 100644
--- a/utils/idmapd/idmapd.man
+++ b/utils/idmapd/idmapd.man
@@ -12,10 +12,7 @@
 .Nm rpc.idmapd
 .Op Fl v
 .Op Fl f
-.Op Fl d Ar domain
 .Op Fl p Ar path
-.Op Fl U Ar username
-.Op Fl G Ar groupname
 .Op Fl c Ar path
 .Sh DESCRIPTION
 .Nm
@@ -31,25 +28,10 @@ Increases the verbosity level (can be specified multiple times).
 Runs
 .Nm
 in the foreground and prints all output to the terminal.
-.It Fl d Ar domain
-Set domain to
-.Ar domain .
-This is used internally by NFSv4 and is typically assigned by the
-system administrator.  By default,
-.Ar domain
-is set to be the FQDN of the host, minus the hostname.
 .It Fl p Ar path
 Specifies the location of the RPC pipefs to be
 .Ar path .
 The default value is \&"/var/lib/nfs/rpc_pipefs\&".
-.It Fl U Ar username
-Specifies the NFSv4 nobody user to be
-.Ar username .
-The default value is \&"nobody\&".
-.It Fl G Ar groupname
-Specifies the NFSv4 nobody group to be
-.Ar groupname .
-The default value is \&"nobody\&".
 .It Fl c Ar path
 Use configuration file
 .Ar path .
@@ -59,11 +41,11 @@ Client-only: perform no idmapping for any NFS server, even if one is detected.
 Server-only: perform no idmapping for any NFS client, even if one is detected.
 .El
 .Sh EXAMPLES
-.Cm rpc.idmapd -d \&"citi.umich.edu\&" -f -vvv
+.Cm rpc.idmapd -f -vvv
 .Pp
 Runs
 .Nm
-with the domain \&"citi.umich.edu\&" in the foreground, printing all
+printing all
 messages to console, and with a verbosity level of 3.
 .\" This next request is for sections 2 and 3 function return values only.
 .\" .Sh RETURN VALUES
-- 
1.8.3.1

