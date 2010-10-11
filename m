Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0JKAEe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:04:34 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:04:34 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/15] export: Ensure that we free struct exportent->e_uuid
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:04:32 -0400
Message-ID: <20101011000432.6667.27334.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Currently, the exportent->e_uuid is initialised in
support/nfs/exports.c:parseopts(), but it is never freed.

Also ensure that exportent->e_uuid is duplicated correctly in
dupexportent().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Adjusted to account for the new export_free() helper.

Also, e_uuid points to memory that is always allocated with strdup(3),
not with xstrdup().  Thus it must be freed via free(3) and not via
xfree().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/export.c |    1 +
 support/nfs/exports.c   |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index f528603..4fda30a 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -38,6 +38,7 @@ export_free(nfs_export *exp)
 	xfree(exp->m_export.e_sqgids);
 	free(exp->m_export.e_mountpoint);
 	free(exp->m_export.e_fslocdata);
+	free(exp->m_export.e_uuid);
 
 	xfree(exp->m_export.e_hostname);
 	xfree(exp);
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index a93941c..1744ed6 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -332,6 +332,8 @@ dupexportent(struct exportent *dst, struct exportent *src)
 		dst->e_mountpoint = strdup(src->e_mountpoint);
 	if (src->e_fslocdata)
 		dst->e_fslocdata = strdup(src->e_fslocdata);
+	if (src->e_uuid)
+		dst->e_uuid = strdup(src->e_uuid);
 	dst->e_hostname = NULL;
 }
 

