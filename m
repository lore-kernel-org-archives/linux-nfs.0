Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54200 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756507AbaIOWKb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Sep 2014 18:10:31 -0400
Date: Mon, 15 Sep 2014 18:10:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/5] lockd: move lockd's grace period handling into
 its own module
Message-ID: <20140915221030.GE31157@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
 <1408473509-14010-2-git-send-email-jlayton@primarydata.com>
 <20140828200059.GB25203@fieldses.org>
 <20140828202442.GC25203@fieldses.org>
 <20140915220813.GC31157@fieldses.org>
 <20140915220939.GD31157@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140915220939.GD31157@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 15, 2014 at 06:09:39PM -0400, J. Bruce Fields wrote:
> I considered doing something like the following anyway (total
> off-the-cuff draft, not tested), but I think it's overkill.

Oh, and the one other nit here is this.

--b.

commit 24e24d2e8125d917a49b3df6a5248d6ca5c9592b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Sep 15 11:05:46 2014 -0400

    nfsd4: stop grace_time update at end of grace period
    
    The attempt to automatically set a new grace period time at the end of
    the grace period isn't really helpful.  We'll probably shut down and
    reboot before we actually make use of the new grace period time anyway.
    So may as well leave it up to the init system to get this right.
    
    This just confuses people when they see /proc/fs/nfsd/nfsv4gracetime
    change from what they set it to.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fc88b57..a298c3d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4124,12 +4124,6 @@ nfsd4_end_grace(struct nfsd_net *nn)
 	nn->grace_ended = true;
 	nfsd4_record_grace_done(nn);
 	locks_end_grace(&nn->nfsd4_manager);
-	/*
-	 * Now that every NFSv4 client has had the chance to recover and
-	 * to see the (possibly new, possibly shorter) lease time, we
-	 * can safely set the next grace time to the current lease time:
-	 */
-	nn->nfsd4_grace = nn->nfsd4_lease;
 }
 
 static time_t
