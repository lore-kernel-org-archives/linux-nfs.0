Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35520 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751586AbdBXAeM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 19:34:12 -0500
Received: by mail-it0-f68.google.com with SMTP id 203so807232ith.2
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2017 16:33:56 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.com
Subject: [PATCH 2/2] nfsd: Change the default to enable all minor versions unless told otherwise
Date: Thu, 23 Feb 2017 19:33:44 -0500
Message-Id: <20170224003344.113724-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170224003344.113724-2-trond.myklebust@primarydata.com>
References: <20170224003344.113724-1-trond.myklebust@primarydata.com>
 <20170224003344.113724-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of letting the kernel decide, default to enabling all versions,
and let the user be more specifc in /etc/nfs.conf or on the command line.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 utils/nfsd/nfsd.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 1708521ab286..9735e65466fa 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -107,13 +107,12 @@ main(int argc, char **argv)
 	}
 
 	nfssvc_get_minormask(&minormask);
-	/* We assume the kernel will default all minor versions to 'on',
-	 * and allow the config file to disable some.
+	/* We default all minor versions to 'on', and allow the config
+	 * file to disable some.
 	 */
-	if (NFSCTL_VERISSET(versbits, 4)) {
-		NFSCTL_MINORSET(minorversset, 0);
-		NFSCTL_MINORSET(minorvers, 0);
-	}
+	if (NFSCTL_VERISSET(versbits, 4))
+		minorversset = minorvers = minormask;
+
 	for (i = 1; i <= NFS4_MAXMINOR; i++) {
 		char tag[20];
 		sprintf(tag, "vers4.%d", i);
-- 
2.9.3

