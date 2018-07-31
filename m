Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:37662 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729797AbeGaKoH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2018 06:44:07 -0400
Received: by mail-qt0-f194.google.com with SMTP id n6-v6so15122386qtl.4
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 02:04:47 -0700 (PDT)
Message-ID: <1533027885.3710.2.camel@redhat.com>
Subject: Re: linux-next: build warning after merge of the nfs-anna tree
From: David Wysochanski <dwysocha@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date: Tue, 31 Jul 2018 05:04:45 -0400
In-Reply-To: <20180730185200.0d836ca7@canb.auug.org.au>
References: <20180730185200.0d836ca7@canb.auug.org.au>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2018-07-30 at 18:52 +1000, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the nfs-anna tree, today's linux-next build (powerpc
> ppc44x_defconfig, sparc defconfig) produced this warning:
> 
> net/sunrpc/stats.c: In function 'rpc_clnt_show_stats':
> /home/sfr/next/next/net/sunrpc/stats.c:258:32: warning: excess elements in struct initializer
>    struct rpc_iostats stats = { 0 };
>         

Apologies I did not see this before submission.

The below fixup compiles without warning for me on ppc64le.

   struct rpc_iostats stats = {};


>                         ^
> 
> Introduced by commit
> 
>   c3b588a2d5be ("sunrpc: Change rpc_print_iostats to rpc_clnt_show_stats and handle rpc_clnt clones")
> 
