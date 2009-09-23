From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: a question abount =?UTF-8?Q?idmapd=E2=80=8F?=
Date: Wed, 23 Sep 2009 08:47:33 -0400
Message-ID: <1253710053.3211.4.camel@heimdal.trondhjem.org>
References: <1252611727-19078-1-git-send-email-jlayton@redhat.com>
	 <20090910202825.GL14406@fieldses.org>
	 <20090910170024.2853a48e@tlielax.poochiereds.net>
	 <COL101-W29D4B28A8FCF99B81BCAE6A6DB0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: hongpo gao <gaohhpp@hotmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40157 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832AbZIWMre (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Sep 2009 08:47:34 -0400
In-Reply-To: <COL101-W29D4B28A8FCF99B81BCAE6A6DB0-MsuGFMq8XAE@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-09-23 at 18:44 +0800, hongpo gao wrote:
> 
> hello, 
> 
> I have a question about idmap. Should I send the mail to
> linux-nfs@vger.kernel.org?

The linux-nfs mailing list is preferred over nfsv4@linux-nfs.org, if
that's what you mean.

> The question is as follows:
> 
> In Linux Kernel fs/nfs/idmap.c, 
> The process will call rpc_queue_upcall in the nfs_idmap_id function,
> then it will wait on the waitqueue util the userspace write msg into
> the idmap rpc_pipe. 
> 
> In userspace idmapd.c file,
> the nfscb will read the rpc_pipe by aiomicio(read, ...), write the
> rpc_pipe by atomicio(write,...) in the end.
> my question is : if the rpc.idmapd deamon is killed in the duration
> time that between atomicio(read,.. ) and atomic(write,...), will the
> kernel thread will always sleep on the wait_queue? That is to say,
> will the rpc_queue_upcall be never return ?

No. The kernel tracks whether or not a daemon is listening on the other
end of the rpc_pipe, and will therefore return an error should the above
scenario happen.

Cheers
  Trond

