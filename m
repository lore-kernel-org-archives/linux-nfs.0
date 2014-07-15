Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522AbaGOPJr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:47 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 07/15] gss_log: Replace gss_log_debug with LIBTIRPC_DEBUG macros
Date: Tue, 15 Jul 2014 11:09:26 -0400
Message-Id: <1405436974-4161-8-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A couple gss_log_debug() calls are reporting errors.
To allow errors to be logged with the least amount
of debugging on, replace those calls the LIBTIRPC_DEBUG
macro

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/authgss_prot.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/src/authgss_prot.c b/src/authgss_prot.c
index 7f4a019..6dc4af6 100644
--- a/src/authgss_prot.c
+++ b/src/authgss_prot.c
@@ -178,7 +178,8 @@ xdr_rpc_gss_wrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 		maj_stat = gss_get_mic(&min_stat, ctx, qop,
 				       &databuf, &wrapbuf);
 		if (maj_stat != GSS_S_COMPLETE) {
-			gss_log_debug("gss_get_mic failed");
+			gss_log_status("xdr_rpc_gss_wrap_data: gss_get_mic", 
+				maj_stat, min_stat);
 			return (FALSE);
 		}
 		/* Marshal checksum. */
@@ -226,13 +227,13 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 	if (svc == RPCSEC_GSS_SVC_INTEGRITY) {
 		/* Decode databody_integ. */
 		if (!xdr_rpc_gss_buf(xdrs, &databuf, (u_int)-1)) {
-			gss_log_debug("xdr decode databody_integ failed");
+			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode databody_integ failed"));
 			return (FALSE);
 		}
 		/* Decode checksum. */
 		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
 			gss_release_buffer(&min_stat, &databuf);
-			gss_log_debug("xdr decode checksum failed");
+			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode checksum failed"));
 			return (FALSE);
 		}
 		/* Verify checksum and QOP. */
@@ -250,7 +251,7 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 	else if (svc == RPCSEC_GSS_SVC_PRIVACY) {
 		/* Decode databody_priv. */
 		if (!xdr_rpc_gss_buf(xdrs, &wrapbuf, (u_int)-1)) {
-			gss_log_debug("xdr decode databody_priv failed");
+			LIBTIRPC_DEBUG(1, ("xdr_rpc_gss_unwrap_data: decode databody_priv failed"));
 			return (FALSE);
 		}
 		/* Decrypt databody. */
@@ -277,7 +278,8 @@ xdr_rpc_gss_unwrap_data(XDR *xdrs, xdrproc_t xdr_func, caddr_t xdr_ptr,
 
 	/* Verify sequence number. */
 	if (xdr_stat == TRUE && seq_num != seq) {
-		gss_log_debug("wrong sequence number in databody");
+		LIBTIRPC_DEBUG(1, 
+			("xdr_rpc_gss_unwrap_data: wrong sequence number in databody"));
 		return (FALSE);
 	}
 	return (xdr_stat);
-- 
1.9.3

