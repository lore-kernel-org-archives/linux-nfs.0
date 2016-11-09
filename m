Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35897 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752652AbcKIWf1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 17:35:27 -0500
Received: by mail-qk0-f195.google.com with SMTP id h201so18419308qke.3
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2016 14:35:27 -0800 (PST)
Message-ID: <1478730923.24935.3.camel@poochiereds.net>
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tejun Heo <tj@kernel.org>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 09 Nov 2016 17:35:23 -0500
In-Reply-To: <20161109202359.GC4952@fieldses.org>
References: <20160830205348.GA31915@Karyakshetra>
         <20161108213911.GA27681@fieldses.org>
         <20161108225221.GB6460@htj.duckdns.org>
         <20161109012725.GA29930@fieldses.org>
         <1478697488.7930.7.camel@poochiereds.net>
         <20161109162752.GA4952@fieldses.org>
         <1478712815.7930.28.camel@poochiereds.net>
         <20161109194724.GB4952@fieldses.org> <20161109202359.GC4952@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-11-09 at 15:23 -0500, J. Bruce Fields wrote:
On Wed, Nov 09, 2016 at 02:47:24PM -0500, J. Bruce Fields wrote:

For now I wish we could just like to continue assuming the workqueue
processes only one item at a time.  Do we have that now, or do we need
to switch to (looking at workqueue.h...) alloc_ordered workqueue()?

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

That looks good to me. Eventually we could better serialize the handling
of the callback code and move to an unordered workqueue, but for now I
think Bruce is right that we have to keep it.


Reviewed-by: Jeff Layton <jlayton@redhat.com>
