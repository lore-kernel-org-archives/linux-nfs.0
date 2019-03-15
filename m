Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95EC9C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:19:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5C9FA218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:19:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qejtTyE1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726468AbfCOTTG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 15:19:06 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:36673 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726431AbfCOTTG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 15:19:06 -0400
Received: by mail-it1-f196.google.com with SMTP id h9so12646922itl.1
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 12:19:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1V+cnnuSxQItDHiNOiHdtKo390u6Icwe8DT85cEGY/o=;
        b=qejtTyE1DdlARXTNB4vcJrio+4hygzo/Ta3xmpATl/g5fGqffFFQA0vegWDaFcyOEw
         9a10tQJYFZXQuJCXfCBAGVIzgLHxt9sJFq8lVt3c3phsnYF+FG6G7IQ2pwHTWwpJ2Yrg
         dHU1pmZgezQxs/hX23Jo6kbvK1ipk5ebz2bEUnM9EVRSwpEt2/lh7jTbjvKKGrQnCx6R
         dLJSoHjR1AF41TS5yZQnYry9ceU4gx5S5QY/CCMKfrKfJaUVpX7R7a0tzpiS5VYnVRGT
         meYAR9ZavvyXGv82ATixyZ8sOR1ny5a9Jiy9sguk6Fxe55f/V+sLCISmPGVdllxxDRat
         xq8Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=1V+cnnuSxQItDHiNOiHdtKo390u6Icwe8DT85cEGY/o=;
        b=IqgCn3kB0A1LGv0XobVfJ50c7b/k546wYZV3BBpX3TUpP6D/Xy0f9B6JgjTJnaR+Dw
         ygYZvnzW6zsUS4Go4C24YmnaCwPx3ON7VBWDyAEAPkMUKF1bZBzXH9vVI5QPezQXWEo+
         ImeFk+K2DUMYpjJV78EvuYXCjgklB1majFo5coY+mZMYrhSMUdP+A51N2ox1Ozg7XGNg
         a5DpeJ4+Fdoe0ZdU6EN2T+Wc47AtPrKV5lTZPwn0/qfy7tjWPaE5usrV4axOt6IFufVF
         dgF13BT2Ge3jUQIN2u7em0mohYZJM6MzjYjas7MNRjlwhOWyTQ73mWSVM6DePNn0bz6n
         nVbQ==
X-Gm-Message-State: APjAAAWxnnklp1857IKfA4D8W9I9+GnIzVzYWrCuJ0R+OujhmC+jQ4Yl
        13fZkK4+ctl9wa5fzpKX9hPSIWT/0QzfvxYKUovy7g==
X-Google-Smtp-Source: APXvYqwgPTrM8xanhHuSTBiN2m6cWwL7WxwQt/Bcg2q87EuUrJShjdmNYNgF5vGHKdqTxCc6e6NgbOJvocTc5pabXgY=
X-Received: by 2002:a24:8985:: with SMTP id s127mr2878707itd.72.1552677545702;
 Fri, 15 Mar 2019 12:19:05 -0700 (PDT)
MIME-Version: 1.0
References: <CAB9dFduu5_UDP_G-QXiYCYMPoytMOJQJ5OxXB02rGtbfMXO5BQ@mail.gmail.com>
 <0e15881e705bb78910d6f3032273491eb1d5f369.camel@hammerspace.com>
In-Reply-To: <0e15881e705bb78910d6f3032273491eb1d5f369.camel@hammerspace.com>
From:   Marc Dionne <marc.c.dionne@gmail.com>
Date:   Fri, 15 Mar 2019 16:18:53 -0300
Message-ID: <CAB9dFdux-sD2hXEu8QSg=b+N624RHb9cHwPin1HoTeN_UuPVeA@mail.gmail.com>
Subject: Re: Hanging nfs mount - bisected to merge commit 06b5fc3ad94e
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 15, 2019 at 2:54 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> Hi Marc
>
> On Thu, 2019-03-14 at 16:32 -0300, Marc Dionne wrote:
> > I have an odd nfs issue with the current mainline kernel, where a
> > mount hangs and eventually times out when attempting a mount with nfs
> > version 4 and that is not offered by the server.  With prior kernels
> > it fails quickly with "mount.nfs: Protocol not supported".
> >
> > To reproduce, I have rpc.nfsd start with "-N 4", then try to mount
> > something local with -o nfsvers=4, for instance:
> >   $ mount -t nfs -o nfsvers=4 localhost:/s /mnt
> >
> > I bisected the behaviour down to commit 06b5fc3ad94e ("Merge tag
> > 'nfs-rdma-for-5.1-1' of
> > git://git.linux-nfs.org/projects/anna/linux-nfs").  It's a merge
> > commit, but one that has quite a bit of conflict resolution.  I also
> > verified that the 2 parent commits of the merge (5085607d2091 and
> > 2c94b8eca1a2) both behave as old kernels did.
> >
> > Thanks
> > Marc
>
> Can you please check if the following patch and/or the 'testing' branch
> in
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/testing
> fixes the issue?
>
> Thanks
>   Trond
> 8<----------------------------------------------
> From 513149607d19bc3821386fb5ac75f8b99fd4b115 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
> Date: Fri, 15 Mar 2019 12:55:59 -0400
> Subject: [PATCH 2/6] SUNRPC: Fix the minimal size for reply buffer allocation
>
> We must at minimum allocate enough memory to be able to see any auth
> errors in the reply from the server.
>
> Fixes: 2c94b8eca1a26 ("SUNRPC: Use au_rslack when computing reply...")
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  net/sunrpc/clnt.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 4216fe33204a..310873895578 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1730,7 +1730,12 @@ call_allocate(struct rpc_task *task)
>         req->rq_callsize = RPC_CALLHDRSIZE + (auth->au_cslack << 1) +
>                            proc->p_arglen;
>         req->rq_callsize <<= 2;
> -       req->rq_rcvsize = RPC_REPHDRSIZE + auth->au_rslack + proc->p_replen;
> +       /*
> +        * Note: the reply buffer must at minimum allocate enough space
> +        * for the 'struct accepted_reply' from RFC5531.
> +        */
> +       req->rq_rcvsize = RPC_REPHDRSIZE + auth->au_rslack + \
> +                       max_t(size_t, proc->p_replen, 2);
>         req->rq_rcvsize <<= 2;
>
>         status = xprt->ops->buf_alloc(task);
> --
> 2.20.1

Hi Trond,

I can confirm that this patch does fix my issue.

Thanks,
Marc
