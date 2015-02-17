Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:47372 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431AbbBQXMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2015 18:12:15 -0500
Date: Tue, 17 Feb 2015 18:12:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David Ramos <daramos@stanford.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel memory leak in gssp_accept_sec_context_upcall()
 (net/sunrpc/auth_gss/gss_rpc_upcall.c)
Message-ID: <20150217231214.GC3667@fieldses.org>
References: <D7D77294-A842-4E57-91EF-31EE1B58EDD2@stanford.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <D7D77294-A842-4E57-91EF-31EE1B58EDD2@stanford.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 13, 2015 at 01:11:51PM -0800, David Ramos wrote:
> Our UC-KLEE tool found a kernel memory leak of 512 bytes (on x86_64) for each call to gssp_accept_sec_context_upcall() (net/sunrpc/auth_gss/gss_rpc_upcall.c). Since it appears that this call can be triggered by remote connections (at least, from a cursory a glance at the call chain), it may be exploitable to cause kernel memory exhaustion. We found the bug in kernel 3.16.3, but it appears to date back to commit 9dfd87da1aeb0fd364167ad199f40fe96a6a87be (2013-08-20).
> 
> The gssp_accept_sec_context_upcall() function performs a pair of calls to gssp_alloc_receive_pages() and gssp_free_receive_pages() (lines 282 and 290). The first function gssp_alloc_receive_pages() allocates memory for arg->pages:
> 225:         arg->pages = kzalloc(arg->npages * sizeof(struct page *), GFP_KERNEL);
> 
> The second function gssp_free_receive_pages() then frees the pages pointed to by the arg->pages array, but not the array itself:
> 218:         for (i = 0; i < arg->npages && arg->pages[i]; i++)
> 219:                 __free_page(arg->pages[i]);
> 
> I’ve included a suggested patch below

Thanks, applying.

> (apologies if the format isn’t quite right).

The whitespace is mangled (tabs replaced by spaces?), so I needed to
apply it manually.

Also I copied most of your explanation above into the commit message,
it's a little verbose but I'd rather err on the side of explaining stuff
than not.

--b.

> 
> Thanks,
> -David
> 
> 8<------------------------------------------------------------
> From 9baa9b3a8ba2efad2d63d735f3a7e718950c5068 Mon Sep 17 00:00:00 2001
> From: David A. Ramos <daramos@stanford.edu>
> Date: Fri, 13 Feb 2015 13:01:28 -0800
> Subject: [PATCH] Fix memory leak in gssp_accept_sec_context_upcall().
> 
> Reported-by: David A. Ramos <daramos@stanford.edu>
> Fixes: 9dfd87da1aeb ("rpc: fix huge kmalloc's in gss-proxy”)
> Signed-off-by: David A. Ramos <daramos@stanford.edu>
> ---
>  net/sunrpc/auth_gss/gss_rpc_upcall.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
> index abbb7dc..59eeed4 100644
> --- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
> +++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
> @@ -217,6 +217,8 @@ static void gssp_free_receive_pages(struct gssx_arg_accept_sec_context *arg)
>  
>         for (i = 0; i < arg->npages && arg->pages[i]; i++)
>                 __free_page(arg->pages[i]);
> +
> +       kfree(arg->pages);
>  }
>  
>  static int gssp_alloc_receive_pages(struct gssx_arg_accept_sec_context *arg)
> -- 
> 1.7.4.4
> 
