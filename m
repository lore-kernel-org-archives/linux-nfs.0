Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46908 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755168Ab1CVPBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 11:01:52 -0400
Date: Tue, 22 Mar 2011 11:01:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: problem with nfs4: rpciod seems to loop in rpc_shutdown_client
 forever
Message-ID: <20110322150147.GA14627@fieldses.org>
References: <201103182349.22331.wolfgang.walter@stwm.de>
 <20110321232857.GC472@fieldses.org>
 <201103221552.21826.wolfgang.walter@stwm.de>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <201103221552.21826.wolfgang.walter@stwm.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 22, 2011 at 03:52:21PM +0100, Wolfgang Walter wrote:
> Am Dienstag, 22. März 2011 schrieb J. Bruce Fields:
> > On Fri, Mar 18, 2011 at 11:49:21PM +0100, Wolfgang Walter wrote:
> > > Hello,
> > >
> > > I have a problem with our nfs-server (stable 2.6.32.33 but also with
> > > .31 or .32 and probably older ones): sometimes
> > > one or more rpciod get stuck. I used
> > >
> > > 	rpcdebug -m rpc -s all
> > >
> > > I get messages as the following one about every second:
> > >
> > > Mar 18 11:15:37 au kernel: [44640.906793] RPC:       killing all tasks
> > > for client ffff88041c51de00 Mar 18 11:15:38 au kernel: [44641.906793]
> > > RPC:       killing all tasks for client ffff88041c51de00 Mar 18 11:15:39
> > > au kernel: [44642.906795] RPC:       killing all tasks for client
> > > ffff88041c51de00 Mar 18 11:15:40 au kernel: [44643.906793] RPC:      
> > > killing all tasks for client ffff88041c51de00 Mar 18 11:15:41 au kernel:
> > > [44644.906795] RPC:       killing all tasks for client ffff88041c51de00
> > > Mar 18 11:15:42 au kernel: [44645.906794] RPC:       killing all tasks
> > > for client ffff88041c51de00
> > >
> > > and I get this messages:
> > >
> > > Mar 18 22:45:57 au kernel: [86061.779008]   174 0381     -5
> > > ffff88041c51de00   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL
> > > a:rpc_exit_task q:none
> > >
> > > My theorie is this one:
> > >
> > > * this async task is runnable but does not progress (calling
> > > rpc_exit_task). * this is because the same rpciod which handles this task
> > > loops in rpc_shutdown_client waiting for this task to go away.
> > > * because rpc_shutdown_client is called from an async rpc, too
> >
> > Off hand I don't see any place where rpc_shutdown_client() is called
> > from rpciod; do you?
> 
> I'm not familiar with the code.
> 
> But could it be that this is in fs/nfsd/nfs4state.c ?
> 
> Just a guess because 2.6.38 does not have this problem and in 2.6.38 it seems 
> to have a workqueue of its own.

Well, spotted, yes it's true that 2.6.32 had called put_nfs4_client()
from an rpc_call_done callback, that put_nfs4_client() can end up
calling rpc_shutdown_client, and that that's since been fixed....

If someone wants to backport the fix to 2.6.32.y....

Actually I think it might be sufficient just to apply
147efd0dd702ce2f1ab44449bd70369405ef68fd ?  But I haven't tried.

--b.

commit 147efd0dd702ce2f1ab44449bd70369405ef68fd
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sun Feb 21 17:41:19 2010 -0800

    nfsd4: shutdown callbacks on expiry
    
    Once we've expired the client, there's no further purpose to the
    callbacks; go ahead and shut down the callback client rather than
    waiting for the last reference to go.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index efef7f2..9ce5831 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -697,9 +697,6 @@ shutdown_callback_client(struct nfs4_client *clp)
 static inline void
 free_client(struct nfs4_client *clp)
 {
-	shutdown_callback_client(clp);
-	if (clp->cl_cb_xprt)
-		svc_xprt_put(clp->cl_cb_xprt);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -752,6 +749,9 @@ expire_client(struct nfs4_client *clp)
 				 se_perclnt);
 		release_session(ses);
 	}
+	shutdown_callback_client(clp);
+	if (clp->cl_cb_xprt)
+		svc_xprt_put(clp->cl_cb_xprt);
 	put_nfs4_client(clp);
 }
 
