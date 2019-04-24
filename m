Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1F9FC282E1
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 19:09:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A06392183E
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 19:09:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rPRdVCdx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729959AbfDXTJ4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 15:09:56 -0400
Received: from mail-lf1-f65.google.com ([209.85.167.65]:37002 "EHLO
        mail-lf1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727459AbfDXTJz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 15:09:55 -0400
Received: by mail-lf1-f65.google.com with SMTP id h126so4897020lfh.4;
        Wed, 24 Apr 2019 12:09:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=6k0hAFc2DRIye5Fv2Jz6AR2EVYYSQF4aAKZfcEEK4V4=;
        b=rPRdVCdx071xmpPg+Xmd0OxYQ0ksZ1xu3elB5Smq/1BHyx22vOOmdNxdRqTZ1cHnOH
         DIDfjxCH/YbF60nKNVxhotUvcMUV6mhcHnHM4CYEIy17HswGW+QTNkcd/MSS5/I62nIx
         KtX3vOwvEp14xMCRvixXKTgJlDOh9eoDskD8QGkFWBhesdLFJmGQH0afQGafCvVf1fyb
         zEF0DyLIQt/yrE/TaNrSANfcT5Awg9hpq8eXrOzejSYI7JppNR5796sEbL2ytZqttyQp
         qVNzWTOVrGQ3sPjTVvi/GUsNRXA+8oM23jrkMKUjHTuzFUZ2Ta6MFyWMkgZ9EgH3YexN
         RCjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=6k0hAFc2DRIye5Fv2Jz6AR2EVYYSQF4aAKZfcEEK4V4=;
        b=ZshlQtMSpF4kIIcB2Nkl458ZWC12DGJC9ayC0gOV791DItHewKWDbfgtF6W27ikwdB
         yymSx20trFuL5Y4bNU6nxONEAFfBd+dSWgK6poWRLl+tNJAjr25AMTQJSjugVuasT8Ta
         iem3yDAnBkULun6huNz1PNwvoGUfjdPrmSe99+bEzNwWcl0YgdFwAbSdcZkzZtdH8YSg
         3z7NdIZ65VnJRhJ4kldpwxJfKDGCEdxgnwD0Fwe3617bOeYqmHNsiCM1BePYLV7AHJ51
         QOfW43n9wV+A3M23EmPoj5BJlUBNrWKdT3LUhL+qfqzyAUHNSiuTcRFsm410KRuj1Env
         nHgw==
X-Gm-Message-State: APjAAAUHz4s516SssOppL0OVNzo17fmN6lg3TRMG2DURyl+0BsNrUfs5
        k0Yy7ghE2HqJg+luR8uUd7M4Oh6V5OK8AYEhsg==
X-Google-Smtp-Source: APXvYqx5/VP+j6WsVj441n7DbIbILoSZ3CSkFsBbTyWxmngCYUL5nTokCMU4i4pHnatiaghYDCkKx4sQpv55nF96un0=
X-Received: by 2002:a19:c113:: with SMTP id r19mr18455110lff.64.1556132992853;
 Wed, 24 Apr 2019 12:09:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190422163424.19402-1-jlayton@kernel.org> <20190422163424.19402-2-jlayton@kernel.org>
 <87wojl61s5.fsf@notabene.neil.brown.name> <20190424135854.GB20542@fieldses.org>
 <2b131f18-1df4-790c-a548-3155a0677c34@RedHat.com> <20190424154735.GC20542@fieldses.org>
In-Reply-To: <20190424154735.GC20542@fieldses.org>
From:   Pavel Shilovsky <piastryyy@gmail.com>
Date:   Wed, 24 Apr 2019 12:09:41 -0700
Message-ID: <CAKywueQBSwecUpr7CerLSzFT07F55sLC3vF=xFMV13uCn5_iOA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] nfsd: wake waiters blocked on file_lock before
 deleting it
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.com>,
        Jeff Layton <jlayton@kernel.org>, slawek1211@gmail.com,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>,
        Steve French <smfrench@gmail.com>,
        Ronnie Sahlberg <lsahlber@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Yes, I think there is a bug here, thanks!

If cinode->can_cache_brlcks is false we should return 1 but the code
will return 0 if coming from the "try_again" label. We also need to
call locks_delete_block unconditionally at the end of the function.

--
Best regards,
Pavel Shilovsky

