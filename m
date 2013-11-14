Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f41.google.com ([209.85.213.41]:34560 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765Ab3KNQf4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:35:56 -0500
Received: by mail-yh0-f41.google.com with SMTP id f11so1143064yha.0
        for <linux-nfs@vger.kernel.org>; Thu, 14 Nov 2013 08:35:55 -0800 (PST)
Subject: [PATCH] nfs(5): Document the "migration" mount option
To: steved@redhat.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 14 Nov 2013 11:35:53 -0500
Message-ID: <20131114163552.19821.30799.stgit@manray.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support for NFSv4 migration was merged in 3.13.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/mount/nfs.man |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 2a42b93..8535aec 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -855,6 +855,26 @@ In the presence of multiple client network interfaces,
 special routing policies,
 or atypical network topologies,
 the exact address to use for callbacks may be nontrivial to determine.
+.TP 1.5i
+.BR migration " / " nomigration
+Selects whether the client uses an identification string that is compatible
+with NFSv4 Transparent State Migration (TSM).
+If the mounted server supports NFSv4 migration with TSM, specify the
+.B migration
+option.
+.IP
+Some server features misbehave in the face of a migration-compatible
+identification string.
+The
+.B nomigration
+option retains the use of a traditional client indentification string
+which is compatible with legacy NFS servers.
+This is also the behavior if neither option is specified.
+A client's open and lock state cannot be migrated transparently
+when it identifies itself via a traditional identification string.
+.IP
+This mount option has no effect with NFSv4 minor versions newer than zero,
+which always use TSM-compatible client identification strings.
 .SH nfs4 FILE SYSTEM TYPE
 The
 .BR nfs4

