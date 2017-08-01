Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:37403 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbdHAP77 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 11:59:59 -0400
Received: by mail-io0-f196.google.com with SMTP id c74so1828076iod.4
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 08:59:59 -0700 (PDT)
Subject: [PATCH v1 2/4] nfsd: Const-ify NFSv4 encoding and decoding ops
 arrays
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 01 Aug 2017 11:59:58 -0400
Message-ID: <20170801155958.14944.81071.stgit@klimt.1015granger.net>
In-Reply-To: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
References: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Close an attack vector by moving the arrays of encoding and decoding
methods to read-only memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 20fbcab..51e729a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1780,7 +1780,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 
 typedef __be32(*nfsd4_dec)(struct nfsd4_compoundargs *argp, void *);
 
-static nfsd4_dec nfsd4_dec_ops[] = {
+static const nfsd4_dec nfsd4_dec_ops[] = {
 	[OP_ACCESS]		= (nfsd4_dec)nfsd4_decode_access,
 	[OP_CLOSE]		= (nfsd4_dec)nfsd4_decode_close,
 	[OP_COMMIT]		= (nfsd4_dec)nfsd4_decode_commit,
@@ -4332,7 +4332,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
  * since we don't need to filter out obsolete ops as this is
  * done in the decoding phase.
  */
-static nfsd4_enc nfsd4_enc_ops[] = {
+static const nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_ACCESS]		= (nfsd4_enc)nfsd4_encode_access,
 	[OP_CLOSE]		= (nfsd4_enc)nfsd4_encode_close,
 	[OP_COMMIT]		= (nfsd4_enc)nfsd4_encode_commit,