=D1=81=D1=80, 24 =D0=B0=D0=BF=D1=80. 2019 =D0=B3. =D0=B2 08:48, J. Bruce Fi=
elds <bfields@fieldses.org>:
>
> On Wed, Apr 24, 2019 at 11:29:59AM -0400, Steve Dickson wrote:
> >
> >
> > On 4/24/19 9:58 AM, J. Bruce Fields wrote:
> > > Steve, see Neil's comment, is there a cifs bug here?
> > Looking into it...
>
> I was thinking Steve French, though I'm sure he wouldn't mind if you
> fixed cifs bugs.  Too many Steves!
>
> --b.
>
> >
> > steved.
> > >
> > > --b.
> > >
> > > On Tue, Apr 23, 2019 at 09:47:06AM +1000, NeilBrown wrote:
> > >> On Mon, Apr 22 2019, Jeff Layton wrote:
> > >>
> > >>> After a blocked nfsd file_lock request is deleted, knfsd will send =
a
> > >>> callback to the client and then free the request. Commit 16306a61d3=
b7
> > >>> ("fs/locks: always delete_block after waiting.") changed it such th=
at
> > >>> locks_delete_block is always called on a request after it is awoken=
,
> > >>> but that patch missed fixing up blocked nfsd request handling.
> > >>>
> > >>> Call locks_delete_block on the block to wake up any locks still blo=
cked
> > >>> on the nfsd lock request before freeing it. Some of its callers alr=
eady
> > >>> do this however, so just remove those calls.
> > >>>
> > >>> URL: https://bugzilla.kernel.org/show_bug.cgi?id=3D203363
> > >>> Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting."=
)
> > >>> Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
> > >>> Cc: Neil Brown <neilb@suse.com>
> > >>> Cc: stable@vger.kernel.org
> > >>> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > >>> ---
> > >>>  fs/nfsd/nfs4state.c | 3 +--
> > >>>  1 file changed, 1 insertion(+), 2 deletions(-)
> > >>>
> > >>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > >>> index 6a45fb00c5fc..e87e15df2044 100644
> > >>> --- a/fs/nfsd/nfs4state.c
> > >>> +++ b/fs/nfsd/nfs4state.c
> > >>> @@ -265,6 +265,7 @@ find_or_allocate_block(struct nfs4_lockowner *l=
o, struct knfsd_fh *fh,
> > >>>  static void
> > >>>  free_blocked_lock(struct nfsd4_blocked_lock *nbl)
> > >>>  {
> > >>> + locks_delete_block(&nbl->nbl_lock);
> > >>>   locks_release_private(&nbl->nbl_lock);
> > >>
> > >> Thanks for tracking this down.
> > >>
> > >> An implication of this bug and fix is that we need to be particularl=
y
> > >> careful to make sure locks_delete_block() is called on all relevant
> > >> paths.
> > >> Can we make that easier?  My first thought was to include the call i=
n
> > >> locks_release_private, but lockd calls the two quite separately and =
it
> > >> certainly seems appropriate that locks_delete_block should be called
> > >> asap, but locks_release_private() can be delayed.
> > >>
> > >> Also cifs calls locks_delete_block, but never calls
> > >> locks_release_private, so it wouldn't help there.
> > >>
> > >> Looking at cifs, I think there is a call missing there too.
> > >> cifs_posix_lock_set() *doesn't* always call locks_delete_block() aft=
er
> > >> waiting.  In particular, if ->can_cache_brlcks becomes true while
> > >> waiting then I don't think the behaviour is right.... though I'm not
> > >> sure it is right for other reasons.  It looks like the return value
> > >> should be 1 in that case, but it'll be zero.
> > >>
> > >> But back to my question about making it easier, move the BUG_ON()
> > >> calls from locks_free_lock() into locks_release_private().
> > >>
> > >> ??
> > >>
> > >> Thanks,
> > >> NeilBrown
> > >>
> > >>
> > >>>   kfree(nbl);
> > >>>  }
> > >>> @@ -293,7 +294,6 @@ remove_blocked_locks(struct nfs4_lockowner *lo)
> > >>>           nbl =3D list_first_entry(&reaplist, struct nfsd4_blocked_=
lock,
> > >>>                                   nbl_lru);
> > >>>           list_del_init(&nbl->nbl_lru);
> > >>> -         locks_delete_block(&nbl->nbl_lock);
> > >>>           free_blocked_lock(nbl);
> > >>>   }
> > >>>  }
> > >>> @@ -4863,7 +4863,6 @@ nfs4_laundromat(struct nfsd_net *nn)
> > >>>           nbl =3D list_first_entry(&reaplist,
> > >>>                                   struct nfsd4_blocked_lock, nbl_lr=
u);
> > >>>           list_del_init(&nbl->nbl_lru);
> > >>> -         locks_delete_block(&nbl->nbl_lock);
> > >>>           free_blocked_lock(nbl);
> > >>>   }
> > >>>  out:
> > >>> --
> > >>> 2.20.1
> > >
> > >
