Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754821AbbLPQzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 11:55:06 -0500
Date: Wed, 16 Dec 2015 11:55:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, Kinglong Mee <kinglongmee@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151216165503.GC5491@fieldses.org>
References: <20151130193313.5bb10791@synchrony.poochiereds.net>
 <20151201115600.GA1557@lst.de>
 <20151201174800.407e2c40@synchrony.poochiereds.net>
 <20151202072504.GA15839@lst.de>
 <20151203220850.GC19518@fieldses.org>
 <20151204083803.GA2440@lst.de>
 <20151204155110.64a352dd@tlielax.poochiereds.net>
 <20151205120222.GA27009@lst.de>
 <20151205072409.46d66109@tlielax.poochiereds.net>
 <20151206080954.1fe7e5c9@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151206080954.1fe7e5c9@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 06, 2015 at 08:09:54AM -0500, Jeff Layton wrote:
> On Sat, 5 Dec 2015 07:24:09 -0500
> Jeff Layton <jlayton@poochiereds.net> wrote:
> 
> > On Sat, 5 Dec 2015 13:02:22 +0100
> > Christoph Hellwig <hch@lst.de> wrote:
> > 
> > > On Fri, Dec 04, 2015 at 03:51:10PM -0500, Jeff Layton wrote:
> > > > > There is no reason not to do it, except for the significant effort
> > > > > to implement it a well as a synthetic test case to actually reproduce
> > > > > the behavior we want to handle.
> > > > 
> > > > Could you end up livelocking here? Suppose you issue the callback and
> > > > the client returns success. He then returns the layout and gets a new
> > > > one just before the delay timer pops. We then end up recalling _that_
> > > > layout...rinse, repeat...
> > > 
> > > If we start allowing layoutgets before the whole range has been
> > > returned there is a great chance for livelocks, yes.  But I don't think
> > > we should allow layoutgets to proceed before that.
> > 
> > Maybe I didn't describe it well enough. I think you can still end up
> > looping even if you don't allow LAYOUTGETs before the entire range is
> > returned.
> > 
> > If we treat NFS4_OK and NFS4ERR_DELAY equivalently, then we're
> > expecting the client to eventually return NFS4ERR_NOMATCHING_LAYOUT (or
> > a different error) to break the cycle of retransmissions. But, HZ/100
> > is enough time for the client to return a layout and request a new one.
> > We may never see that error -- only a continual cycle of
> > CB_LAYOUTRECALL/LAYOUTRETURN/LAYOUTGET.
> > 
> > I think we need a more reliable way to break that cycle so we don't end
> > up looping like that. We should either cancel any active callbacks
> > before reallowing LAYOUTGETs, or move the timeout handling outside of
> > the RPC state machine (like Bruce was suggesting).
> > 
> 
> Either way...in the near term we should probably take the patch that I
> originally proposed, just to ensure that no one hits the bugs that
> Kinglong hit. That does still leave some gaps in the seqid handling,
> but those are preferable to the warning and deadlock.
> 
> Bruce, does that sound reasonable?

Yes, I think I'll just apply the below (your patch with a couple extra
sentences in the changelog), and pass that along for 4.4 soon.

--b.

commit be20aa00c671
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Sun Nov 29 08:46:14 2015 -0500

    nfsd: don't hold ls_mutex across a layout recall
    
    We do need to serialize layout stateid morphing operations, but we
    currently hold the ls_mutex across a layout recall which is pretty
    ugly. It's also unnecessary -- once we've bumped the seqid and
    copied it, we don't need to serialize the rest of the CB_LAYOUTRECALL
    vs. anything else. Just drop the mutex once the copy is done.
    
    This was causing a "workqueue leaked lock or atomic" warning and an
    occasional deadlock.
    
    There's more work to be done here but this fixes the immediate
    regression.
    
    Fixes: cc8a55320b5f "nfsd: serialize layout stateid morphing operations"
    Cc: stable@vger.kernel.org
    Reported-by: Kinglong Mee <kinglongmee@gmail.com>
    Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 9ffef06b30d5..c9d6c715c0fb 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -616,6 +616,7 @@ nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
 
 	mutex_lock(&ls->ls_mutex);
 	nfs4_inc_and_copy_stateid(&ls->ls_recall_sid, &ls->ls_stid);
+	mutex_unlock(&ls->ls_mutex);
 }
 
 static int
@@ -659,7 +660,6 @@ nfsd4_cb_layout_release(struct nfsd4_callback *cb)
 
 	trace_layout_recall_release(&ls->ls_stid.sc_stateid);
 
-	mutex_unlock(&ls->ls_mutex);
 	nfsd4_return_all_layouts(ls, &reaplist);
 	nfsd4_free_layouts(&reaplist);
 	nfs4_put_stid(&ls->ls_stid);
