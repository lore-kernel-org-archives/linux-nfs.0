Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9897 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759160Ab0JFPPh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Oct 2010 11:15:37 -0400
Message-ID: <4CAC9299.3000706@panasas.com>
Date: Wed, 06 Oct 2010 11:15:37 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] cthon nroff general test workaround
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Newer versions of nroff spew out a warning that cause the cthon test
to fail in the following way:

Nroff
./stat: no data in nroff.time
general tests failed

The following patch filters out the warning from the output file
generated during the test.

Singed-off-by: Benny Halevy <bhalevy@panasas.com>

diff --git a/general/runtests.wrk b/general/runtests.wrk
index f3a5a4e..8247e2f 100644
--- a/general/runtests.wrk
+++ b/general/runtests.wrk
@@ -89,6 +89,8 @@ $TIME nroff < nroff.tbl > nroff.out 2>> nroff.time || cat nroff.time
 $TIME nroff < nroff.tbl > nroff.out 2>> nroff.time || cat nroff.time
 rm nroff.out nroff.tbl
 set -e
+egrep -v '^warning:.*$' <nroff.time >nroff.new
+mv -f nroff.new nroff.time
 ./stat nroff.time
 set +e
 
