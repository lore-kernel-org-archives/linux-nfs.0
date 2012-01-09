Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33972 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933046Ab2AITqO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jan 2012 14:46:14 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Change the default setting of the nfs4_disable_idmapping parameter
Date: Mon,  9 Jan 2012 14:45:54 -0500
Message-Id: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the use of numeric uids/gids is officially sanctioned in
RFC3530bis, it is time to change the default here to 'enabled'.

By doing so, we ensure that NFSv4 copies the behaviour of NFSv3 when we're
using the default AUTH_SYS authentication (i.e. when the client uses the
numeric uids/gids as authentication tokens), so that when new files are
created, they will appear to have the correct user/group.
It also fixes a number of backward compatibility issues when migrating
from NFSv3 to NFSv4 on a platform where the server uses different uid/gid
mappings than the client.

Note also that this setting has been successfully tested against servers
that do not support numeric uids/gids at several Connectathon/Bakeathon
events at this point, and the fall back to using string names/groups has
been shown to work well in all those test cases.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 Documentation/kernel-parameters.txt |   17 +++++++++++------
 fs/nfs/client.c                     |    2 +-
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 81c287f..dfd21cf 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1630,12 +1630,17 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			The default is to return 64-bit inode numbers.
 
 	nfs.nfs4_disable_idmapping=
-			[NFSv4] When set, this option disables the NFSv4
-			idmapper on the client, but only if the mount
-			is using the 'sec=sys' security flavour. This may
-			make migration from legacy NFSv2/v3 systems easier
-			provided that the server has the appropriate support.
-			The default is to always enable NFSv4 idmapping.
+			[NFSv4] When set to the default of '1', this option
+			ensures that both the RPC level authentication
+			scheme and the NFS level operations agree to use
+			numeric uids/gids if the mount is using the
+			'sec=sys' security flavour. In effect it is
+			disabling idmapping, which can make migration from
+			legacy NFSv2/v3 systems to NFSv4 easier.
+			Servers that do not support this mode of operation
+			will be autodetected by the client, and it will fall
+			back to using the idmapper.
+			To turn off this behaviour, set the value to '0'.
 
 	nmi_debug=	[KNL,AVR32,SH] Specify one or more actions to take
 			when a NMI is triggered.
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 41bd67f..277dfaf 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -84,7 +84,7 @@ retry:
 /*
  * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
  */
-static int nfs4_disable_idmapping = 0;
+static int nfs4_disable_idmapping = 1;
 
 /*
  * RPC cruft for NFS
-- 
1.7.7.5

