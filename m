Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:62123 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbaE3NJq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:46 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so5115720qgf.21
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:45 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] nfsd: make nfsd4_encode_fattr static
Date: Fri, 30 May 2014 09:09:25 -0400
Message-Id: <1401455373-18207-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sparse says:

      CHECK   fs/nfsd/nfs4xdr.c
    fs/nfsd/nfs4xdr.c:2043:1: warning: symbol 'nfsd4_encode_fattr' was not declared. Should it be static?

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d3a576dbd99b..6bcdff11c32c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2039,7 +2039,7 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
  */
-__be32
+static __be32
 nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		struct svc_export *exp,
 		struct dentry *dentry, u32 *bmval,
-- 
1.9.3

