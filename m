Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B572C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 17:11:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 61AE220880
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 17:11:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZLNLJSRX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728933AbfDHRLi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 13:11:38 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:38247 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727023AbfDHRLi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2019 13:11:38 -0400
Received: by mail-it1-f196.google.com with SMTP id f22so294955ita.3
        for <linux-nfs@vger.kernel.org>; Mon, 08 Apr 2019 10:11:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=HlHRMD0G2rWmkeFw62uDW9Q1A2QY2derloYBbj0xfD0=;
        b=ZLNLJSRXqH/emuE6C1pDhnaBo/cUeTQoshBsvq2hlZiAkjmGmnmNrMhd7vyC2OtjSS
         yrsvt66zaNzjcrE66ab4pC7JXR+E5V+YjQyHLngNoj/gncuqhGhX9aek2tHiUs8eWTRb
         lOtB1/+kNTP69HPhPdInIEV2hvy8h+/S3WEqMmf8FDJ9TTJ0unymXx89ZXLGShoY+CqH
         59WA63vuurToTdxuQJJYbCC5G7AxjieJZ7A2DFpkI+X/guj7KeJXWYL/Hpk30sm6F2jS
         N7sZw4Jm0jpwRLEZ4rQKKUHWrfOG23euhEbua6qQ/BbXeS2wyDKCQKoTldb/9D26eIoh
         qV9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=HlHRMD0G2rWmkeFw62uDW9Q1A2QY2derloYBbj0xfD0=;
        b=P17tA2nLrK5jX/JSZK2e5y0ljx20mBAHSQDfOn8+xpS+rDO28o1FiVz/I/oAqTUXcs
         XtQhIrMXAzcsCuupQLoB3WBUGT0Et1WYoJ0wyL9GtkseUl4EosLuXH43QUw6Xlyl3f/Y
         Zr9EDKEnlzO92tAG3m9FYlQaKlw4VF2TNlwU9YoQt/p0F2X9M6a85EQBc+/XpvhZMZgW
         MOqDxq25XiKnfuENilpkzJM/PCUHR430ehlvAwlViASnE+Fht0gcCou7mRowf9hQPNTM
         7UyyX/+pjOR1Vx6FWzURp5u3DMYsht4/x3bNYeApwa+uM+kThfk9MjN/VXwcTjYwDia0
         H8ZQ==
X-Gm-Message-State: APjAAAVMSDT1MmFLurALtgEj3bXRq3E5MQsA3K0bZOw/oVOXMDbmhYg4
        jJEHb3K1oe4Qw4bUkEYHGiEDNQqzgq0=
X-Google-Smtp-Source: APXvYqycF6Hf6cBHAvUzIoGmWAEVii5/lmoeehFY46kdo06pYtvD25MiVm6hxwbIFJ6i7FGnVNv7tg==
X-Received: by 2002:a05:660c:78e:: with SMTP id h14mr21249707itk.49.1554743496959;
        Mon, 08 Apr 2019 10:11:36 -0700 (PDT)
Received: from gouda.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.googlemail.com with ESMTPSA id p17sm12462808iol.69.2019.04.08.10.11.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 08 Apr 2019 10:11:34 -0700 (PDT)
Message-ID: <89770990a66eb25000248daaf2b0b8fcf105c8d7.camel@gmail.com>
Subject: Re: [PATCH v2 28/28] NFS: Remove redundant open context from
 nfs_page
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Mon, 08 Apr 2019 13:11:31 -0400
In-Reply-To: <9498d534b8e59f903bf750183a08d22a6ae7ba9a.camel@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
         <20190329215948.107328-2-trond.myklebust@hammerspace.com>
         <20190329215948.107328-3-trond.myklebust@hammerspace.com>
         <20190329215948.107328-4-trond.myklebust@hammerspace.com>
         <20190329215948.107328-5-trond.myklebust@hammerspace.com>
         <20190329215948.107328-6-trond.myklebust@hammerspace.com>
         <20190329215948.107328-7-trond.myklebust@hammerspace.com>
         <20190329215948.107328-8-trond.myklebust@hammerspace.com>
         <20190329215948.107328-9-trond.myklebust@hammerspace.com>
         <20190329215948.107328-10-trond.myklebust@hammerspace.com>
         <20190329215948.107328-11-trond.myklebust@hammerspace.com>
         <20190329215948.107328-12-trond.myklebust@hammerspace.com>
         <20190329215948.107328-13-trond.myklebust@hammerspace.com>
         <20190329215948.107328-14-trond.myklebust@hammerspace.com>
         <20190329215948.107328-15-trond.myklebust@hammerspace.com>
         <20190329215948.107328-16-trond.myklebust@hammerspace.com>
         <20190329215948.107328-17-trond.myklebust@hammerspace.com>
         <20190329215948.107328-18-trond.myklebust@hammerspace.com>
         <20190329215948.107328-19-trond.myklebust@hammerspace.com>
         <20190329215948.107328-20-trond.myklebust@hammerspace.com>
         <20190329215948.107328-21-trond.myklebust@hammerspace.com>
         <20190329215948.107328-22-trond.myklebust@hammerspace.com>
         <20190329215948.107328-23-trond.myklebust@hammerspace.com>
         <20190329215948.107328-24-trond.myklebust@hammerspace.com>
         <20190329215948.107328-25-trond.myklebust@hammerspace.com>
         <20190329215948.107328-26-trond.myklebust@hammerspace.com>
         <20190329215948.107328-27-trond.myklebust@hammerspace.com>
         <20190329215948.107328-28-trond.myklebust@hammerspace.com>
         <20190329215948.107328-29-trond.myklebust@hammerspace.com>
         <c92a3c3d629636a0ce88a04098565345ce5ed5d8.camel@gmail.com>
         <9498d534b8e59f903bf750183a08d22a6ae7ba9a.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.0 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, 2019-04-06 at 14:14 +0000, Trond Myklebust wrote:
