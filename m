Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og113.obsmtp.com ([64.18.0.26]:51371 "HELO
	exprod5og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932443Ab0JXMCH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Oct 2010 08:02:07 -0400
Message-ID: <4CC4203C.2050600@panasas.com>
Date: Sun, 24 Oct 2010 14:02:04 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] move include lines out of include file
References: <20101022005120.GA15788@merit.edu>
In-Reply-To: <20101022005120.GA15788@merit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/22/2010 02:51 AM, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  include/linux/sunrpc/simple_rpc_pipefs.h |    6 ------
>  net/sunrpc/simple_rpc_pipefs.c           |    5 +++++
>  2 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/sunrpc/simple_rpc_pipefs.h b/include/linux/sunrpc/simple_rpc_pipefs.h
> index 02e8147..f6a1227 100644
> --- a/include/linux/sunrpc/simple_rpc_pipefs.h
> +++ b/include/linux/sunrpc/simple_rpc_pipefs.h
> @@ -39,14 +39,8 @@
>  #ifndef _SIMPLE_RPC_PIPEFS_H_
>  #define _SIMPLE_RPC_PIPEFS_H_
>  
> -#include <linux/fs.h>
> -#include <linux/list.h>
> -#include <linux/mount.h>
> -#include <linux/sched.h>
> -#include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/rpc_pipe_fs.h>
>  
> -
>  #define payload_of(headerp)  ((void *)(headerp + 1))
>  
>  /*
> diff --git a/net/sunrpc/simple_rpc_pipefs.c b/net/sunrpc/simple_rpc_pipefs.c
> index c9306aa..b749cf7 100644
> --- a/net/sunrpc/simple_rpc_pipefs.c
> +++ b/net/sunrpc/simple_rpc_pipefs.c
> @@ -41,6 +41,11 @@
>  #include <linux/completion.h>
>  #include <linux/uaccess.h>
>  #include <linux/module.h>
> +#include <linux/fs.h>
> +#include <linux/list.h>
> +#include <linux/mount.h>
> +#include <linux/sched.h>
> +#include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/simple_rpc_pipefs.h>
>  

This patch does *not* break the header's independence. .i.e
the header can still be compiled independently without any other
includes. Which means some of the includes here are un-needed.
See patch below. (Please squash it into your patch)

Boaz
---
git diff --stat -p -M net/sunrpc/simple_rpc_pipefs.c
 net/sunrpc/simple_rpc_pipefs.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/simple_rpc_pipefs.c b/net/sunrpc/simple_rpc_pipefs.c
index c4825b7..24e2277 100644
--- a/net/sunrpc/simple_rpc_pipefs.c
+++ b/net/sunrpc/simple_rpc_pipefs.c
@@ -38,13 +38,7 @@
  *  With thanks to CITI's project sponsor and partner, IBM.
  */
 
-#include <linux/completion.h>
-#include <linux/uaccess.h>
-#include <linux/module.h>
-#include <linux/fs.h>
-#include <linux/list.h>
 #include <linux/mount.h>
-#include <linux/sched.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/simple_rpc_pipefs.h>
 
