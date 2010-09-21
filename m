Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47714 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756589Ab0IUUAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 16:00:42 -0400
Subject: Re: [bfields@pop.test.fieldses.org: all f08d6374 Merge branch
 'nfs-for-next' into linux-next results]
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <1285097787.30222.24.camel@heimdal.trondhjem.org>
References: <20100918171546.GA9859@fieldses.org>
	 <1284831680.2787.1.camel@heimdal.trondhjem.org>
	 <20100919184549.GD32071@fieldses.org> <20100920130106.GB4580@fieldses.org>
	 <20100920131025.GC4580@fieldses.org>
	 <1285091815.30222.19.camel@heimdal.trondhjem.org>
	 <20100921111657.330e7838@corrin.poochiereds.net>
	 <20100921192005.GC4385@fieldses.org>
	 <1285097787.30222.24.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Sep 2010 16:00:32 -0400
Message-ID: <1285099232.30222.25.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-21 at 15:36 -0400, Trond Myklebust wrote:
> On Tue, 2010-09-21 at 15:20 -0400, J. Bruce Fields wrote:
> > All I need to do is mount nfs4.1 and run cthon -s.  The last output I
> > see from the test is:
> > 
> > check for proper open/unlink operation
> > nfsjunk files before unlink:
> >   
> 
> Oh... I bet I see what it is.
> 
> It's that damned res->sr_slotid = NFS4_MAX_SLOT_TABLE and related
> initialisation junk that's biting us in the arse again...
> 
> I'll fix it...

Does this work?

Cheers
  Trond
-------------------------------------------------------------------------------------
NFSv4.1: Fix the slotid initialisation in nfs_async_rename()

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c46e45e..72aa706 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2550,6 +2550,7 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 
 	args->bitmask = server->cache_consistency_bitmask;
 	res->server = server;
+	res->seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
 }
 
@@ -2575,6 +2576,7 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
 	arg->bitmask = server->attr_bitmask;
 	res->server = server;
+	res->seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 }
 
 static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,


