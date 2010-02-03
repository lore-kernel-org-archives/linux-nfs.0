From: Ben Myers <bpm@sgi.com>
Subject: [RFC PATCH 1/4] Add 'wsync' export option.
Date: Wed, 03 Feb 2010 17:44:29 -0600
Message-ID: <20100203234429.17677.38683.stgit@case>
References: <20100203233755.17677.96582.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:35565 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756585Ab0BCXoa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 18:44:30 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay3.corp.sgi.com (Postfix) with ESMTP id A0A07AC036
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 15:44:30 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id 8C18E48D6BF8
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 17:44:29 -0600 (CST)
In-Reply-To: <20100203233755.17677.96582.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


---
 fs/nfsd/export.c            |    1 +
 include/linux/nfsd/export.h |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c487810..170bf68 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1428,6 +1428,7 @@ static struct flags {
 	{ NFSEXP_ROOTSQUASH, {"root_squash", "no_root_squash"}},
 	{ NFSEXP_ALLSQUASH, {"all_squash", ""}},
 	{ NFSEXP_ASYNC, {"async", "sync"}},
+	{ NFSEXP_WSYNC, {"wsync", ""}},
 	{ NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
 	{ NFSEXP_NOHIDE, {"nohide", ""}},
 	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 8ae78a6..f6b7fc9 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -31,7 +31,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40 80 100 currently unused */
+#define NFSEXP_WSYNC		0x0040
+/* 80 100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
@@ -121,6 +122,7 @@ struct svc_expkey {
 };
 
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
+#define EX_ISWSYNC(exp)		(EX_ISSYNC(exp) && ((exp)->ex_flags & NFSEXP_WSYNC))
 #define EX_NOHIDE(exp)		((exp)->ex_flags & NFSEXP_NOHIDE)
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
 

