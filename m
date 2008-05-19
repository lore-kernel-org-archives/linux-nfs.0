From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] fs/nfs/nfsroot.c: remove CVS keyword
Date: Tue, 20 May 2008 01:08:00 +0300
Message-ID: <20080519220800.GQ17716@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40326 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765507AbYESWKG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 18:10:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch removes a CVS keyword that wasn't updated for a long time 
from a comment.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
b1b2f95e28139a739561c0f4257d9d36bee2d603 diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 531379d..15afe3a 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -1,6 +1,4 @@
 /*
- *  $Id: nfsroot.c,v 1.45 1998/03/07 10:44:46 mj Exp $
- *
  *  Copyright (C) 1995, 1996  Gero Kuhlmann <gero-TuicA7gkpRym5h6znurzUg@public.gmane.org>
  *
  *  Allow an NFS filesystem to be mounted as root. The way this works is:

