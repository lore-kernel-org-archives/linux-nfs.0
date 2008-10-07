From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/30] fix fs/nfs/nfsroot.c compilation
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.66202.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Adrian Bunk <bunk@kernel.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754905AbYJGWcr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:47 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>

This patch fixes the following compile error caused by
commit f9247273cb69ba101877e946d2d83044409cc8c5
(UFS: add const to parser token tabl):

<--  snip  -->

...
  CC      fs/nfs/nfsroot.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/fs/nfs/nfsroot.c:130: error: tokens causes a section type conflict
make[3]: *** [fs/nfs/nfsroot.o] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfsroot.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 46763d1..8478fc2 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -127,7 +127,7 @@ enum {
 	Opt_err
 };
 
-static match_table_t __initdata tokens = {
+static match_table_t __initconst tokens = {
 	{Opt_port, "port=%u"},
 	{Opt_rsize, "rsize=%u"},
 	{Opt_wsize, "wsize=%u"},

