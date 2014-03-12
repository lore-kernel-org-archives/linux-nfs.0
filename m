Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:58921 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaCLQvY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 12:51:24 -0400
Received: by mail-ie0-f178.google.com with SMTP id lx4so11001098iec.9
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 09:51:23 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] NFS: Clean up: revert increase in READDIR RPC buffer max
	size
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 12 Mar 2014 12:51:17 -0400
Message-ID: <20140312165117.15349.8938.stgit@manet.1015granger.net>
In-Reply-To: <20140312164620.15349.22643.stgit@manet.1015granger.net>
References: <20140312164620.15349.22643.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Security labels go with each directory entry, thus they are always
stored in the page cache, not in the head buffer.  The length of the
reply that goes in head[0] should not have changed to support
NFSv4.2 labels.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5be2868..79e1d02 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -203,8 +203,7 @@ static int nfs4_stat_to_errno(int);
 				 2 + encode_verifier_maxsz + 5 + \
 				nfs4_label_maxsz)
 #define decode_readdir_maxsz	(op_decode_hdr_maxsz + \
-				 decode_verifier_maxsz + \
-				nfs4_label_maxsz + nfs4_fattr_maxsz)
+				 decode_verifier_maxsz)
 #define encode_readlink_maxsz	(op_encode_hdr_maxsz)
 #define decode_readlink_maxsz	(op_decode_hdr_maxsz + 1)
 #define encode_write_maxsz	(op_encode_hdr_maxsz + \

