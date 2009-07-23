From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] include des_crypt in build
Date: Wed, 22 Jul 2009 23:05:26 -0400
Message-ID: <1248318326-16734-2-git-send-email-vapier@gentoo.org>
References: <1248318326-16734-1-git-send-email-vapier@gentoo.org>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:55628 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086AbZGWDFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2009 23:05:37 -0400
In-Reply-To: <1248318326-16734-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some C libraries (like glibc) provide cbc_crypt and ecb_crypt and friends,
but others may not.  So build the local des_crypt.c file that is already
in libtirpc.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 src/Makefile.am |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/src/Makefile.am b/src/Makefile.am
index 7b002da..ee8d355 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -50,7 +50,7 @@ libtirpc_la_SOURCES = auth_none.c auth_unix.c authunix_prot.c bindresvport.c cln
         rpc_callmsg.c rpc_generic.c rpc_soc.c rpcb_clnt.c rpcb_prot.c \
         rpcb_st_xdr.c svc.c svc_auth.c svc_dg.c svc_auth_unix.c svc_generic.c \
         svc_raw.c svc_run.c svc_simple.c svc_vc.c getpeereid.c \
-        auth_time.c auth_des.c authdes_prot.c
+        auth_time.c auth_des.c authdes_prot.c des_crypt.c
 
 ## XDR
 libtirpc_la_SOURCES += xdr.c xdr_rec.c xdr_array.c xdr_float.c xdr_mem.c xdr_reference.c xdr_stdio.c
-- 
1.6.3.3

