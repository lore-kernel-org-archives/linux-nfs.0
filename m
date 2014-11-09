Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:46637 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaKIBPU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 20:15:20 -0500
Subject: [PATCH v2 09/10] NFS: SETCLIENTID XDR buffer sizes are incorrect
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 08 Nov 2014 20:15:18 -0500
Message-ID: <20141109011518.8806.36904.stgit@manet.1015granger.net>
In-Reply-To: <20141109010328.8806.5861.stgit@manet.1015granger.net>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the correct calculation of the maximum size of a clientaddr4
when encoding and decoding SETCLIENTID operations. clientaddr4 is
defined in section 2.2.10 of RFC3530bis-31.

The usage in encode_setclientid_maxsz is missing the 4-byte length
in both strings, but is otherwise correct. decode_setclientid_maxsz
simply asks for a page of receive buffer space, which is
unnecessarily large (more than 4KB).

Note that a SETCLIENTID reply is either clientid+verifier, or
clientaddr4, depending on the returned NFS status. It doesn't
hurt to allocate enough space for both.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4xdr.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 206c08a..f8afa67 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -141,13 +141,15 @@ static int nfs4_stat_to_errno(int);
 				XDR_QUADLEN(NFS4_VERIFIER_SIZE) + \
 				XDR_QUADLEN(NFS4_SETCLIENTID_NAMELEN) + \
 				1 /* sc_prog */ + \
-				XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
-				XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + \
+				1 + XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
+				1 + XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + \
 				1) /* sc_cb_ident */
 #define decode_setclientid_maxsz \
 				(op_decode_hdr_maxsz + \
-				2 + \
-				1024) /* large value for CLID_INUSE */
+				2 /* clientid */ + \
+				XDR_QUADLEN(NFS4_VERIFIER_SIZE) + \
+				1 + XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
+				1 + XDR_QUADLEN(RPCBIND_MAXUADDRLEN))
 #define encode_setclientid_confirm_maxsz \
 				(op_encode_hdr_maxsz + \
 				3 + (NFS4_VERIFIER_SIZE >> 2))

