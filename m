Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35662 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752942AbdHJUld (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Aug 2017 16:41:33 -0400
Received: by mail-it0-f65.google.com with SMTP id 76so2422847ith.2
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 13:41:32 -0700 (PDT)
Received: from manet.1015granger.net (c-68-46-169-226.hsd1.mi.comcast.net. [68.46.169.226])
        by smtp.gmail.com with ESMTPSA id z75sm3651152ita.18.2017.08.10.13.41.31
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 13:41:31 -0700 (PDT)
Subject: [PATCH v2] NFS: Fix NFSv2 security settings
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 10 Aug 2017 16:41:31 -0400
Message-ID: <20170810204110.11398.85077.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For a while now any NFSv2 mount where sec= is specified uses
AUTH_NULL. If sec= is not specified, the mount uses AUTH_UNIX.
Commit e68fd7c8071d ("mount: use sec= that was specified on the
command line") attempted to address a very similar problem with
NFSv3, and should have fixed this too, but it has a bug.

The MNTv1 MNT procedure does not return a list of security flavors,
so our client makes up a list containing just AUTH_NULL. This should
enable nfs_verify_authflavors() to assign the sec= specified flavor,
but instead, it incorrectly sets it to AUTH_NULL.

I expect this would also be a problem for any NFSv3 server whose
MNTv3 MNT procedure returned a security flavor list containing only
AUTH_NULL.

Fixes: e68fd7c8071d ("mount: use sec= that was specified on ... ")
BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=310
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/super.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Changes since v1:
- Description edited for accuracy

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d828ef8..6b179af 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1691,8 +1691,8 @@ static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
 			rpc_authflavor_t *server_authlist, unsigned int count)
 {
 	rpc_authflavor_t flavor = RPC_AUTH_MAXFLAVOR;
+	bool found_auth_null = false;
 	unsigned int i;
-	int use_auth_null = false;
 
 	/*
 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
@@ -1701,6 +1701,10 @@ static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
 	 * AUTH_NULL has a special meaning when it's in the server list - it
 	 * means that the server will ignore the rpc creds, so any flavor
 	 * can be used but still use the sec= that was specified.
+	 *
+	 * Note also that the MNT procedure in MNTv1 does not return a list
+	 * of supported security flavors. In this case, nfs_mount() fabricates
+	 * a security flavor list containing just AUTH_NULL.
 	 */
 	for (i = 0; i < count; i++) {
 		flavor = server_authlist[i];
@@ -1709,11 +1713,11 @@ static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
 			goto out;
 
 		if (flavor == RPC_AUTH_NULL)
-			use_auth_null = true;
+			found_auth_null = true;
 	}
 
-	if (use_auth_null) {
-		flavor = RPC_AUTH_NULL;
+	if (found_auth_null) {
+		flavor = args->auth_info.flavors[0];
 		goto out;
 	}
 

