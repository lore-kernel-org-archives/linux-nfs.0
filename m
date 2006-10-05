From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Found issue with BKL not held during call
	to	nfs_asynch_unlink_release()
Date: Thu, 05 Oct 2006 14:33:40 -0700
Message-ID: <1160084020.3376.93.camel@dyn9047022153>
References: <1160070364.3376.71.camel@dyn9047022153>
	<1160079629.10668.3.camel@lade.trondhjem.org>
	<1160081896.3376.87.camel@dyn9047022153>
	<1160082597.12684.8.camel@lade.trondhjem.org>
	<76bd70e30610051425g49ff3e50j1d698bfacb784a41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVaof-0004qE-2J
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 14:31:41 -0700
Received: from e31.co.us.ibm.com ([32.97.110.149])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVaoe-0006es-NP
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 14:31:42 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k95LVT4F020110
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 17:31:29 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k95LVTUf540002
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 15:31:29 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k95LVS7a029493
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 15:31:29 -0600
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30610051425g49ff3e50j1d698bfacb784a41@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-10-05 at 17:25 -0400, Chuck Lever wrote:
> On 10/5/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Thu, 2006-10-05 at 13:58 -0700, Frank Filz wrote:
> > > Ok. Should the BKL be acquired for all the tk_ops calls? I see these
> > > four:
> > >
> > > net/sunrpc/clnt.c rpc_call_async 535 tk_ops->rpc_release(data);
> >
> > Yup. This needs a BKL wrapper.
> >
> > > net/sunrpc/sched.c rpc_prepare_task 568 task->tk_ops->rpc_call_prepare
> > > (task, task->tk_calldata);
> >
> > Nope. Should be covered by the BKL wrapper of task->tk_action() in
> > __rpc_execute().
> >
> > > net/sunrpc/sched.c rpc_exit_task 578 task->tk_ops->rpc_call_done(task,
> > > task->tk_calldata);
> >
> > Nope. Should be covered by the BKL wrapper of task->tk_action() in
> > __rpc_execute().
> >
> > > net/sunrpc/sched.c rpc_release_task 892 tk_ops->rpc_release(calldata);
> >
> > Yup. This needs a BKL wrapper.
> 
> One more, in rpc_run_task()...

Oops, missed that one. I'll code up and test a patch to add these.

> > Note that this would allow us to immediately get rid of all the BKL
> > wrappers around rpc_call_*() and friends.

I'll also code up a separate patch or patch set to remove these.

> Do you mean rpc_call_{a,}sync() or do you mean the tk_ops calls?

I assume rpc_call_async() and rpc_call_sync() along with rpc_execute().

Frank



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
