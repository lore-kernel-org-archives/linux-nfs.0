Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BBD3C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:48:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5AFA5218D2
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:48:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556113694;
	bh=n88aMz6pFtTGlg0CCGpnIxsIOq+t1ShnZTefBtlursU=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:List-ID:From;
	b=QsX2hxTfjuY0/nVLrfcxdH6WsOMlqNz4qdE/EBUysLbsGla5SkYQmlt6Gutacq4bu
	 w6KEL0gMujvDP2qXhwE37YxOGeCawsJmfTikm/kp/kUkx+KiOf54Q3htaGSmn8Jb0W
	 5T9Urg00G96R5yMWqQPiOkTQ/gTh9pB4qUVmDik8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726524AbfDXNsN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:48:13 -0400
Received: from mail.kernel.org ([198.145.29.99]:46478 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725978AbfDXNsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Apr 2019 09:48:13 -0400
Received: from mail-ed1-f52.google.com (mail-ed1-f52.google.com [209.85.208.52])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1DBB921900
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 13:48:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1556113692;
        bh=n88aMz6pFtTGlg0CCGpnIxsIOq+t1ShnZTefBtlursU=;
        h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
        b=YI47D50MJmO56GeILZOT8QJ61KmVDcw5TXirNOuvKc+wpvfix9BifmZyB5NA41WiC
         LLHG1MF2Rh166oBauPRpXh1nApom40QH+OtIu4gi18ThOQiMW+ydw7qHJN+pnJyACH
         CNXXCrg+J4CPF2OjcA3Y06GptYhzVrFrhF3pV1tM=
Received: by mail-ed1-f52.google.com with SMTP id g6so15973844edc.8
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 06:48:12 -0700 (PDT)
X-Gm-Message-State: APjAAAVLn4Ku25WwQtycsDkqK+DwErsWog3NnjI4edHmqw3Cbz/vo0kX
        xLOYEBrlOD4EifQl8xjP6II5BHyxxh4a9XgmSmNMNg==
X-Google-Smtp-Source: APXvYqxK/M3zg3Ht1zx6LjSVSJO54/ubORrzCw5X+bg0rJsoAn7UIQ0G7kVJOM5jms48jCSG3XzYp8XsFljeKIwGRPs=
X-Received: by 2002:a50:9317:: with SMTP id m23mr20443937eda.114.1556113690630;
 Wed, 24 Apr 2019 06:48:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190422163424.19402-1-jlayton@kernel.org> <20190422163424.19402-2-jlayton@kernel.org>
 <87wojl61s5.fsf@notabene.neil.brown.name> <CAOhYWN+qtb3fRRbxJBMOCyyivc5-rYAfeVZ362HxWjett+UGHQ@mail.gmail.com>
 <87r29s5fiv.fsf@notabene.neil.brown.name>
In-Reply-To: <87r29s5fiv.fsf@notabene.neil.brown.name>
From:   Jeff Layton <jlayton@kernel.org>
Date:   Wed, 24 Apr 2019 09:47:59 -0400
X-Gmail-Original-Message-ID: <CAOhYWN+wgm9gVPkGW=jh+WUt0T_Nn1zs=BZAKt8y-b50dWM4zw@mail.gmail.com>
Message-ID: <CAOhYWN+wgm9gVPkGW=jh+WUt0T_Nn1zs=BZAKt8y-b50dWM4zw@mail.gmail.com>
Subject: Re: [PATCH] locks: move checks from locks_free_lock() to locks_release_private()
To:     NeilBrown <neilb@suse.com>
Cc:     Bruce Fields <bfields@fieldses.org>, slawek1211@gmail.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Apr 23, 2019 at 10:00 PM NeilBrown <neilb@suse.com> wrote:
>
>
> Code that allocates locks using locks_alloc_lock() will free it
> using locks_free_lock(), and will benefit from the BUG_ON()
> consistency checks therein.
>
> However some code (nfsd and lockd) allocate a lock embedded in
> some other data structure, and so free the lock themselves after
> calling locks_release_private().  This path does not benefit from
> the consistency checks.
>
> To help catch future errors, move the BUG_ON() checks to
> locks_release_private() - which locks_free_lock() already calls.
> This ensures that all users for locks will find out if the lock
> isn't detached properly before being free.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/locks.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/fs/locks.c b/fs/locks.c
> index 71d0c6c2aac5..456a3782c6ca 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -352,6 +352,12 @@ EXPORT_SYMBOL_GPL(locks_alloc_lock);
>
>  void locks_release_private(struct file_lock *fl)
>  {
> +       BUG_ON(waitqueue_active(&fl->fl_wait));
> +       BUG_ON(!list_empty(&fl->fl_list));
> +       BUG_ON(!list_empty(&fl->fl_blocked_requests));
> +       BUG_ON(!list_empty(&fl->fl_blocked_member));
> +       BUG_ON(!hlist_unhashed(&fl->fl_link));
> +
>         if (fl->fl_ops) {
>                 if (fl->fl_ops->fl_release_private)
>                         fl->fl_ops->fl_release_private(fl);
> @@ -371,12 +377,6 @@ EXPORT_SYMBOL_GPL(locks_release_private);
>  /* Free a lock which is not in use. */
>  void locks_free_lock(struct file_lock *fl)
>  {
> -       BUG_ON(waitqueue_active(&fl->fl_wait));
> -       BUG_ON(!list_empty(&fl->fl_list));
> -       BUG_ON(!list_empty(&fl->fl_blocked_requests));
> -       BUG_ON(!list_empty(&fl->fl_blocked_member));
> -       BUG_ON(!hlist_unhashed(&fl->fl_link));
> -
>         locks_release_private(fl);
>         kmem_cache_free(filelock_cache, fl);
>  }
> --
> 2.14.0.rc0.dirty
>

Looks good to me. Bruce, would you mind picking this up for the next
merge window? I don't have any other file locking patches queued up
for v5.2, and I hate to send Linus a PR for just this.

Either way:

Reviewed-by: Jeff Layton <jlayton@kernel.org>
