Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56A8CC282CE
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 19:42:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 152082171F
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 19:42:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NPfiuIPW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731589AbfDETmT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 Apr 2019 15:42:19 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:45699 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731183AbfDETmT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2019 15:42:19 -0400
Received: by mail-io1-f66.google.com with SMTP id s7so5960725iom.12
        for <linux-nfs@vger.kernel.org>; Fri, 05 Apr 2019 12:42:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=HqGReXiTRd8rVMPDQAYdtnmPEfW0Me0b7Q4rx2q5OUs=;
        b=NPfiuIPWqjdb0KfoVHIhYQ6Tb/LROiK/0BMYbRdU0CHUotHfwOOXZRmv4eEIJQquhS
         gXGCzRsofcIpDZiAh+p7X8jdRUQPp/3fd8F/xksHLV4Ncb4+3vkj2onwXClX9tECIhE3
         S5J5hCVBYot/7haBHfpfrweRoYAor61nB0fZFuOdoMqgq5FjvOHB4rQezaaMh/DcTwgE
         N7pgqEtoy45AsZxxFktmwTsbzirBaLIy5UC2v8pzfaZgrZkvlNc7CYf+Qa7rDQaR+o46
         c4qAxzLnTjtWtPftxn1oQ4Tvv403e6ka1qKcyzCqJaG/sT3ugX6/eTkvR3uEv+zX6or6
         2fyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=HqGReXiTRd8rVMPDQAYdtnmPEfW0Me0b7Q4rx2q5OUs=;
        b=icR5Wkaqyg38jgxSiqCTJnJqp9UN0W9oKNvgn6qJVpP4Sm2CVys2h2E+bqXuhEskx8
         VSxjLtz3CQFls+08EYn3miDXuMxkWnbyTFyhlkh37i/SO4p5Wc3qRad+uhjHDe1xPjbp
         cV7aa2lzV+T5X7aSX7cJ4qrVIXTGPVLFsJ2Qcb0jqmT8CGjGkT5TJJyuZCulsVo8E2Cm
         HLOklEAaXSVoSaTlwAvS8dKmrgK8R1M466hnP0e2OXBa35pLxAngUqPpaZrTkCxDu60U
         RdHqYhwax0GrBV1WK7DAri+LscYIbIfU1HKBpeMzLw+1RZNWcBYgyR/cGnvMhJAO+IQH
         WEdA==
X-Gm-Message-State: APjAAAU/jIW28mQscLvURfuk8OmTMJvO1yFYs1hcu4sCDboHlqfv6J01
        o+UJ53mmbjHWOJnEBX9sW6Q=
X-Google-Smtp-Source: APXvYqyWTvPGreRJDOu3rnXzwVTZtxeiP02bV7eat49ApIlMbRe5E2xCb49RykeyL4DFwe5GZdl09w==
X-Received: by 2002:a5d:840d:: with SMTP id i13mr2439216ion.186.1554493337825;
        Fri, 05 Apr 2019 12:42:17 -0700 (PDT)
Received: from gouda.nowheycreamery.com (c-73-145-169-100.hsd1.mi.comcast.net. [73.145.169.100])
        by smtp.googlemail.com with ESMTPSA id o9sm1478032itb.23.2019.04.05.12.42.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 05 Apr 2019 12:42:16 -0700 (PDT)
Message-ID: <c92a3c3d629636a0ce88a04098565345ce5ed5d8.camel@gmail.com>
Subject: Re: [PATCH v2 28/28] NFS: Remove redundant open context from
 nfs_page
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Date:   Fri, 05 Apr 2019 15:42:15 -0400
In-Reply-To: <20190329215948.107328-29-trond.myklebust@hammerspace.com>
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
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.0 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

I'm having some trouble with xfstests generic/464 after applying this patch.
Here is the oops I'm getting, I'm able to reproduce it fairly easily against all
NFS versions: 

