Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46838 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403Ab0HFV26 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 17:28:58 -0400
Date: Fri, 6 Aug 2010 17:27:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Message-ID: <20100806212727.GC29536@fieldses.org>
References: <20100802103214.7eea09eb@corrin.poochiereds.net>
 <20100802103620.5638dac1@corrin.poochiereds.net>
 <20100802181634.GD12637@fieldses.org>
 <201008030109.o73193bp094241@www262.sakura.ne.jp>
 <20100803154851.GA23467@fieldses.org>
 <201008040013.o740DmYK024832@www262.sakura.ne.jp>
 <20100804194045.GD18200@fieldses.org>
 <201008050110.o751AG18066496@www262.sakura.ne.jp>
 <20100805204612.GA13821@fieldses.org>
 <20100805213107.GB13821@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100805213107.GB13821@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 05, 2010 at 05:31:07PM -0400, J. Bruce Fields wrote:
> On Thu, Aug 05, 2010 at 04:46:12PM -0400, J. Bruce Fields wrote:
> > On Thu, Aug 05, 2010 at 10:10:16AM +0900, Tetsuo Handa wrote:
> > > J. Bruce Fields wrote:
> > > > Maybe figuring out exactly hwere that is would help work out what's
> > > > going on.  Doing
> > > > 
> > > > 	make net/sunrpc/svc.lst
> > > > 
> > > > then looking for c1356dd4 (or just mailing me svc.lst) could help.
> > > 
> > > "make net/sunrpc/svc.lst" failed due to following error.
> > > 
> > >   BFD: Dwarf Error: Abbrev offset (3238007024) greater than or equal to .debug_abbrev size (1607).
> > > 
> > > Manual printk() debug reported that
> > > rqstp->rq_argp == rqstp->rq_resp == ZERO_SIZE_PTR and
> > 
> > Huh.  As far as I can tell that will only happen if you've not no nfsd
> > versions defined; how is that happening?
> 
> OK, I think it's another startup-order problem: depending on how things
> are started up, sv_nrthreads may already be nonzero, causing us to skip
> nfsd_reset_versions(), so that the loop in __svc_create() ends up
> leaving xdrsize 0, and then the kmalloc's in svc_prepare_thread() assign
> ZERO_SIZE_PTR.
> 
> I need to think a little more about what we should be doing here.

Bah, so what you were hitting was simple--I just moved the
nfsd_reset_versions() call to the wrong place; the below should fix it.

There's also a couple other bugs in the area.

Thanks for the -next testing!

--b.

commit e844a7b9805a2b74cfd34c8604f5bba3e0869305
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Aug 6 15:48:03 2010 -0400

    nfsd: initialize nfsd versions before creating svc
    
    Commit 59db4a0c102e0de226a3395dbf25ea51bf845937 "nfsd: move more into
    nfsd_startup()" inadvertently moved nfsd_versions after
    nfsd_create_svc().  On older distributions using an rpc.nfsd that does
    not explicitly set the list of nfsd versions, this results in
    svc-create_pooled() being called with an empty versions array.  The
    resulting incomplete initialization leads to a NULL dereference in
    svc_process_common() the first time a client accesses the server.
    
    Move nfsd_reset_versions() back before the svc_create_pooled(); this
    time, put it closer to the svc_create_pooled() call, to make this
    mistake more difficult in the future.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 39ced4a..e2c4346 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -224,7 +224,6 @@ static int nfsd_startup(unsigned short port, int nrservs)
 	ret = nfs4_state_start();
 	if (ret)
 		goto out_lockd;
-	nfsd_reset_versions();
 	nfsd_up = true;
 	return 0;
 out_lockd:
@@ -329,6 +328,7 @@ int nfsd_create_serv(void)
 		       nfsd_max_blksize >= 8*1024*2)
 			nfsd_max_blksize /= 2;
 	}
+	nfsd_reset_versions();
 
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
 				      nfsd_last_thread, nfsd, THIS_MODULE);
