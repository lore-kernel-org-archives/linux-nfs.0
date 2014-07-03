Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:58160 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbaGCWbS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 18:31:18 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so849117qcv.12
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 15:31:17 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 3 Jul 2014 18:31:15 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
Message-ID: <20140703183115.397af08e@tlielax.poochiereds.net>
In-Reply-To: <20140703213526.GG24322@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-16-git-send-email-jlayton@primarydata.com>
	<20140703203259.GF24322@fieldses.org>
	<20140703213526.GG24322@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/iruD5j=mZKYdaAoNrcG09TZ"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/iruD5j=mZKYdaAoNrcG09TZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thu, 3 Jul 2014 17:35:26 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jul 03, 2014 at 04:32:59PM -0400, J. Bruce Fields wrote:
> > On Mon, Jun 30, 2014 at 11:48:44AM -0400, Jeff Layton wrote:
> > > We want to use the nfsd4_compound_state to cache the nfs4_client in
> > > order to optimise away extra lookups of the clid.
> > > 
> > > In the v4.0 case, we use this to ensure that we only have to look up the
> > > client at most once per compound for each call into lookup_clientid. For
> > > v4.1+ we set the pointer in the cstate during SEQUENCE processing so we
> > > should never need to do a search for it.
> > 
> > The connectathon locking test is failing for me in the nfsv4/krb5i case
> > as of this commit.
> > 
> > Which makes no sense to me whatsoever, so it's entirely possible this is
> > some unrelated problem on my side.  I'll let you know when I've figured
> > out anything more.
> 
> It's intermittent.
> 
> I've reproduced it on the previous commit so I know at least that this
> one isn't at fault.
> 
> I doubt it's really dependent on krb5i, at most that's probably just
> making it more likely to reproduce.
> 
> --b.

Bruce,

Does this patch help? I suspect this is where the bug crept in, but I'm
unclear on why it would be intermittent...

FWIW, this all gets cleaned up in a later patch that changes how the
refcounting on lock and openowners works.

-- 
Jeff Layton <jlayton@primarydata.com>

--MP_/iruD5j=mZKYdaAoNrcG09TZ
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-nfsd-fix-lock-stateid-cleanup-on-error-in-nfsd4_lock.patch

>From 84884320b983eaeb68c652de8fe4b48aad4052c3 Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@primarydata.com>
Date: Thu, 3 Jul 2014 18:20:31 -0400
Subject: [PATCH] nfsd: fix lock stateid cleanup on error in nfsd4_lock

commit 43a1b041e3b changed nfsd4_lock to call release_lockowner_if_empty
if the the lock stateid was new and the function was going to return an
error.

This is wrong. The lockowner will never be empty in that situation since
it still has the new lock stateid attached to it. Change it to call
release_lock_stateid instead, which will destroy the lock stateid and
then release the lockowner if it's empty at that point.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Reported-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a22c73f14a17..b2ea0a06fbf2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4600,7 +4600,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 out:
 	if (status && new_state)
-		release_lockowner_if_empty(lock_sop);
+		release_lock_stateid(lock_stp);
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
-- 
1.9.3


--MP_/iruD5j=mZKYdaAoNrcG09TZ--
