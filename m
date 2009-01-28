From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] nfs-utils: git should ignore cscope.* files
Date: Wed, 28 Jan 2009 18:07:38 -0500
Message-ID: <20090128230738.21484.11187.stgit@ingres.1015granger.net>
References: <20090128225938.21484.82096.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:46397 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbZA1XJE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 18:09:04 -0500
In-Reply-To: <20090128225938.21484.82096.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tell git to ignore cscope database files.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 .gitignore |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index a5cf8ce..cfc329a 100644
--- a/.gitignore
+++ b/.gitignore
@@ -54,5 +54,7 @@ utils/statd/sm_inter.h
 utils/statd/sm_inter_clnt.c
 utils/statd/sm_inter_svc.c
 utils/statd/sm_inter_xdr.c
+# cscope database files
+cscope.*
 # generic editor backup et al
 *~

