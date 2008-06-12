From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 23/37] fs/nfs/nfsroot.c: remove CVS keyword
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.64731.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Adrian Bunk <bunk@kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755090AbYFLTeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:07 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>

This patch removes a CVS keyword that wasn't updated for a long time
from a comment.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfsroot.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
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