> Hi Anna
> 
> On Fri, 2019-04-05 at 15:42 -0400, Anna Schumaker wrote:
> > Hi Trond,
> > 
> > I'm having some trouble with xfstests generic/464 after applying this
> > patch.
> > Here is the oops I'm getting, I'm able to reproduce it fairly easily
> > against all
> > NFS versions: 
> > 
> > [   41.182015] BUG: unable to handle kernel NULL pointer dereference
> > at
> > 0000000000000048
> > [   41.182051] #PF error: [normal kernel read fault]
> > [   41.182071] PGD 0 P4D 0 
> > [   41.182086] Oops: 0000 [#1] PREEMPT SMP PTI
> > [   41.182104] CPU: 1 PID: 14515 Comm: kworker/1:6 Not tainted 5.1.0-
> > rc3-ANNA+
> > #5292
> > [   41.182131] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [   41.182174] Workqueue: nfsiod rpc_async_release [sunrpc]
> > [   41.182209] RIP: 0010:__put_nfs_open_context+0xd/0x110 [nfs]
> > [   41.182227] Code: f8 ba a8 00 00 00 be c0 0c 00 00 e8 5d c0 58 f7
> > 48 89 c3 48
> > 85 c0 74 c5 e9 15 ff ff ff 0f 1f 44 00 00 41 56 41 55 41 54 55 53
> > <48> 8b 47 48
> > 48 8b 68 30 4c 8b 60 68 f0 ff 0f 0f 88 14 53 01 00 74
> > [   41.182267] RSP: 0018:ffffae5f04b6be30 EFLAGS: 00010246
> > [   41.182279] RAX: 0000000000000000 RBX: ffffa22aae71a680 RCX:
> > 0000000000000000
> > [   41.182295] RDX: ffffffffb9205dc8 RSI: 0000000000000000 RDI:
> > 0000000000000000
> > [   41.182311] RBP: 0000000000000801 R08: ffffa22aa5ca0000 R09:
> > ffffa22aba267800
> > [   41.182327] R10: 0000000000000000 R11: 0000000000000000 R12:
> > ffffce5effd1c200
> > [   41.182351] R13: 0000000000000000 R14: ffffa22aad2aa6c0 R15:
> > 0ffffce5effd1c20
> > [   41.182378] FS:  0000000000000000(0000) GS:ffffa22abcb00000(0000)
> > knlGS:0000000000000000
> > [   41.182411] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [   41.182435] CR2: 0000000000000048 CR3: 00000000af972005 CR4:
> > 0000000000160ee0
> > [   41.182468] Call Trace:
> > [   41.182495]  nfs_commitdata_release+0x15/0x30 [nfs]
> > [   41.182536]  rpc_free_task+0x39/0x70 [sunrpc]
> > [   41.182571]  rpc_async_release+0x29/0x40 [sunrpc]
> > [   41.182594]  process_one_work+0x1eb/0x410
> > [   41.182611]  worker_thread+0x2d/0x3d0
> > [   41.182621]  ? process_one_work+0x410/0x410
> > [   41.182632]  kthread+0x112/0x130
> > [   41.182641]  ? kthread_park+0x80/0x80
> > [   41.182652]  ret_from_fork+0x35/0x40
> > [   41.182662] Modules linked in: nfsv3 nfs fscache rpcrdma ib_isert
> > 
> 
> Does the following patch help to fix this?

This patch does fix the problem. Thanks!

Anna

> 
> Cheers
>   Trond
> 
> 8<---------------------------------------
> From d84c699bba78d66d3ccd3f76a6aae573bdfddc05 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
> Date: Sat, 6 Apr 2019 10:05:55 -0400
> Subject: [PATCH] NFS: Ensure that all nfs lock contexts have a valid open
>  context
> 
> Force the lock context to keep a reference to the parent open
> context so that we can guarantee the validity of the latter.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/inode.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 414a90d48493..efc45f22c581 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -885,10 +885,14 @@ struct nfs_lock_context *nfs_get_lock_context(struct
> nfs_open_context *ctx)
>  		spin_lock(&inode->i_lock);
>  		res = __nfs_find_lock_context(ctx);
>  		if (res == NULL) {
> -			list_add_tail_rcu(&new->list, &ctx->lock_context.list);
> -			new->open_context = ctx;
> -			res = new;
> -			new = NULL;
> +			new->open_context = get_nfs_open_context(ctx);
> +			if (new->open_context) {
> +				list_add_tail_rcu(&new->list,
> +						&ctx->lock_context.list);
> +				res = new;
> +				new = NULL;
> +			} else
> +				res = ERR_PTR(-EBADF);
>  		}
>  		spin_unlock(&inode->i_lock);
>  		kfree(new);
> @@ -906,6 +910,7 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
>  		return;
>  	list_del_rcu(&l_ctx->list);
>  	spin_unlock(&inode->i_lock);
> +	put_nfs_open_context(ctx);
>  	kfree_rcu(l_ctx, rcu_head);
>  }
>  EXPORT_SYMBOL_GPL(nfs_put_lock_context);
> -- 
> 2.20.1
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 

