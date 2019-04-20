Return-Path: <SRS0=Y3U+=SW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD9C1C282DD
	for <linux-nfs@archiver.kernel.org>; Sat, 20 Apr 2019 10:19:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A572A2087B
	for <linux-nfs@archiver.kernel.org>; Sat, 20 Apr 2019 10:19:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555755575;
	bh=4okiLuBocXYLwW2FEdXPp3WM0diZxPtvqTKe0B8EUb4=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:List-ID:From;
	b=tqzd/P10E/2NivpRic5piJQuq8ROhJDs+Q0tjjTrIbwHhuAhjVOVbRs8OEfhZgqcr
	 nTuT4ZvJqs+N2YgI3i3RZ7654YjRRuHlafIUWd3LnLgDskvAFcotbAnhonLnFAh3X8
	 R4gpGz8JNNxhl7tUx/0k1mUahK+1R5/V8eajZWyM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726075AbfDTKTf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 20 Apr 2019 06:19:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:37360 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725920AbfDTKTf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Apr 2019 06:19:35 -0400
Received: from mail-ed1-f54.google.com (mail-ed1-f54.google.com [209.85.208.54])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1943D2087B
        for <linux-nfs@vger.kernel.org>; Sat, 20 Apr 2019 10:19:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1555755574;
        bh=4okiLuBocXYLwW2FEdXPp3WM0diZxPtvqTKe0B8EUb4=;
        h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
        b=pfANx158qjEc/ncWABx/AKaRk8dOpfVOZiRD1+QOWG0bQcH2xR/gfnrG9J8YKhKwA
         WcDd2XSETI81pF/lVLvnTQ5Avxhc7WFIggu0XtvthgKq9BgjSi14fNNCeLVyV6D3Yf
         oKUpglqr2DDs76dE47nduTAipJM4ss2KiJ/vMyDI=
Received: by mail-ed1-f54.google.com with SMTP id u23so5850261eds.9
        for <linux-nfs@vger.kernel.org>; Sat, 20 Apr 2019 03:19:34 -0700 (PDT)
X-Gm-Message-State: APjAAAUtsVvgvCF6msmq7jRM/FCf+2QvbnJqlglM6lld9zDg7sr1iW+2
        YrPzmd5EBxSy9lABRYhWWWvlnicBwplynVbC4vSThQ==
X-Google-Smtp-Source: APXvYqwpXnZyzHYfJENHCEJKDli1dGVrqN3v0+uW/YIAMU7UOBmCX5esik0I1Epx/bTEH2QkMm22gsVNLIUY5VsfKqM=
X-Received: by 2002:a50:9317:: with SMTP id m23mr5503659eda.114.1555755572693;
 Sat, 20 Apr 2019 03:19:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190420101548.8552-1-jlayton@kernel.org>
In-Reply-To: <20190420101548.8552-1-jlayton@kernel.org>
From:   Jeff Layton <jlayton@kernel.org>
Date:   Sat, 20 Apr 2019 06:19:21 -0400
X-Gmail-Original-Message-ID: <CAOhYWNJ6HJP5XB4jrg7_mTs1bCrc_5tzMjgdTu-6+v2+-ABkLw@mail.gmail.com>
Message-ID: <CAOhYWNJ6HJP5XB4jrg7_mTs1bCrc_5tzMjgdTu-6+v2+-ABkLw@mail.gmail.com>
Subject: Re: [PATCH] nfsd: wake waiters blocked on file_lock before deleting it
To:     Bruce Fields <bfields@fieldses.org>
Cc:     slawek1211@gmail.com, NeilBrown <neilb@suse.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Apr 20, 2019 at 6:16 AM Jeff Layton <jlayton@kernel.org> wrote:
>
> After a blocked nfsd file_lock request is deleted, knfsd will send a
> callback to the client and then free the request. Commit 16306a61d3b7
> ("fs/locks: always delete_block after waiting.") changed it such that
> locks_delete_block is always called on a request after it is awoken,
> but that patch missed fixing up blocked nfsd request handling.
>
> Call locks_delete_block on the block to wake up any locks still blocked
> on the nfsd lock request before sending the callback.
>
> URL: https://bugzilla.kernel.org/show_bug.cgi?id=203363
> Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting.")
> Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
> Cc: Neil Brown <neilb@suse.com>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4state.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 6a45fb00c5fc..1960e8fd9ad1 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -298,6 +298,14 @@ remove_blocked_locks(struct nfs4_lockowner *lo)
>         }
>  }
>
> +static void
> +nfsd4_cb_notify_lock_prepare(struct nfsd4_callback *cb)
> +{
> +       struct nfsd4_blocked_lock       *nbl = container_of(cb,
> +                                               struct nfsd4_blocked_lock, nbl_cb);
> +       locks_delete_block(&nbl->nbl_lock);
> +}
> +
>  static int
>  nfsd4_cb_notify_lock_done(struct nfsd4_callback *cb, struct rpc_task *task)
>  {
> @@ -325,6 +333,7 @@ nfsd4_cb_notify_lock_release(struct nfsd4_callback *cb)
>  }
>
>  static const struct nfsd4_callback_ops nfsd4_cb_notify_lock_ops = {
> +       .prepare        = nfsd4_cb_notify_lock_prepare,
>         .done           = nfsd4_cb_notify_lock_done,
>         .release        = nfsd4_cb_notify_lock_release,
>  };
> --
> 2.20.1
>

This should also go to stable I think. If you end up picking this up,
can you add the Cc: for stable as well?

Thanks,
-- 
Jeff Layton <jlayton@kernel.org>
