Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:46563 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403AbbBMRYE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2015 12:24:04 -0500
Received: by mail-vc0-f169.google.com with SMTP id kv19so6607407vcb.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Feb 2015 09:24:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <DB901924-FAA9-4A13-995D-9AB887756371@oracle.com>
References: <DB901924-FAA9-4A13-995D-9AB887756371@oracle.com>
Date: Fri, 13 Feb 2015 12:24:02 -0500
Message-ID: <CAHQdGtQC6wxn=X-78GLwsEj6R-arz+tKK_CwmmK=9Ffn4-t_DA@mail.gmail.com>
Subject: Re: rq_bc_pa_list manipulated under incorrect lock?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 13, 2015 at 11:30 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> Hi Trond-
>
> While reviewing xprt_complete_bc_request(), I noticed this:
>
> 326         spin_lock(&bc_serv->sv_cb_lock);
>
> 327         list_del(&req->rq_bc_pa_list);   <<<<<<<
>
> 328         list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
> 329         wake_up(&bc_serv->sv_cb_waitq);
> 330         spin_unlock(&bc_serv->sv_cb_lock);
>
> Other places in the code hold xprt->bc_pa_lock when updating
> rq_bc_pa_list. Maybe not a big deal because xprt->transport_lock is
> held across the lookup and complete calls?
>
> Introduced by commit 2ea24497a1b3 ("SUNRPC: RPC callbacks
> may be split across several TCP segments”).
>

Ack. That looks like a bug. It's not an actual problem as long as we
only have 1 entry on that list, but it will bite us if we ever decide
to grow the slot table...

Can you send a patch?

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