[   41.182015] BUG: unable to handle kernel NULL pointer dereference at
0000000000000048
[   41.182051] #PF error: [normal kernel read fault]
[   41.182071] PGD 0 P4D 0 
[   41.182086] Oops: 0000 [#1] PREEMPT SMP PTI
[   41.182104] CPU: 1 PID: 14515 Comm: kworker/1:6 Not tainted 5.1.0-rc3-ANNA+
#5292
[   41.182131] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   41.182174] Workqueue: nfsiod rpc_async_release [sunrpc]
[   41.182209] RIP: 0010:__put_nfs_open_context+0xd/0x110 [nfs]
[   41.182227] Code: f8 ba a8 00 00 00 be c0 0c 00 00 e8 5d c0 58 f7 48 89 c3 48
85 c0 74 c5 e9 15 ff ff ff 0f 1f 44 00 00 41 56 41 55 41 54 55 53 <48> 8b 47 48
48 8b 68 30 4c 8b 60 68 f0 ff 0f 0f 88 14 53 01 00 74
[   41.182267] RSP: 0018:ffffae5f04b6be30 EFLAGS: 00010246
[   41.182279] RAX: 0000000000000000 RBX: ffffa22aae71a680 RCX: 0000000000000000
[   41.182295] RDX: ffffffffb9205dc8 RSI: 0000000000000000 RDI: 0000000000000000
[   41.182311] RBP: 0000000000000801 R08: ffffa22aa5ca0000 R09: ffffa22aba267800
[   41.182327] R10: 0000000000000000 R11: 0000000000000000 R12: ffffce5effd1c200
[   41.182351] R13: 0000000000000000 R14: ffffa22aad2aa6c0 R15: 0ffffce5effd1c20
[   41.182378] FS:  0000000000000000(0000) GS:ffffa22abcb00000(0000)
knlGS:0000000000000000
[   41.182411] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   41.182435] CR2: 0000000000000048 CR3: 00000000af972005 CR4: 0000000000160ee0
[   41.182468] Call Trace:
[   41.182495]  nfs_commitdata_release+0x15/0x30 [nfs]
[   41.182536]  rpc_free_task+0x39/0x70 [sunrpc]
[   41.182571]  rpc_async_release+0x29/0x40 [sunrpc]
[   41.182594]  process_one_work+0x1eb/0x410
[   41.182611]  worker_thread+0x2d/0x3d0
[   41.182621]  ? process_one_work+0x410/0x410
[   41.182632]  kthread+0x112/0x130
[   41.182641]  ? kthread_park+0x80/0x80
[   41.182652]  ret_from_fork+0x35/0x40
[   41.182662] Modules linked in: nfsv3 nfs fscache rpcrdma ib_isert
iscsi_target_mod ib_iser libiscsi scsi_transport_iscsi ib_srpt target_core_mod
ib_srp scsi_transport_srp ib_ipoib rdma_ucm ib_uverbs ib_umad rdma_cm cfg80211
ib_cm iw_cm rfkill 8021q mrp ib_core crct10dif_pclmul crc32_pclmul joydev
mousedev crc32c_intel ghash_clmulni_intel aesni_intel input_leds led_class
psmouse aes_x86_64 evdev crypto_simd cryptd glue_helper mac_hid intel_agp
intel_gtt i2c_piix4 pcspkr nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables
x_tables ata_generic pata_acpi serio_raw atkbd libps2 ata_piix libata scsi_mod
floppy i8042 serio xfs virtio_balloon virtio_gpu drm_kms_helper syscopyarea
sysfillrect sysimgblt fb_sys_fops ttm drm virtio_net net_failover failover
agpgart virtio_pci virtio_blk virtio_ring virtio
[   41.182827] CR2: 0000000000000048
[   41.182836] ---[ end trace 19c8b9d2801d26ce ]---

Let me know if you need any more information!

Anna

On Fri, 2019-03-29 at 17:59 -0400, Trond Myklebust wrote:
> The lock context already references and tracks the open context, so
> take the opportunity to save some space in struct nfs_page.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/pagelist.c        | 7 +------
>  include/linux/nfs_page.h | 3 +--
>  2 files changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index ce6440b79328..5d5ac5df93e2 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -325,7 +325,6 @@ __nfs_create_request(struct nfs_lock_context *l_ctx,
> struct page *page,
>  	req->wb_offset  = offset;
>  	req->wb_pgbase	= pgbase;
>  	req->wb_bytes   = count;
> -	req->wb_context = get_nfs_open_context(ctx);
>  	kref_init(&req->wb_kref);
>  	req->wb_nio = 0;
>  	return req;
> @@ -414,8 +413,8 @@ void nfs_unlock_and_release_request(struct nfs_page *req)
>  static void nfs_clear_request(struct nfs_page *req)
>  {
>  	struct page *page = req->wb_page;
> -	struct nfs_open_context *ctx = req->wb_context;
>  	struct nfs_lock_context *l_ctx = req->wb_lock_context;
> +	struct nfs_open_context *ctx = l_ctx->open_context;
>  
>  	if (page != NULL) {
>  		put_page(page);
> @@ -430,10 +429,6 @@ static void nfs_clear_request(struct nfs_page *req)
>  		nfs_put_lock_context(l_ctx);
>  		req->wb_lock_context = NULL;
>  	}
> -	if (ctx != NULL) {
> -		put_nfs_open_context(ctx);
> -		req->wb_context = NULL;
> -	}
>  }
>  
>  /**
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index 1ea13e94feb7..0bbd587fac6a 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -42,7 +42,6 @@ struct nfs_inode;
>  struct nfs_page {
>  	struct list_head	wb_list;	/* Defines state of page: */
>  	struct page		*wb_page;	/* page to read in/write out
> */
> -	struct nfs_open_context	*wb_context;	/* File state context info */
>  	struct nfs_lock_context	*wb_lock_context;	/* lock context info
> */
>  	pgoff_t			wb_index;	/* Offset >> PAGE_SHIFT */
>  	unsigned int		wb_offset,	/* Offset & ~PAGE_MASK */
> @@ -203,7 +202,7 @@ loff_t req_offset(struct nfs_page *req)
>  static inline struct nfs_open_context *
>  nfs_req_openctx(struct nfs_page *req)
>  {
> -	return req->wb_context;
> +	return req->wb_lock_context->open_context;
>  }
>  
>  #endif /* _LINUX_NFS_PAGE_H */

