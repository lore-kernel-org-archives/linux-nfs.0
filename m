Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42824 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573AbbCWPgP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Mar 2015 11:36:15 -0400
Date: Mon, 23 Mar 2015 11:36:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfsd: return correct openowner when there is a race
 to put one in the hash
Message-ID: <20150323153614.GB15183@fieldses.org>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
 <1427122424-8078-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427122424-8078-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 23, 2015 at 10:53:42AM -0400, Jeff Layton wrote:
> alloc_init_open_stateowner can return an already freed entry if there is
> a race to put openowners in the hashtable.

Looks like alloc_init_lock_stateowner has the same bug, so I'll apply
something like this pending testing.

I wonder if it's actually possible to hit this one?

--b.

commit bdff3084f09f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Mar 23 11:02:30 2015 -0400

    nfsd: return correct lockowner when there is a race on hash insert
    
    alloc_init_lock_stateowner can return an already freed entry if there is
    a race to put openowners in the hashtable.
    
    Noticed by inspection after Jeff Layton fixed the same bug for open
    owners.  Depending on client behavior, this one may be trickier to
    trigger in practice.
    
    Fixes: c58c6610ec24 "nfsd: Protect adding/removing lock owners using client_lock"
    Cc: stable@vger.kernel.org>
    Cc: Trond Myklebust <trond.myklebust@primarydata.com>
    Cc: Jeff Layton <jeff.layton@primarydata.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d2f2c37dc2db..49ae6116992f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5062,7 +5062,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
 	} else
 		nfs4_free_lockowner(&lo->lo_owner);
 	spin_unlock(&clp->cl_lock);
-	return lo;
+	return ret;
 }
 
 static void
