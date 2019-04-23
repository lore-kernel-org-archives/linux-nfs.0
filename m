Return-Path: <SRS0=AvAq=SZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56116C10F14
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 10:57:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 20361214AE
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 10:57:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556017069;
	bh=CAEh/OqemTNM7MKV0ZJ2UfJubusChaOsNFpBv3E7WNI=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:List-ID:From;
	b=2VXrPSqyleatvtfM8scBKtjewKQS8ZN051GSs8EyDY4/G7fVxl5P6fOBVg2VaA3rW
	 TWUJhf3KRP6aQMBs/+KHWmiFW+wmSDwm9nFoCnCvpHYnfRRPFwvU1nxAIF6ao3McWX
	 oTU5rDLByePA1UXIq48EjrXUYb7w/5Rr9xp+ZWC0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727168AbfDWK5s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Apr 2019 06:57:48 -0400
Received: from mail.kernel.org ([198.145.29.99]:43662 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726150AbfDWK5s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Apr 2019 06:57:48 -0400
Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com [209.85.208.51])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8DCBB214AE
        for <linux-nfs@vger.kernel.org>; Tue, 23 Apr 2019 10:57:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1556017066;
        bh=CAEh/OqemTNM7MKV0ZJ2UfJubusChaOsNFpBv3E7WNI=;
        h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
        b=nx1L+JJgECMkHNIggruxL+j1TKdp0bAUhbga+XqoKAfzTOo9td/D94JeA2yesnWx8
         cMI+nhmsUy9T84FxWF96NIFcIXyP8SBOEg1BD4ncQs3FRAS22LHekfrESnL31sDtqj
         vhmDVzpznW5eOdbrTnoZb9u28n5Epz7UMTN5x704=
Received: by mail-ed1-f51.google.com with SMTP id k92so12172730edc.12
        for <linux-nfs@vger.kernel.org>; Tue, 23 Apr 2019 03:57:46 -0700 (PDT)
X-Gm-Message-State: APjAAAXFa3ktBKHXqz/ZgjYo9xTWAKqQzTiCqDB8gdn8QyRozwX9D8cl
        3VtEMRVFNGOvawiOMsXHrc8Zh7OPSaR4aHl9JJlU9A==
X-Google-Smtp-Source: APXvYqz86piKmX/b3jcPNAbmbl6G7fETJeR2kHScnN1pe7g9eGjvbBVtPulMC657cSBs745RDPChea6ceVsoxVQzQC8=
X-Received: by 2002:a17:906:6c0d:: with SMTP id j13mr11934196ejr.249.1556017065152;
 Tue, 23 Apr 2019 03:57:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190422163424.19402-1-jlayton@kernel.org> <20190422163424.19402-2-jlayton@kernel.org>
 <87wojl61s5.fsf@notabene.neil.brown.name>
In-Reply-To: <87wojl61s5.fsf@notabene.neil.brown.name>
From:   Jeff Layton <jlayton@kernel.org>
Date:   Tue, 23 Apr 2019 06:57:33 -0400
X-Gmail-Original-Message-ID: <CAOhYWN+qtb3fRRbxJBMOCyyivc5-rYAfeVZ362HxWjett+UGHQ@mail.gmail.com>
Message-ID: <CAOhYWN+qtb3fRRbxJBMOCyyivc5-rYAfeVZ362HxWjett+UGHQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] nfsd: wake waiters blocked on file_lock before
 deleting it
To:     NeilBrown <neilb@suse.com>
Cc:     Bruce Fields <bfields@fieldses.org>, slawek1211@gmail.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 22, 2019 at 7:47 PM NeilBrown <neilb@suse.com> wrote:
>
> On Mon, Apr 22 2019, Jeff Layton wrote:
>
> > After a blocked nfsd file_lock request is deleted, knfsd will send a
> > callback to the client and then free the request. Commit 16306a61d3b7
> > ("fs/locks: always delete_block after waiting.") changed it such that
> > locks_delete_block is always called on a request after it is awoken,
> > but that patch missed fixing up blocked nfsd request handling.
> >
> > Call locks_delete_block on the block to wake up any locks still blocked
> > on the nfsd lock request before freeing it. Some of its callers already
> > do this however, so just remove those calls.
> >
> > URL: https://bugzilla.kernel.org/show_bug.cgi?id=203363
> > Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting.")
> > Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
> > Cc: Neil Brown <neilb@suse.com>
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > ---
> >  fs/nfsd/nfs4state.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 6a45fb00c5fc..e87e15df2044 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -265,6 +265,7 @@ find_or_allocate_block(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
> >  static void
> >  free_blocked_lock(struct nfsd4_blocked_lock *nbl)
> >  {
> > +     locks_delete_block(&nbl->nbl_lock);
> >       locks_release_private(&nbl->nbl_lock);
>
> Thanks for tracking this down.
>
> An implication of this bug and fix is that we need to be particularly
> careful to make sure locks_delete_block() is called on all relevant
> paths.
> Can we make that easier?  My first thought was to include the call in
> locks_release_private, but lockd calls the two quite separately and it
> certainly seems appropriate that locks_delete_block should be called
> asap, but locks_release_private() can be delayed.
>
> Also cifs calls locks_delete_block, but never calls
> locks_release_private, so it wouldn't help there.
>
> Looking at cifs, I think there is a call missing there too.
> cifs_posix_lock_set() *doesn't* always call locks_delete_block() after
> waiting.  In particular, if ->can_cache_brlcks becomes true while
> waiting then I don't think the behaviour is right.... though I'm not
> sure it is right for other reasons.  It looks like the return value
> should be 1 in that case, but it'll be zero.
>
> But back to my question about making it easier, move the BUG_ON()
> calls from locks_free_lock() into locks_release_private().
>
> ??
>

That sounds like a fine idea. I was thinking about putting all of the
BUG_ONs there in a separate function that both spots could call, but
moving them into locks_release_private should work just as well. Care
to propose a patch?
--
Jeff Layton <jlayton@kernel.org>
