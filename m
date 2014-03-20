Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36768 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759234AbaCTPh7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Mar 2014 11:37:59 -0400
Received: by mail-ig0-f173.google.com with SMTP id t19so15242830igi.0
        for <linux-nfs@vger.kernel.org>; Thu, 20 Mar 2014 08:37:59 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] SUNRPC: Ensure call_connect_status() deals correctly with SOFTCONN tasks
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1395328983-20477-1-git-send-email-steved@redhat.com>
Date: Thu, 20 Mar 2014 11:36:35 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <C382CE3B-4462-4B9F-9B73-2131993C4C47@primarydata.com>
References: <1395328983-20477-1-git-send-email-steved@redhat.com>
To: Dickson Steve <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 20, 2014, at 11:23, Steve Dickson <steved@redhat.com> wrote:

> Don't schedule an rpc_delay before checking to see if the task
> is a SOFTCON because the tk_callback from the delay (__rpc_atrun)
> clears the task status before the rpc_exit_task can be run.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> net/sunrpc/clnt.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index cea1308..cb76099 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1802,10 +1802,10 @@ call_connect_status(struct rpc_task *task)
> 	case -ECONNABORTED:
> 	case -ENETUNREACH:
> 	case -EHOSTUNREACH:
> -		/* retry with existing socket, after a delay */
> -		rpc_delay(task, 3*HZ);
> 		if (RPC_IS_SOFTCONN(task))
> 			break;
> +		/* retry with existing socket, after a delay */
> +		rpc_delay(task, 3*HZ);
> 	case -EAGAIN:
> 		/* Check for timeouts before looping back to call_bind */
> 	case -ETIMEDOUT:

Doh! Good catch!

Applied...

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

