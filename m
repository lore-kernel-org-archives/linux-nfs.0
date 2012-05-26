Return-Path: linux-nfs-owner@vger.kernel.org
Received: from april.london.02.net ([87.194.255.143]:58033 "EHLO
	april.london.02.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190Ab2EZVkj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 May 2012 17:40:39 -0400
Received: from cartman.offog.org (94.194.126.16) by april.london.02.net (8.5.140)
        id 4F728CFB015B42F2 for linux-nfs@vger.kernel.org; Sat, 26 May 2012 22:32:14 +0100
Received: from ats by cartman.offog.org with local (Exim 4.77)
	(envelope-from <ats@offog.org>)
	id 1SYOas-0004RP-9H
	for linux-nfs@vger.kernel.org; Sat, 26 May 2012 22:32:14 +0100
Date: Sat, 26 May 2012 22:32:14 +0100
From: Adam Sampson <ats@offog.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils 1.2.6: nsm_client needs to link with libtirpc
Message-ID: <20120526213213.GY25787@cartman.at.offog.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nsm_client needs to link against libtirpc.

diff -x config.log -x config.status -ru tmp/nfs-utils-1.2.6/tests/nsm_client/Makefile.am work/nfs-utils-1.2.6/tests/nsm_client/Makefile.am
--- tmp/nfs-utils-1.2.6/tests/nsm_client/Makefile.am	2012-05-14 15:40:52.000000000 +0100
+++ work/nfs-utils-1.2.6/tests/nsm_client/Makefile.am	2012-05-26 22:18:50.999001661 +0100
@@ -13,7 +13,7 @@
 
 BUILT_SOURCES = $(GENFILES)
 nsm_client_LDADD = ../../support/nfs/libnfs.a \
-		   ../../support/nsm/libnsm.a $(LIBCAP)
+		   ../../support/nsm/libnsm.a $(LIBCAP) $(LIBTIRPC)
 
 if CONFIG_RPCGEN
 RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen

-- 
Adam Sampson <ats@offog.org>                         <http://offog.org/>
