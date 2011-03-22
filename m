Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:44049 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751830Ab1CVOwY convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 10:52:24 -0400
From: Wolfgang Walter <wolfgang.walter@stwm.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: problem with nfs4: rpciod seems to loop in rpc_shutdown_client forever
Date: Tue, 22 Mar 2011 15:52:21 +0100
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <201103182349.22331.wolfgang.walter@stwm.de> <20110321232857.GC472@fieldses.org>
In-Reply-To: <20110321232857.GC472@fieldses.org>
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <201103221552.21826.wolfgang.walter@stwm.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Am Dienstag, 22. März 2011 schrieb J. Bruce Fields:
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
> > Mar 18 11:15:37 au kernel: [44640.906793] RPC:       killing all tasks
> > for client ffff88041c51de00 Mar 18 11:15:38 au kernel: [44641.906793]
> > RPC:       killing all tasks for client ffff88041c51de00 Mar 18 11:15:39
> > au kernel: [44642.906795] RPC:       killing all tasks for client
> > ffff88041c51de00 Mar 18 11:15:40 au kernel: [44643.906793] RPC:      
> > killing all tasks for client ffff88041c51de00 Mar 18 11:15:41 au kernel:
> > [44644.906795] RPC:       killing all tasks for client ffff88041c51de00
> > Mar 18 11:15:42 au kernel: [44645.906794] RPC:       killing all tasks
> > for client ffff88041c51de00
> >
> > and I get this messages:
> >
> > Mar 18 22:45:57 au kernel: [86061.779008]   174 0381     -5
> > ffff88041c51de00   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL
> > a:rpc_exit_task q:none
> >
> > My theorie is this one:
> >
> > * this async task is runnable but does not progress (calling
> > rpc_exit_task). * this is because the same rpciod which handles this task
> > loops in rpc_shutdown_client waiting for this task to go away.
> > * because rpc_shutdown_client is called from an async rpc, too
>
> Off hand I don't see any place where rpc_shutdown_client() is called
> from rpciod; do you?

I'm not familiar with the code.

But could it be that this is in fs/nfsd/nfs4state.c ?

Just a guess because 2.6.38 does not have this problem and in 2.6.38 it seems 
to have a workqueue of its own.

>
> > At the beginning is is always one or more tasks as above.
> >
> > Once a rpciod hangs more an more other tasks hang forever:
> >
> > Mar 18 22:45:57 au kernel: [86061.778809] -pid- flgs status -client-
> > --rqstp- -timeout ---ops-- Mar 18 22:45:57 au kernel: [86061.778819]  
> > 300 0281    -13 ffff8801ef5d0600   (null)        0 ffffffff817211a0
> > nfs4_cbv1 CB_NULL a:call_refreshresult q:none Mar 18 22:45:57 au kernel:
> > [86061.778823]   289 0281      0 ffff880142a49800 ffff8802a1dde000       
> > 0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_status q:none Mar 18 22:45:57
> > au kernel: [86061.778827]   286 0281      0 ffff880349f57e00
> > ffff88010affe000        0 ffffffff817a3fd0 rpcbindv2 GETPORT
> > a:call_status q:none Mar 18 22:45:57 au kernel: [86061.778830]   283 0281
> >      0 ffff88041d19ac00 ffff880418650000        0 ffffffff817a3fd0
> > rpcbindv2 GETPORT a:call_status q:none
>
> There's a lot of these GETPORT calls.  Is portmap/rpcbind down?

No, it is running.

I think that these getports get scheduled as tasks for the hanging rpciod.


Regards,
-- 
Wolfgang Walter
Studentenwerk München
Anstalt des öffentlichen Rechts

