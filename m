Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758241Ab3D2M7G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Apr 2013 08:59:06 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 03/17] NFSDv4.2: Added NFS v4.2 support to the NFS server
Date: Mon, 29 Apr 2013 08:57:05 -0400
Message-Id: <1367240239-19326-4-git-send-email-SteveD@redhat.com>
In-Reply-To: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

This enable NFSv4.2 support for the server. To enable this
code do the following:
  echo "+4.2" >/proc/fs/nfsd/versions

after the nfsd kernel module is loaded.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 1 +
 fs/nfsd/nfsd.h    | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a272007..b38de7a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1572,6 +1572,7 @@ struct nfsd4_minorversion_ops {
 static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
 	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
 	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
+	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
 };
 
 static __be32
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 553b230..4c682fd 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -24,7 +24,7 @@
 /*
  * nfsd version
  */
-#define NFSD_SUPPORTED_MINOR_VERSION	1
+#define NFSD_SUPPORTED_MINOR_VERSION	2
 /*
  * Maximum blocksizes supported by daemon under various circumstances.
  */
-- 
1.8.1.4

