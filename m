Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:46102 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbaABEwU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jan 2014 23:52:20 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so13720756pdj.31
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jan 2014 20:52:19 -0800 (PST)
Message-ID: <52C4F07C.6050205@gmail.com>
Date: Thu, 02 Jan 2014 12:52:12 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
CC: Chuck Lever <chuck.lever@oracle.com>, Bruce Fields <bfields@fieldses.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>
Subject: Re: [PATCH 1/4] SUNRPC: Ensure xprt_connect_status handles all potential
 connection errors
References: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com> <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond, 

With the whole patchset, rpc.nfsd will return immediately as,
[root@localhost linux-2.6]# rpc.nfsd -N 2 -N 3
rpc.nfsd: writing fd to kernel failed: errno 13 (Permission denied)
rpc.nfsd: writing fd to kernel failed: errno 13 (Permission denied)
rpc.nfsd: unable to set any sockets for nfsd
[root@localhost linux-2.6]# dmesg
[ 1263.249079] svc: failed to register nfsdv4 RPC service (errno 13).
[ 1263.257789] svc: failed to register nfsdv4 RPC service (errno 13).

But, I think errno 13 cannot give user the correct meaning.
As before, errno 111 (Connection refused) maybe better.

thanks,
Kinglong Mee

On 01/01/2014 03:39 AM, Trond Myklebust wrote:
> Currently, xprt_connect_status will convert connection error values such
> as ECONNREFUSED, ECONNRESET, ... into EIO, which means that they never
> get handled.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprt.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 04199bc8416f..ddd198e90292 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -749,6 +749,11 @@ static void xprt_connect_status(struct rpc_task *task)
>  	}
>  
>  	switch (task->tk_status) {
> +	case -ECONNREFUSED:
> +	case -ECONNRESET:
> +	case -ECONNABORTED:
> +	case -ENETUNREACH:
> +	case -EHOSTUNREACH:
>  	case -EAGAIN:
>  		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
>  		break;
> 

