Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:37523 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753484AbaFWQ6P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 12:58:15 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 23 Jun 2014 12:58:15 -0400
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id F4016C90041
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 12:58:06 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5NGwDtm47251468
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 16:58:13 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5NGwCff006551
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 12:58:12 -0400
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org
Subject: [PATCH 2/2] Open files with OPEN4_SHARE_DENY_NONE for DELEG5 test
Date: Mon, 23 Jun 2014 11:57:42 -0500
Message-Id: <1403542662-8450-2-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1403542662-8450-1-git-send-email-malahal@us.ibm.com>
References: <1403542662-8450-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DELEG5 test, while getting the READ delegation, uses
OPEN4_SHARE_DENY_WRITE as that is the default. Pass
OPEN4_SHARE_DENY_NONE explicitly as that is assumed
in the test.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 nfs4.0/servertests/st_delegation.py | 1 +
 1 file changed, 1 insertion(+)

diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
index 4da3a7a..eaff326 100644
--- a/nfs4.0/servertests/st_delegation.py
+++ b/nfs4.0/servertests/st_delegation.py
@@ -249,6 +249,7 @@ def testManyReaddeleg(t, env, funct=_recall, response=NFS4_OK):
             
         # Get a read delegation
         res = c.open_file(t.code, access=OPEN4_SHARE_ACCESS_READ,
+                          deny=OPEN4_SHARE_DENY_NONE,
                           set_recall=True,
                           recall_funct=funct, recall_return=response)
         fh, stateid = c.confirm(t.code, res)
-- 
1.8.3.1

