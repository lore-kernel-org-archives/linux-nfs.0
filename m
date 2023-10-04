Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7D02E7C4F5
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Oct 2023 18:54:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S244799AbjJDSyp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Oct 2023 14:54:45 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46878 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S244618AbjJDSye (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Oct 2023 14:54:34 -0400
Received: from mail-lj1-x235.google.com (mail-lj1-x235.google.com [IPv6:2a00:1450:4864:20::235])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8B2601B8
        for <linux-nfs@vger.kernel.org>; Wed,  4 Oct 2023 11:53:58 -0700 (PDT)
Received: by mail-lj1-x235.google.com with SMTP id 38308e7fff4ca-2c29d23bee2so263661fa.0
        for <linux-nfs@vger.kernel.org>; Wed, 04 Oct 2023 11:53:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03; t=1696445636; x=1697050436; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=0KzDJRS7KxkkZ6Oh0+MnmsXHFeSbYVpjE5bfzb8MwZM=;
        b=Ws4qCUkDzsKhsOn+heD62DOk+zU6uH2oy9wkshi+mlDUHsfnDtnXPlzXrojsH8zFlb
         dCf8QESSowRixpMsMkYTxDr8Nh9S+83WJDGy0/1MPG8girIF58TT0KnwtLnhM4flQ8Lf
         AESVHr4Cen7GR9fS51XrjldqKP6MBS0PDw0t4rwY1rv7A9mSIOOnMsD1gAW8yJb1r1ne
         ArByjJJ6JboBXCgWPhLHkpWFFn8TPwDn/svKvooMRki7k7w+69H2HFhfb7fHGcpJIyPZ
         2Gpoc90EunM+8ncdocZtVw4SFjMAGJbKuYNMkNXqisOm0uY3C9GBgdcqZSKMXfr/0sL4
         6l8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1696445636; x=1697050436;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=0KzDJRS7KxkkZ6Oh0+MnmsXHFeSbYVpjE5bfzb8MwZM=;
        b=eXJRBoQUVWGlIXfE4eA6sDLjuE1G6Qfxu+9JvCh/OjtbNIfmNzLrfu4CPBJAXix1S2
         lOLLhJ4AVi5COwJqJOwWuSo0EcIypow1zXFqZj+PkArwUBCqJnIeVVWhfqCQZV3xmu08
         OtZMhrznbnP7zUP5SLMWxaDdZ8fW/jIW8luKN9TBp2RP2P9K47YAMzXMoS73AtzvM1/Q
         /ND/zcKENozfqmiYbMR3N8jw7mhAn8Vf1SCzsj7lWNnZq7QvEb0q8aGJT6VXzZfd7Vqw
         ezK9YFMf//KbDpMnaJFahSnLrmCtUhhh1P8CKurZv3RhxuBO3yzf9/hUQcr7Wl6NTnbT
         4fkg==
X-Gm-Message-State: AOJu0YztzJfy0K0WRJm3QpKcCrxZ3rNsz9aCU9jppH+MCHxqjRuXmqIM
        ajXfdY1rkGyK3/VtxbhkHRrmDaTwx2pJ8UdsbnA2Geg1
X-Google-Smtp-Source: AGHT+IHxMII9E+vZVP07wA14i9ESof8uSHDbdaJohu/0MosOxS8pMOVqtNoNcLxfcQzjOIemgvPAy+EsTmvPTMpcL94=
X-Received: by 2002:a2e:b53a:0:b0:2bc:e36a:9e32 with SMTP id
 z26-20020a2eb53a000000b002bce36a9e32mr2723977ljm.5.1696445636362; Wed, 04 Oct
 2023 11:53:56 -0700 (PDT)
MIME-Version: 1.0
References: <93929ecf62e79670f1e3a1878757fc9fa443aa7c.1688210094.git.bcodding@redhat.com>
In-Reply-To: <93929ecf62e79670f1e3a1878757fc9fa443aa7c.1688210094.git.bcodding@redhat.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Wed, 4 Oct 2023 14:53:44 -0400
Message-ID: <CAN-5tyGf6txJpoJBSzEh75BgZAQ1f4TbZF10Dw25GjeE4Pz=7w@mail.gmail.com>
Subject: Re: [PATCH v3] NFSv4: Fix dropped lock for racing OPEN and delegation return
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     trond.myklebust@hammerspace.com, anna@kernel.org,
        Olga.Kornievskaia@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond/Ben,

Did this ever go to stable? I don't know if I missed a mail from Greg
that it was picked up or it never got picked up because it wasn't
marked for stable?

Thank you.

On Sat, Jul 1, 2023 at 8:13=E2=80=AFAM Benjamin Coddington <bcodding@redhat=
.com> wrote:
>
> Commmit f5ea16137a3f ("NFSv4: Retry LOCK on OLD_STATEID during delegation
> return") attempted to solve this problem by using nfs4's generic async er=
ror
> handling, but introduced a regression where v4.0 lock recovery would hang=
.
> The additional complexity introduced by overloading that error handling i=
s
> not necessary for this case.  This patch expects that commit to be
> reverted.
>
> The problem as originally explained in the above commit is:
>
>     There's a small window where a LOCK sent during a delegation return c=
an
>     race with another OPEN on client, but the open stateid has not yet be=
en
>     updated.  In this case, the client doesn't handle the OLD_STATEID err=
or
>     from the server and will lose this lock, emitting:
>     "NFS: nfs4_handle_delegation_recall_error: unhandled error -10024".
>
> Fix this by using the old_stateid refresh helpers if the server replies
> with OLD_STATEID.
>
> Suggested-by: Trond Myklebust <trondmy@hammerspace.com>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 6bb14f6cfbc0..f350f41e1967 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7180,8 +7180,15 @@ static void nfs4_lock_done(struct rpc_task *task, =
void *calldata)
>                 } else if (!nfs4_update_lock_stateid(lsp, &data->res.stat=
eid))
>                         goto out_restart;
>                 break;
> -       case -NFS4ERR_BAD_STATEID:
>         case -NFS4ERR_OLD_STATEID:
> +               if (data->arg.new_lock_owner !=3D 0 &&
> +                       nfs4_refresh_open_old_stateid(&data->arg.open_sta=
teid,
> +                                       lsp->ls_state))
> +                       goto out_restart;
> +               else if (nfs4_refresh_lock_old_stateid(&data->arg.lock_st=
ateid, lsp))
> +                       goto out_restart;
> +               fallthrough;
> +       case -NFS4ERR_BAD_STATEID:
>         case -NFS4ERR_STALE_STATEID:
>         case -NFS4ERR_EXPIRED:
>                 if (data->arg.new_lock_owner !=3D 0) {
> --
> 2.40.1
>
