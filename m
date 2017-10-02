Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:44514 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdJBLDG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Oct 2017 07:03:06 -0400
Received: by mail-qk0-f172.google.com with SMTP id r64so4494173qkc.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Oct 2017 04:03:05 -0700 (PDT)
Message-ID: <1506942183.1719.0.camel@redhat.com>
Subject: Re: [PATCH 09/18] nfsd: use ARRAY_SIZE
From: Jeff Layton <jlayton@redhat.com>
To: =?ISO-8859-1?Q?J=E9r=E9my?= Lefaure <jeremy.lefaure@lse.epita.fr>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 02 Oct 2017 07:03:03 -0400
In-Reply-To: <20171001193101.8898-10-jeremy.lefaure@lse.epita.fr>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
         <20171001193101.8898-10-jeremy.lefaure@lse.epita.fr>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2017-10-01 at 15:30 -0400, Jérémy Lefaure wrote:
> Using the ARRAY_SIZE macro improves the readability of the code.
> 
> Found with Coccinelle with the following semantic patch:
> @r depends on (org || report)@
> type T;
> T[] E;
> position p;
> @@
> (
>  (sizeof(E)@p /sizeof(*E))
> > 
> 
>  (sizeof(E)@p /sizeof(E[...]))
> > 
> 
>  (sizeof(E)@p /sizeof(T))
> )
> 
> Signed-off-by: Jérémy Lefaure <jeremy.lefaure@lse.epita.fr>
> ---
>  fs/nfsd/fault_inject.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> index 34c1c449fddf..3ec72c931ac5 100644
> --- a/fs/nfsd/fault_inject.c
> +++ b/fs/nfsd/fault_inject.c
> @@ -11,6 +11,7 @@
>  #include <linux/nsproxy.h>
>  #include <linux/sunrpc/addr.h>
>  #include <linux/uaccess.h>
> +#include <linux/kernel.h>
>  
>  #include "state.h"
>  #include "netns.h"
> @@ -125,8 +126,6 @@ static struct nfsd_fault_inject_op inject_ops[] =
> {
>  	},
>  };
>  
> -#define NUM_INJECT_OPS (sizeof(inject_ops)/sizeof(struct
> nfsd_fault_inject_op))
> -
>  int nfsd_fault_inject_init(void)
>  {
>  	unsigned int i;
> @@ -137,7 +136,7 @@ int nfsd_fault_inject_init(void)
>  	if (!debug_dir)
>  		goto fail;
>  
> -	for (i = 0; i < NUM_INJECT_OPS; i++) {
> +	for (i = 0; i < ARRAY_SIZE(inject_ops); i++) {
>  		op = &inject_ops[i];
>  		if (!debugfs_create_file(op->file, mode, debug_dir,
> op, &fops_nfsd))
>  			goto fail;

Reviewed-by: Jeff Layton <jlayton@redhat.com>
