Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:45010 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbbBMSia (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2015 13:38:30 -0500
Received: by mail-vc0-f182.google.com with SMTP id id10so6760919vcb.13
        for <linux-nfs@vger.kernel.org>; Fri, 13 Feb 2015 10:38:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150213180513.10705.1546.stgit@manet.1015granger.net>
References: <20150213180513.10705.1546.stgit@manet.1015granger.net>
Date: Fri, 13 Feb 2015 13:38:29 -0500
Message-ID: <CAHQdGtSYh2braYJqX048x5jDPrzSLzo2Am_iE=k+EDS0pctJBw@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Always manipulate rpc_rqst::rq_bc_pa_list under xprt->bc_pa_lock
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 13, 2015 at 1:08 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Other code that accesses rq_bc_pa_list holds xprt->bc_pa_lock.
> xprt_complete_bc_request() should do the same.
>
> Fixes: 2ea24497a1b3 ("SUNRPC: RPC callbacks may be split . . .")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> How about this (compile-tested only)?

 Looks just fine to me. Thanks!

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
