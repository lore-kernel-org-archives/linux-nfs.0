Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40235 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698Ab2CBTyx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 14:54:53 -0500
Received: by iagz16 with SMTP id z16so2712877iag.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 11:54:53 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] RFC: export options for junctions
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 02 Mar 2012 14:54:51 -0500
Message-ID: <20120302195451.18167.81861.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At Connectathon, I ran my FedFS-enabled client in a guest environment
with NAT networking.  This made the source port for my NFS connections
unprivileged.

Attempting to access a junction on my test server failed with a
"client insecure" error on the server, even if I specified the
"insecure" export option on the parent export.  I added "insecure" to
the default junction export options, and this fixed the problem.

Bruce suggested, however, that the correct way to address this is to
have junctions inherit the export options of their parent.  I don't
see a direct way to do this, so I'm posting this patch as a
conversation starter.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ac9cdbd..35bc2e9 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -853,7 +853,7 @@ locations_to_options(struct jp_ops *ops, nfs_fsloc_set_t locations,
 			ptr += len;
 		} else {
 			if (last_path == NULL)
-				len = snprintf(ptr, remaining, "refer=%s@%s",
+				len = snprintf(ptr, remaining, "insecure,refer=%s@%s",
 							rootpath, server);
 			else
 				len = snprintf(ptr, remaining, ":%s@%s",

