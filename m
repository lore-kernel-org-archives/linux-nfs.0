Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676Ab0HFWHI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 18:07:08 -0400
Date: Fri, 6 Aug 2010 18:05:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Message-ID: <20100806220537.GE29536@fieldses.org>
References: <20100802103620.5638dac1@corrin.poochiereds.net>
 <20100802181634.GD12637@fieldses.org>
 <201008030109.o73193bp094241@www262.sakura.ne.jp>
 <20100803154851.GA23467@fieldses.org>
 <201008040013.o740DmYK024832@www262.sakura.ne.jp>
 <20100804194045.GD18200@fieldses.org>
 <201008050110.o751AG18066496@www262.sakura.ne.jp>
 <20100805204612.GA13821@fieldses.org>
 <20100805213107.GB13821@fieldses.org>
 <20100806212727.GC29536@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100806212727.GC29536@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 06, 2010 at 05:27:28PM -0400, J. Bruce Fields wrote:
> Bah, so what you were hitting was simple--I just moved the
> nfsd_reset_versions() call to the wrong place; the below should fix it.
> 
> There's also a couple other bugs in the area.

This isn't a serious bug, but I think it makes sense to fix it.

--b.

commit 7fa53cc872332b265bc5ba1266f39586f218ad4a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Aug 6 18:00:33 2010 -0400

    nfsd: don't allow setting maxblksize after svc created
    
    It's harmless to set this after the server is created, but also
    ineffective, since the value is only used at the time of
    svc_create_pooled().  So fail the attempt, in keeping with the pattern
    set by write_versions, write_{lease,grace}time and write_recoverydir.
    
    (This could break userspace that tried to write to nfsd/max_block_size
    between setting up sockets and starting the server.  However, such code
    wouldn't have worked anyway, and I don't know of any examples--rpc.nfsd
    in nfs-utils, probably the only user of the interface, doesn't do that.)
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 12f0ee7..b53b1d0 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1190,7 +1190,7 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 			bsize = NFSSVC_MAXBLKSIZE;
 		bsize &= ~(1024-1);
 		mutex_lock(&nfsd_mutex);
-		if (nfsd_serv && nfsd_serv->sv_nrthreads) {
+		if (nfsd_serv) {
 			mutex_unlock(&nfsd_mutex);
 			return -EBUSY;
 		}
