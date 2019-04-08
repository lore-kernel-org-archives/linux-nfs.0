Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 837B6C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 18:15:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 49B702084C
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 18:15:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qnslTvZY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726403AbfDHSPF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 14:15:05 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:53170 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726220AbfDHSPF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2019 14:15:05 -0400
Received: by mail-it1-f193.google.com with SMTP id x132so644928itf.2
        for <linux-nfs@vger.kernel.org>; Mon, 08 Apr 2019 11:15:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ISXFPg+Gv8HTEmwkNh6axgfdIfhJxVO1PpHNkUfEdkg=;
        b=qnslTvZYvthkJOPAnQkv7TGgTejdSJmr2YUd5dtv5ZeuKsaddcAI5Ng9mj+7GAiNy8
         1Yv3j7iXGjZniMfugRtrOduI3tRR65njRnGBfhsfFswzLPmKvcntjYXTxL1TiXJY8HMP
         U3JswlmW6mrhf0I6XIvvHRpmAO15TwhAvUV3dferbXLiAuXd0LX0ivrMShuGOLH2798m
         9sY6in++BYfNrDHu48hBd+T3mZuQDjG9EJNZ4h77tZb1BynI+cPn83QAMyROloQ/0OwO
         1P5dZN5E7s5eDx09/X6Dq+pZDBFxyCh04zN1wo3N7yqiQkjD5+Mve9yy03Dt1TeiSbYz
         edkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ISXFPg+Gv8HTEmwkNh6axgfdIfhJxVO1PpHNkUfEdkg=;
        b=DxQW7dsBxSuPbR3K6neZ7//JPQZ8YnF+yBF7K6oHxqPqaL+5sRaYilb61jA358KZbl
         ecTNFPAhqv8T8uPW3IxrqV3uHLo9kykBC5tJ+LP7GvAHNJN/Wlt/5LNvgUuMaMqA3TgM
         hJDF1eHpM95ZseonDwOS32moNMv5fzUnCgHWxEmqXJdu6NDWPLvybRXwjdZ1N2KE6UWn
         AH2ktUjQe5h8G6cg99moWZaxSQZTHmJwlH/+qSVsvSB2z5YmacB72tnMlq7o8l0xgB9F
         lf+P9vlcNnkKnRNLX5c+rbMse96mUwzDsAB72SulZGcJgM2/uBUSBKBJRjwSwY8VZpkC
         jUEw==
X-Gm-Message-State: APjAAAUCHl5dnVJ5iK1NK1wBqQ8utez8YZnssBfIiebY6xsZdN8KgI8J
        8voI6pidekKMWCTr0gj4gbtlPJpedZM=
X-Google-Smtp-Source: APXvYqwoEQr83GLtnkaCgh8qWDCWUCGWG/lVUvpTIrmeJRny9FLodlhhAUb9HHOweYV+0FQ5Yfpbuw==
X-Received: by 2002:a24:f947:: with SMTP id l68mr19537246ith.128.1554747304364;
        Mon, 08 Apr 2019 11:15:04 -0700 (PDT)
Received: from gouda.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.googlemail.com with ESMTPSA id d138sm5403284itc.15.2019.04.08.11.15.03
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 08 Apr 2019 11:15:03 -0700 (PDT)
Message-ID: <b0a37e92321b5ef2f461a3eab79a8e4dd3afd96d.camel@gmail.com>
Subject: Re: [PATCH v2 28/28] NFS: Remove redundant open context from
 nfs_page
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Mon, 08 Apr 2019 14:15:02 -0400
In-Reply-To: <745990f6eedb24b4c59cb653d70b6b7da81aca9e.camel@hammerspace.com>
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
         <89770990a66eb25000248daaf2b0b8fcf105c8d7.camel@gmail.com>
         <745990f6eedb24b4c59cb653d70b6b7da81aca9e.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.0 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2019-04-08 at 18:13 +0000, Trond Myklebust wrote:
