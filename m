Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31490 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761Ab1C0Pe5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Mar 2011 11:34:57 -0400
Subject: Re: strange put_rpccred() handling
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <87ei5sppsx.fsf@devron.myhome.or.jp>
References: <87ei5sppsx.fsf@devron.myhome.or.jp>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 27 Mar 2011 17:33:46 +0200
Message-ID: <1301240026.22136.27.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-03-28 at 00:05 +0900, OGAWA Hirofumi wrote:
> Hi,
> 
> BUG: atomic_dec_and_test(): -1: atomic counter underflow at:
> Pid: 2827, comm: mount.nfs Not tainted 2.6.38 #1
> Call Trace:
>  [<ffffffffa02223a0>] ? put_rpccred+0x44/0x14e [sunrpc]
>  [<ffffffffa021bbe9>] ? rpc_ping+0x4e/0x58 [sunrpc]
>  [<ffffffffa021c4a5>] ? rpc_create+0x481/0x4fc [sunrpc]
>  [<ffffffffa022298a>] ? rpcauth_lookup_credcache+0xab/0x22d [sunrpc]
>  [<ffffffffa028be8c>] ? nfs_create_rpc_client+0xa6/0xeb [nfs]
>  [<ffffffffa028c660>] ? nfs4_set_client+0xc2/0x1f9 [nfs]
>  [<ffffffffa028cd3c>] ? nfs4_create_server+0xf2/0x2a6 [nfs]
>  [<ffffffffa0295d07>] ? nfs4_remote_mount+0x4e/0x14a [nfs]
>  [<ffffffff810dd570>] ? vfs_kern_mount+0x6e/0x133
>  [<ffffffffa029605a>] ? nfs_do_root_mount+0x76/0x95 [nfs]
>  [<ffffffffa029643d>] ? nfs4_try_mount+0x56/0xaf [nfs]
>  [<ffffffffa0297434>] ? nfs_get_sb+0x435/0x73c [nfs]
>  [<ffffffff810dd59b>] ? vfs_kern_mount+0x99/0x133
>  [<ffffffff810dd693>] ? do_kern_mount+0x48/0xd8
>  [<ffffffff810f5b75>] ? do_mount+0x6da/0x741
>  [<ffffffff810f5c5f>] ? sys_mount+0x83/0xc0
>  [<ffffffff8100293b>] ? system_call_fastpath+0x16/0x1b
> 
> This is not oops, and debug code is not in vanilla. This debug code is
> simple - detects atomic_dec_and_test() underflow.
> 
> Well, so, I think this is real bug of nfs codes somewhere. With some
> review, the code
> 
> rpc_call_sync()
>     rpc_run_task
>         rpc_execute()
>             __rpc_execute()
>                 rpc_release_task()
>                     rpc_release_resources_task()
>                         put_rpccred()                <= release cred
>     rpc_put_task
>         rpc_do_put_task()
>             rpc_release_resources_task()
>                 put_rpccred()                        <= release cred again
> 
> seems to be release cred unintendedly.
> 
> static void rpc_release_resources_task(struct rpc_task *task)
> {
> 	if (task->tk_rqstp)
> 		xprt_release(task);
> 	if (task->tk_msg.rpc_cred) {
> 		put_rpccred(task->tk_msg.rpc_cred);
> 		task->tk_msg.rpc_cred = NULL;
> 	}
> 	rpc_task_release_client(task);
> }
> 
> The above change may fix the problem though, I don't know the codes what
> want to do actually. And I guess this is not right fix, because the path
> is looks strange - on early stage, __rpc_execute() calls
> rpc_release_task() explicitly.

Argh! You are completely correct. The intention was that
rpc_release_resources_task() should be able to be called more than once,
which means that we have to set task->tk_msg.rpc_cred to NULL after
freeing the cred. I've no idea why I missed that when I cleaned up that
code.

Thanks for debugging this!

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

