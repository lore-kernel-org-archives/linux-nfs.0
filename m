Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45648 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756102Ab2HTW4u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 18:56:50 -0400
Date: Mon, 20 Aug 2012 18:56:43 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: minor nfsd cleanups
Message-ID: <20120820225643.GA8960@fieldses.org>
References: <1345503060-8892-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1345503060-8892-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 20, 2012 at 06:50:57PM -0400, J. Bruce Fields wrote:
> Three patches for 3.7, mainly just shutting up sparse.--b.

Plus one more I forgot....--b.

commit 3a6d5cded2bcb69e259e18e23474ae0c1767fc04
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Aug 14 16:09:31 2012 -0400

    nfsd4: nfsd_process_n_delegations should be static
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 566a9b7..f393da8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4578,7 +4578,7 @@ void nfsd_forget_openowners(u64 num)
 	printk(KERN_INFO "NFSD: Forgot %d open owners", count);
 }
 
-int nfsd_process_n_delegations(u64 num, struct list_head *list)
+static int nfsd_process_n_delegations(u64 num, struct list_head *list)
 {
 	int i, count = 0;
 	struct nfs4_file *fp, *fnext;
