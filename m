From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Mon, 27 Oct 2008 11:48:23 -0400
Message-ID: <1225122503.14242.12.camel@heimdal.trondhjem.org>
References: <20081022091207.GA12996@squirrel.roonstrasse.net>
	 <20081023123628.GA18549@squirrel.roonstrasse.net>
	 <1224773745.7625.4.camel@localhost>
	 <20081024083913.GA15197@squirrel.roonstrasse.net>
	 <1224871763.22672.33.camel@localhost>
	 <20081027095843.GA10937@squirrel.roonstrasse.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48061 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbYJ0Ps2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Oct 2008 11:48:28 -0400
In-Reply-To: <20081027095843.GA10937-2pNSKKP3PSJxEiad3KpGLI/oZP4lHnOC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-10-27 at 10:58 +0100, Max Kellermann wrote:
> On 2008/10/24 20:09, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > OK, could you please describe your environment a bit. Do you have lots
> > of different users logged in at the same time, or do you perhaps use
> > newgrp or su to switch uid/gids a lot on your processes?
> > I'm trying to see if there might be a reason for the lookup in the
> > credcache being such a heavy duty operation in your setup.
> 
> It's a web server for shared hosting.  The web space is mounted via
> NFSv3 from a NetApp.  There is a huge number of web sites on this
> cluster.  All web sites are owned by the same UID, and the web server
> runs as a different UID (read-only access).
> 
> Each time a CGI starts, its uid is changed to the one "owner" UID
> (similar to mod_suexec, but there's only one UID for all customer
> accounts).  Each time a CGI starts, its chroot (pivot_root) is
> constructed with several bind mounts (in a separate namespace with
> CLONE_NEWNS).
> 
> There are no new users or groups being created.  There are only 2 UIDs
> accessing NFS: the webserver (ro) and CGI (rw).

OK. That points a finger at the garbage collector. Does the following
patch help at all?

Cheers
  Trond
------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Mon, 27 Oct 2008 11:43:48 -0400
SUNRPC: Fix rpcauth_prune_expired

We need to make sure that we don't remove creds from the cred_unused list
if they are still under the moratorium, or else they will never get
garbage collected.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)


diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 436bf1b..a045a12 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -228,19 +228,21 @@ static int
 rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 {
 	spinlock_t *cache_lock;
-	struct rpc_cred *cred;
+	struct rpc_cred *cred, *next;
 	unsigned long expired = jiffies - RPC_AUTH_EXPIRY_MORATORIUM;
 
-	while (!list_empty(&cred_unused)) {
-		cred = list_entry(cred_unused.next, struct rpc_cred, cr_lru);
+	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
+
+		/* Enforce a 60 second garbage collection moratorium */
+		if (time_in_range(cred->cr_expire, expired, jiffies) &&
+		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
+			continue;
+
 		list_del_init(&cred->cr_lru);
 		number_cred_unused--;
 		if (atomic_read(&cred->cr_count) != 0)
 			continue;
-		/* Enforce a 5 second garbage collection moratorium */
-		if (time_in_range(cred->cr_expire, expired, jiffies) &&
-		    test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0)
-			continue;
+
 		cache_lock = &cred->cr_auth->au_credcache->lock;
 		spin_lock(cache_lock);
 		if (atomic_read(&cred->cr_count) == 0) {


