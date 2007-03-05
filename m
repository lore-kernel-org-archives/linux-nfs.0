From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Oops in lockd (2.6.20.1)
Date: Mon, 05 Mar 2007 11:18:29 -0500
Message-ID: <1173111509.6470.29.camel@heimdal.trondhjem.org>
References: <20070305134706.GA6072@sith.mimuw.edu.pl>
	<200703051636.06411.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Jan Rekorajski <baggins@sith.mimuw.edu.pl>
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOFtj-0003XG-PW
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 08:18:53 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/FbJZX0eZ16xuePZFN3z54u1zXXsnDJdM=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOFtk-0000z6-Aj
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 08:18:53 -0800
In-Reply-To: <200703051636.06411.olaf.kirch@oracle.com>
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

On Mon, 2007-03-05 at 16:36 +0100, Olaf Kirch wrote:
> On Monday 05 March 2007 14:47, Jan Rekorajski wrote:
> > [<ffffffff8807cc1d>] :lockd:nlm_release_call+0xd/0x20
> > [<ffffffff8807cfca>] :lockd:__nlm_async_call+0x9a/0xc0
> > [<ffffffff8807e7a0>] :lockd:lockd+0x0/0x280
> > [<ffffffff8807d032>] :lockd:nlm_async_call+0x42/0x50
> > [<ffffffff8807fbae>] :lockd:nlmsvc_grant_blocked+0x12e/0x170
> > [<ffffffff8807fdd3>] :lockd:nlmsvc_retry_blocked+0x73/0xa0
> > [<ffffffff8807e8d7>] :lockd:lockd+0x137/0x280
> > [<ffffffff80253df8>] child_rip+0xa/0x12
> > [<ffffffff8807e7a0>] :lockd:lockd+0x0/0x280
> > [<ffffffff8807e7a0>] :lockd:lockd+0x0/0x280
> > [<ffffffff80253dee>] child_rip+0x0/0x12
> >
> >
> > Code: 8b 73 74 85 f6 79 25 48 c7 c1 60 47 08 88 ba 24 01 00 00 48
> > RIP  [<ffffffff8807e058>] :lockd:nlm_release_host+0x28/0x110
> > RSP <ffff8107c5075e40>
> 
> It seems it's dying on a bogus nlm_host pointer. In __nlm_async_call we have:
> 
>         status = rpc_call_async(clnt, msg, RPC_TASK_ASYNC, tk_ops, req);
>         if (status == 0)
>                 return 0;
> out_err:
>         nlm_release_call(req);
>         return status;
> }
> 
> So we ended up in nlm_release_call because rpc_call_async returned an
> error. However, when rpc_call_async fails, it calls the rpc_call_done handler.
> In this case, it's nlmsvc_release_block, which ends up freeing the nlm_block
> object, which does nlm_release_call(block->b_call).
> 
> So it appears to me that it's a double free.
> 
> IMHO, when rpc_call_async fails, we should just return status right away.
> 
> A similar argument applies to nlmsvc_grant_blocked, where we try to
> release the nlm_block object if nlm_async_call() returns an error. When
> we get there, the block object will have been freed already.
> 
> Olaf

Already fixed in 2.6.21-rc1 mainline. See

http://client.linux-nfs.org/Linux-2.6.x/2.6.20/linux-2.6.20-001-fix_nlm_async_call.dif

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
