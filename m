Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54024 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759266Ab0EMQLu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 May 2010 12:11:50 -0400
Date: Thu, 13 May 2010 12:11:49 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 8/9] nfsd4: keep a reference count on client while
	in use
Message-ID: <20100513161149.GA25327@fieldses.org>
References: <4BE9C7A2.8030801@panasas.com> <1273612434-13726-1-git-send-email-bhalevy@panasas.com> <20100512024030.GA27184@fieldses.org> <4BEA2E06.7070902@panasas.com> <4BEA4876.3030802@panasas.com> <20100512222946.GE11389@fieldses.org> <4BEC0E5F.2030608@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BEC0E5F.2030608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 13, 2010 at 05:36:15PM +0300, Benny Halevy wrote:
> On May. 13, 2010, 1:29 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > Another case:
> > 
> > 	- Two 4.1 compounds arrive, both their sequence operations are
> > 	  processed.
> > 	- Independently, an exchange_id expires the client.
> > 	- At this point, the reference count is 2.
> > 	- One of the original compounds completes.  It renews the client
> > 	  (because it hits reference count 1).
> 
> and that will be a no-op as the client is marked as expired.

Pfft, apologies, and thanks for setting me straight again.  Still, the
existing scheme seems slightly more complicated than necessary.

> 
> > 	- The second of the two original compounds completes.  It frees
> > 	  the client.
> 
> right
> 
> > 
> > I guess there's nothing fundamentally wrong with that, but it's a little
> > odd.
> > 
> > Wouldn't it be more straightforward to let cl_refcount be a count of the
> > number of outstanding compounds, and make release_session_client do:
> > 
> > 	if cl_refcount >= 0
> > 		return;
> > 	if (client_is_expired(clp))
> > 		free client;
> > 	else
> > 		renew client;
> > 
> > ?
> > 
> > The following works for me. If you don't see any objection, I'll squash
> > this in and push out the result.
> 
> No objection, looks good. Thanks!

OK, thanks!

I notice I didn't do exactly what I said I would, though; with the
following change on top I think it's right.

I'll test that and then push out the result.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 05ad0ae..84b0fe9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -765,7 +765,7 @@ expire_client(struct nfs4_client *clp)
 	list_del(&clp->cl_strhash);
 	spin_lock(&client_lock);
 	unhash_client_locked(clp);
-	if (atomic_dec_and_test(&clp->cl_refcount))
+	if (atomic_read(&clp->cl_refcount) == 0)
 		free_client(clp);
 	spin_unlock(&client_lock);
 }
@@ -853,7 +853,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	}
 
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
-	atomic_set(&clp->cl_refcount, 1);
+	atomic_set(&clp->cl_refcount, 0);
 	atomic_set(&clp->cl_cb_set, 0);
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
