Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3711 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757217Ab0IGTDu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 15:03:50 -0400
Subject: Re: [PATCH 01/03]: sunrpc: increase MAX_HASHTABLE_BITS to 14
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100822183020.GA26607@xs4all.net>
References: <20100822182848.GA26590@xs4all.net>
	 <20100822183020.GA26607@xs4all.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 15:03:38 -0400
Message-ID: <1283886218.2788.73.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-08-22 at 20:30 +0200, Miquel van Smoorenburg wrote:
> The maximum size of the authcache is now set to 1024 (10 bits),
> but on our server we need at least 4096 (12 bits). Increase
> MAX_HASHTABLE_BITS to 14. This is a maximum of 16384 entries,
> each containing a pointer (8 bytes on x86_64). This is
> exactly the limit of kmalloc() (128K).
> 
> Signed-off-by: Miquel van Smoorenburg <mikevs@xs4all.net>
> 
> diff -ruN linux-2.6.36-rc1.orig/net/sunrpc/auth.c linux-2.6.36-rc1/net/sunrpc/auth.c
> --- linux-2.6.36-rc1.orig/net/sunrpc/auth.c	2010-08-16 02:41:37.000000000 +0200
> +++ linux-2.6.36-rc1/net/sunrpc/auth.c	2010-08-22 17:02:27.896009116 +0200
> @@ -38,7 +39,7 @@
>  static LIST_HEAD(cred_unused);
>  static unsigned long number_cred_unused;
>  
> -#define MAX_HASHTABLE_BITS (10) 
> +#define MAX_HASHTABLE_BITS (14)
>  static int param_set_hashtbl_sz(const char *val, const struct kernel_param *kp)
>  {
>  	unsigned long num;

Fair enough. Applied...

Trond
