Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:36152 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751857Ab0KDRcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 13:32:35 -0400
Date: Thu, 4 Nov 2010 13:32:33 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] add blkmapd and spnfsd to list of build targets to ignore
Message-ID: <20101104173233.GA1681@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 .gitignore |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index 4bff9e3..6530ae0 100644
--- a/.gitignore
+++ b/.gitignore
@@ -36,6 +36,7 @@ support/include/stamp-h1
 lib*.a
 tools/rpcgen/rpcgen
 tools/rpcdebug/rpcdebug
+utils/blkmapd/blkmapd
 utils/exportfs/exportfs
 utils/idmapd/idmapd
 utils/lockd/lockd
@@ -48,6 +49,7 @@ utils/rquotad/rquotad
 utils/rquotad/rquota.h
 utils/rquotad/rquota_xdr.c
 utils/showmount/showmount
+utils/spnfsd/spnfsd
 utils/statd/statd
 tools/locktest/testlk
 tools/getiversion/getiversion
-- 
1.7.1

