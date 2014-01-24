Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f44.google.com ([209.85.214.44]:49867 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbaAXMJi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 07:09:38 -0500
Received: by mail-bk0-f44.google.com with SMTP id mz12so1107982bkb.31
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 04:09:37 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: dros@netapp.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: don't attempt auth methods that require upcall unless we know that gssd is running
Date: Fri, 24 Jan 2014 07:09:28 -0500
Message-Id: <1390565368-17597-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if the server lists krb5 as an allowed auth method, but gssd isn't
running, you'll get the infamous "AUTH_GSS upcall failed" message, even if
you didn't request sec=krb5.

This is because nfs4_find_root_sec() establishes a default list of auth
methods to try when the admin didn't supply one, and that list contains
AUTH_GSS methods first. Skip those methods if gssd isn't running since
they won't succeed anyway.

Cc: Weston Andros Adamson <dros@netapp.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15052b8..468a581 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2900,6 +2900,13 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	} else {
 		/* no flavors specified by user, try default list */
 		for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
+			/*
+			 * Don't attempt to upcall with the default list
+			 * unless we know that gssd is running.
+			 */
+			if (!gssd_running(server->nfs_client->cl_net))
+				continue;
+
 			status = nfs4_lookup_root_sec(server, fhandle, info,
 						      flav_array[i]);
 			if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
-- 
1.8.5.3

