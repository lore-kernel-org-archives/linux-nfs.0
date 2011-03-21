Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34695 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755583Ab1CUXfi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2011 19:35:38 -0400
Subject: Re: problem with nfs4: rpciod seems to loop in rpc_shutdown_client
 forever
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Wolfgang Walter <wolfgang.walter@stwm.de>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <20110321232857.GC472@fieldses.org>
References: <201103182349.22331.wolfgang.walter@stwm.de>
	 <20110321232857.GC472@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Mar 2011 19:35:36 -0400
Message-ID: <1300750536.26546.31.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-03-21 at 19:28 -0400, J. Bruce Fields wrote:
> On Fri, Mar 18, 2011 at 11:49:21PM +0100, Wolfgang Walter wrote:
> > Hello,
> > 
> > I have a problem with our nfs-server (stable 2.6.32.33 but also with
> > .31 or .32 and probably older ones): sometimes
> > one or more rpciod get stuck. I used
> > 
> > 	rpcdebug -m rpc -s all
> > 
> > I get messages as the following one about every second:
> > 
> > Mar 18 11:15:37 au kernel: [44640.906793] RPC:       killing all tasks for client ffff88041c51de00
> > Mar 18 11:15:38 au kernel: [44641.906793] RPC:       killing all tasks for client ffff88041c51de00
> > Mar 18 11:15:39 au kernel: [44642.906795] RPC:       killing all tasks for client ffff88041c51de00
> > Mar 18 11:15:40 au kernel: [44643.906793] RPC:       killing all tasks for client ffff88041c51de00
> > Mar 18 11:15:41 au kernel: [44644.906795] RPC:       killing all tasks for client ffff88041c51de00
> > Mar 18 11:15:42 au kernel: [44645.906794] RPC:       killing all tasks for client ffff88041c51de00
> > 
> > and I get this messages:
> > 
> > Mar 18 22:45:57 au kernel: [86061.779008]   174 0381     -5 ffff88041c51de00   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL a:rpc_exit_task q:none
> > 
> > My theorie is this one:
> > 
> > * this async task is runnable but does not progress (calling rpc_exit_task).
> > * this is because the same rpciod which handles this task loops in
> >   rpc_shutdown_client waiting for this task to go away.
> > * because rpc_shutdown_client is called from an async rpc, too
> 
> Off hand I don't see any place where rpc_shutdown_client() is called
> from rpciod; do you?

The only case I could think of would be if we're still calling mntput()
from some RPC callback. In principle we should only be doing that from
the rpc_call_ops->rpc_callback() from within the nfsiod thread rather
than rpciod.

Is it possible this might be another instance of the nfs_commit_inode()
busy-loop?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

