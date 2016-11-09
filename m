Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39718 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751677AbcKIUYB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Nov 2016 15:24:01 -0500
Date: Wed, 9 Nov 2016 15:23:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Tejun Heo <tj@kernel.org>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
Message-ID: <20161109202359.GC4952@fieldses.org>
References: <20160830205348.GA31915@Karyakshetra>
 <20161108213911.GA27681@fieldses.org>
 <20161108225221.GB6460@htj.duckdns.org>
 <20161109012725.GA29930@fieldses.org>
 <1478697488.7930.7.camel@poochiereds.net>
 <20161109162752.GA4952@fieldses.org>
 <1478712815.7930.28.camel@poochiereds.net>
 <20161109194724.GB4952@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161109194724.GB4952@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 09, 2016 at 02:47:24PM -0500, J. Bruce Fields wrote:
> For now I wish we could just like to continue assuming the workqueue
> processes only one item at a time.  Do we have that now, or do we need
> to switch to (looking at workqueue.h...) alloc_ordered workqueue()?

Oh, wait, I missed the _ordered_ in:

	#define create_singlethread_workqueue(name) \
	        alloc_ordered_workqueue("%s", __WQ_LEGACY | WQ_MEM_RECLAIM, name)

So our existing create_singlethread_workqueue is fine--but we probably
don't need those flags:

--b.

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 211dc2aed8e1..eb78109d666c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1061,7 +1061,7 @@ static const struct rpc_call_ops nfsd4_cb_ops = {
 
 int nfsd4_create_callback_queue(void)
 {
-	callback_wq = create_singlethread_workqueue("nfsd4_callbacks");
+	callback_wq = alloc_ordered_workqueue("nfsd4_callbacks", 0);
 	if (!callback_wq)
 		return -ENOMEM;
 	return 0;