> On Mon, 2019-04-08 at 13:11 -0400, Anna Schumaker wrote:
> > On Sat, 2019-04-06 at 14:14 +0000, Trond Myklebust wrote:
> > > Hi Anna
> > > 
> > > On Fri, 2019-04-05 at 15:42 -0400, Anna Schumaker wrote:
> > > > Hi Trond,
> > > > 
> > > > I'm having some trouble with xfstests generic/464 after applying
> > > > this
> > > > patch.
> > > > Here is the oops I'm getting, I'm able to reproduce it fairly
> > > > easily
> > > > against all
> > > > NFS versions: 
> > > > 
> > > > [   41.182015] BUG: unable to handle kernel NULL pointer
> > > > dereference
> > > > at
> > > > 0000000000000048
> > > > [   41.182051] #PF error: [normal kernel read fault]
> > > > [   41.182071] PGD 0 P4D 0 
> > > > [   41.182086] Oops: 0000 [#1] PREEMPT SMP PTI
> > > > [   41.182104] CPU: 1 PID: 14515 Comm: kworker/1:6 Not tainted
> > > > 5.1.0-
> > > > rc3-ANNA+
> > > > #5292
> > > > [   41.182131] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > > > [   41.182174] Workqueue: nfsiod rpc_async_release [sunrpc]
> > > > [   41.182209] RIP: 0010:__put_nfs_open_context+0xd/0x110 [nfs]
> > > > [   41.182227] Code: f8 ba a8 00 00 00 be c0 0c 00 00 e8 5d c0 58
> > > > f7
> > > > 48 89 c3 48
> > > > 85 c0 74 c5 e9 15 ff ff ff 0f 1f 44 00 00 41 56 41 55 41 54 55 53
> > > > <48> 8b 47 48
> > > > 48 8b 68 30 4c 8b 60 68 f0 ff 0f 0f 88 14 53 01 00 74
> > > > [   41.182267] RSP: 0018:ffffae5f04b6be30 EFLAGS: 00010246
> > > > [   41.182279] RAX: 0000000000000000 RBX: ffffa22aae71a680 RCX:
> > > > 0000000000000000
> > > > [   41.182295] RDX: ffffffffb9205dc8 RSI: 0000000000000000 RDI:
> > > > 0000000000000000
> > > > [   41.182311] RBP: 0000000000000801 R08: ffffa22aa5ca0000 R09:
> > > > ffffa22aba267800
> > > > [   41.182327] R10: 0000000000000000 R11: 0000000000000000 R12:
> > > > ffffce5effd1c200
> > > > [   41.182351] R13: 0000000000000000 R14: ffffa22aad2aa6c0 R15:
> > > > 0ffffce5effd1c20
> > > > [   41.182378] FS:  0000000000000000(0000)
> > > > GS:ffffa22abcb00000(0000)
> > > > knlGS:0000000000000000
> > > > [   41.182411] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > [   41.182435] CR2: 0000000000000048 CR3: 00000000af972005 CR4:
> > > > 0000000000160ee0
> > > > [   41.182468] Call Trace:
> > > > [   41.182495]  nfs_commitdata_release+0x15/0x30 [nfs]
> > > > [   41.182536]  rpc_free_task+0x39/0x70 [sunrpc]
> > > > [   41.182571]  rpc_async_release+0x29/0x40 [sunrpc]
> > > > [   41.182594]  process_one_work+0x1eb/0x410
> > > > [   41.182611]  worker_thread+0x2d/0x3d0
> > > > [   41.182621]  ? process_one_work+0x410/0x410
> > > > [   41.182632]  kthread+0x112/0x130
> > > > [   41.182641]  ? kthread_park+0x80/0x80
> > > > [   41.182652]  ret_from_fork+0x35/0x40
> > > > [   41.182662] Modules linked in: nfsv3 nfs fscache rpcrdma
> > > > ib_isert
> > > > 
> > > 
> > > Does the following patch help to fix this?
> > 
> > This patch does fix the problem. Thanks!
> > 
> 
> Cool! I sent a v3 patchset update last night with this patch correctly
> positioned so it won't cause bisection issues, and with 2 other
> bugfixes. Hopefully, that is the final iteration of the patchset.

Sounds good. I'll look through them again and then add them to my linux-next.

Anna

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 

