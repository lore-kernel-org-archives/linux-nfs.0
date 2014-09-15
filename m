Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56845 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755161AbaIOWJk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Sep 2014 18:09:40 -0400
Date: Mon, 15 Sep 2014 18:09:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/5] lockd: move lockd's grace period handling into
 its own module
Message-ID: <20140915220939.GD31157@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
 <1408473509-14010-2-git-send-email-jlayton@primarydata.com>
 <20140828200059.GB25203@fieldses.org>
 <20140828202442.GC25203@fieldses.org>
 <20140915220813.GC31157@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140915220813.GC31157@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 15, 2014 at 06:08:13PM -0400, J. Bruce Fields wrote:
> On Thu, Aug 28, 2014 at 04:24:43PM -0400, J. Bruce Fields wrote:
> > On Thu, Aug 28, 2014 at 04:01:00PM -0400, J. Bruce Fields wrote:
> > > On Tue, Aug 19, 2014 at 02:38:25PM -0400, Jeff Layton wrote:
> > > > Currently, all of the grace period handling is part of lockd. Eventually
> > > > though we'd like to be able to build v4-only servers, at which point
> > > > we'll need to put all of this elsewhere.
> > > > 
> > > > Move the code itself into fs/nfs_common and have it build a grace.ko
> > > > module. Then, rejigger the Kconfig options so that both nfsd and lockd
> > > > enable it automatically.
> > > 
> > > Thanks, applying this one for 3.18 indepedently of the others.
> > 
> > This code should also be fixed, though.
> > 
> > Currently nfsd is recording the grace period as done when its own timer
> > runs out, but then it continuing to accept reclaims until lockd is also
> > done.
> 
> I sat down to fix this today then decided there's not a real bug:
> 
> All the grace_done upcall really does is throw away any previous clients
> that haven't reclaimed yet.
> 
> It's legal to do that as soon as the correct amount of time has passed.
> It's actually OK to continue to allow the grace period to run past that
> point, the only requirement is that all reclaims precede all new opens,
> which the code still does enforce.
> 
> So I think it might just be worth a little extra explanation.

I considered doing something like the following anyway (total
off-the-cuff draft, not tested), but I think it's overkill.

--b.

commit 675121da48fb4d7d85b58467c7f79dd3a6964879
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Sep 15 17:42:14 2014 -0400

    nfsd4: end grace only when last grace period ends
    
    In the case both lockd and nfsd4 are running, or when we have multiple
    containers exporting the same filesystem, there may be multiple grace
    periods.  In that case the grace period doesn't really end till the last
    one does and though it's harmless to do the grace_done upcall before
    then, it would probably be better not to.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfs_common/grace.c b/fs/nfs_common/grace.c
index ae6e58e..dc67e5d 100644
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -12,6 +12,11 @@
 static int grace_net_id;
 static DEFINE_SPINLOCK(grace_lock);
 
+struct grace_net {
+	struct list_head *grace_list;
+	bool in_grace;
+};
+
 /**
  * locks_start_grace
  * @net: net namespace that this lock manager belongs to
@@ -27,10 +32,10 @@ static DEFINE_SPINLOCK(grace_lock);
 void
 locks_start_grace(struct net *net, struct lock_manager *lm)
 {
-	struct list_head *grace_list = net_generic(net, grace_net_id);
+	struct list_head *gn = net_generic(net, grace_net_id);
 
 	spin_lock(&grace_lock);
-	list_add(&lm->list, grace_list);
+	list_add(&lm->list, &gn->grace_list);
 	spin_unlock(&grace_lock);
 }
 EXPORT_SYMBOL_GPL(locks_start_grace);
@@ -49,9 +54,31 @@ EXPORT_SYMBOL_GPL(locks_start_grace);
 void
 locks_end_grace(struct lock_manager *lm)
 {
+	struct list_head *gn = net_generic(net, grace_net_id);
+
+	if (list_empty(&lm->list))
+		return;
 	spin_lock(&grace_lock);
 	list_del_init(&lm->list);
 	spin_unlock(&grace_lock);
+	if (list_empty(&gn->grace_list))
+		return;
+	/*
+	 * If the server goes down again right now, an NFSv4
+	 * client will still be reclaim after it comes back up, even if
+	 * it hasn't yet had a chance to reclaim state this time.
+	 */
+	lm->finish_grace(lm);
+	/*
+	 * At this point, NFSv4 clients can still reclaim.  But if the
+	 * server crashes, any that have not yet reclaimed will be out
+	 * of luck on the next boot.
+	 */
+	ln->in_grace = false;
+	/*
+	 * At this point, no reclaims are permitted.  Regular locking
+	 * can resume.
+	 */
 }
 EXPORT_SYMBOL_GPL(locks_end_grace);
 
@@ -65,27 +92,28 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
 int
 locks_in_grace(struct net *net)
 {
-	struct list_head *grace_list = net_generic(net, grace_net_id);
+	struct list_head *gn = net_generic(net, grace_net_id);
 
-	return !list_empty(grace_list);
+	return gn->in_grace;
 }
 EXPORT_SYMBOL_GPL(locks_in_grace);
 
 static int __net_init
 grace_init_net(struct net *net)
 {
-	struct list_head *grace_list = net_generic(net, grace_net_id);
+	struct list_head *gn = net_generic(net, grace_net_id);
 
-	INIT_LIST_HEAD(grace_list);
+	INIT_LIST_HEAD(&gn->grace_list);
+	gn->in_grace = true;
 	return 0;
 }
 
 static void __net_exit
 grace_exit_net(struct net *net)
 {
-	struct list_head *grace_list = net_generic(net, grace_net_id);
+	struct list_head *gn = net_generic(net, grace_net_id);
 
-	BUG_ON(!list_empty(grace_list));
+	BUG_ON(!list_empty(&gn->grace_list));
 }
 
 static struct pernet_operations grace_net_ops = {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fc88b57..968acd0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4122,7 +4122,6 @@ nfsd4_end_grace(struct nfsd_net *nn)
 
 	dprintk("NFSD: end of grace period\n");
 	nn->grace_ended = true;
-	nfsd4_record_grace_done(nn);
 	locks_end_grace(&nn->nfsd4_manager);
 	/*
 	 * Now that every NFSv4 client has had the chance to recover and
@@ -6341,6 +6340,13 @@ nfs4_state_destroy_net(struct net *net)
 	put_net(net);
 }
 
+void nfsd4_finish_grace(struct lock_manager *lm)
+{
+	struct nfsd_net *nn = lm->private;
+
+	nfsd4_record_grace_done(nn);
+}
+
 int
 nfs4_state_start_net(struct net *net)
 {
@@ -6352,6 +6358,8 @@ nfs4_state_start_net(struct net *net)
 		return ret;
 	nn->boot_time = get_seconds();
 	nn->grace_ended = false;
+	nn->nfsd4_manager.finish_grace = nfsd4_finish_grace;
+	nn->nfsd4_manager.private = nn;
 	locks_start_grace(net, &nn->nfsd4_manager);
 	nfsd4_client_tracking_init(net);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9418772..0e33e7c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -876,6 +876,8 @@ struct lock_manager_operations {
 
 struct lock_manager {
 	struct list_head list;
+	void (*finish_grace)(struct lock_manager *lm);
+	void *private;
 };
 
 struct net;
