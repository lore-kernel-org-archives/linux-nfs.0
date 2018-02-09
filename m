Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50572 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751070AbeBIPup (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Feb 2018 10:50:45 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EB9013F738
        for <linux-nfs@vger.kernel.org>; Fri,  9 Feb 2018 15:50:44 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-113.phx2.redhat.com [10.3.116.113])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A6F11608F9
        for <linux-nfs@vger.kernel.org>; Fri,  9 Feb 2018 15:50:44 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Remove warnings from rpcgen generated files
Date: Fri,  9 Feb 2018 10:50:42 -0500
Message-Id: <20180209155042.28461-2-steved@redhat.com>
In-Reply-To: <20180209155042.28461-1-steved@redhat.com>
References: <20180209155042.28461-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The xdr c-files, generated from .x by rpcgen, in both
libnsm.a and libexport.a libraries cause the
following warnings:

mount_xdr.c:43:20: warning: unused variable 'buf' [-Wunused-variable]
sm_inter_xdr.c:37:20: warning: unused variable 'buf' [-Wunused-variable]
sm_inter_xdr.c:51:6: warning: unused variable 'i' [-Wunused-variable]

These warnings are caused by rpcgen trying in inline
the xdr routines. It turns out no inlining was happening,
except for one routine. So turning off inlining eliminated
these warnings.

This patch also eliminates a Werror missing-prototypes in sm_inter.h

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/export/Makefile.am | 2 +-
 support/nsm/Makefile.am    | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/support/export/Makefile.am b/support/export/Makefile.am
index be3de69..13f7a49 100644
--- a/support/export/Makefile.am
+++ b/support/export/Makefile.am
@@ -35,7 +35,7 @@ $(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
 
 $(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
 	test -f $@ && rm -rf $@ || true
-	$(RPCGEN) -c -o $@ $<
+	$(RPCGEN) -c -i 0 -o $@ $<
 
 $(GENFILES_H): %.h: %.x $(RPCGEN)
 	test -f $@ && rm -rf $@ || true
diff --git a/support/nsm/Makefile.am b/support/nsm/Makefile.am
index 2038e68..8f5874e 100644
--- a/support/nsm/Makefile.am
+++ b/support/nsm/Makefile.am
@@ -32,11 +32,12 @@ $(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
 
 $(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
 	test -f $@ && rm -rf $@ || true
-	$(RPCGEN) -c -o $@ $<
+	$(RPCGEN) -c -i 0 -o $@ $<
 
 $(GENFILES_H): %.h: %.x $(RPCGEN)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -h -o $@ $<
+	echo "void sm_prog_1(struct svc_req *, SVCXPRT *);" >> $@
 	rm -f $(top_builddir)/support/include/sm_inter.h
 	$(LN_S) ../nsm/sm_inter.h $(top_builddir)/support/include/sm_inter.h
 
-- 
2.14.3

