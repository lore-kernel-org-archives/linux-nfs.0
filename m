From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Found issue with BKL not held
	during	call	to	nfs_asynch_unlink_release()
Date: Thu, 05 Oct 2006 17:09:57 -0400
Message-ID: <1160082597.12684.8.camel@lade.trondhjem.org>
References: <1160070364.3376.71.camel@dyn9047022153>
	<1160079629.10668.3.camel@lade.trondhjem.org>
	<1160081896.3376.87.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVaTz-0002z9-I9
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 14:10:19 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVaTy-0001sP-3T
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 14:10:20 -0700
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: <1160081896.3376.87.camel@dyn9047022153>
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

On Thu, 2006-10-05 at 13:58 -0700, Frank Filz wrote:
> Ok. Should the BKL be acquired for all the tk_ops calls? I see these
> four:
> 
> net/sunrpc/clnt.c rpc_call_async 535 tk_ops->rpc_release(data);

Yup. This needs a BKL wrapper.

> net/sunrpc/sched.c rpc_prepare_task 568 task->tk_ops->rpc_call_prepare
> (task, task->tk_calldata);

Nope. Should be covered by the BKL wrapper of task->tk_action() in
__rpc_execute().

> net/sunrpc/sched.c rpc_exit_task 578 task->tk_ops->rpc_call_done(task,
> task->tk_calldata);

Nope. Should be covered by the BKL wrapper of task->tk_action() in
__rpc_execute().

> net/sunrpc/sched.c rpc_release_task 892 tk_ops->rpc_release(calldata);

Yup. This needs a BKL wrapper.

Note that this would allow us to immediately get rid of all the BKL
wrappers around rpc_call_*() and friends.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
