From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: Found issue with BKL not held during call to
	nfs_asynch_unlink_release()
Date: Thu, 5 Oct 2006 17:25:14 -0400
Message-ID: <76bd70e30610051425g49ff3e50j1d698bfacb784a41@mail.gmail.com>
References: <1160070364.3376.71.camel@dyn9047022153>
	<1160079629.10668.3.camel@lade.trondhjem.org>
	<1160081896.3376.87.camel@dyn9047022153>
	<1160082597.12684.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilzlnx@us.ibm.com>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVaiR-0004Jl-Sh
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 14:25:16 -0700
Received: from wx-out-0506.google.com ([66.249.82.236])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GVaiR-00070w-KY
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 14:25:16 -0700
Received: by wx-out-0506.google.com with SMTP id r21so870587wxc
	for <nfs@lists.sourceforge.net>; Thu, 05 Oct 2006 14:25:15 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1160082597.12684.8.camel@lade.trondhjem.org>
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

On 10/5/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2006-10-05 at 13:58 -0700, Frank Filz wrote:
> > Ok. Should the BKL be acquired for all the tk_ops calls? I see these
> > four:
> >
> > net/sunrpc/clnt.c rpc_call_async 535 tk_ops->rpc_release(data);
>
> Yup. This needs a BKL wrapper.
>
> > net/sunrpc/sched.c rpc_prepare_task 568 task->tk_ops->rpc_call_prepare
> > (task, task->tk_calldata);
>
> Nope. Should be covered by the BKL wrapper of task->tk_action() in
> __rpc_execute().
>
> > net/sunrpc/sched.c rpc_exit_task 578 task->tk_ops->rpc_call_done(task,
> > task->tk_calldata);
>
> Nope. Should be covered by the BKL wrapper of task->tk_action() in
> __rpc_execute().
>
> > net/sunrpc/sched.c rpc_release_task 892 tk_ops->rpc_release(calldata);
>
> Yup. This needs a BKL wrapper.

One more, in rpc_run_task()...

> Note that this would allow us to immediately get rid of all the BKL
> wrappers around rpc_call_*() and friends.

Do you mean rpc_call_{a,}sync() or do you mean the tk_ops calls?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
