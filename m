Return-Path: <SRS0=JCn4=V5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82C66C433FF
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Aug 2019 18:24:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 59174206A2
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Aug 2019 18:24:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dIg3/DBv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730700AbfHASYQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Aug 2019 14:24:16 -0400
Received: from mail-vs1-f66.google.com ([209.85.217.66]:41907 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726014AbfHASYQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Aug 2019 14:24:16 -0400
Received: by mail-vs1-f66.google.com with SMTP id 2so49505852vso.8
        for <linux-nfs@vger.kernel.org>; Thu, 01 Aug 2019 11:24:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nXgC9Z/LyD2VzbS7Q/pL0FmizCoMeySoW5c4MVg1mrw=;
        b=dIg3/DBv5oAOkF4GcOifeJGU5L5EiUJxXYdDBx2SJWZGYhYW/F9t03QWTbUvC/UlVK
         cxdMPuqr86wZ1jb8lqBBeLKQOLPB7i+9rcYNchcW/tA05Dl+53fn3Ji8IAjC9KZajUkr
         WTLcYBv3nJFWrPsLykLcEe0pCdUY2HeafK0V+KhUDsRPOFUYMnwgF7OthK8pePpAoKOk
         I22i+MR1oiqHocHEeWRyV9klX4BvmYtn6lPo6kADi52ibCIne3VHekLCY1ycc3w3xuVo
         tFou6aCISdTCERkYC+6nmDFtvbKLmA/Fwv39eMqg4g/keiDw8wwKziaPXxClzbXekb9l
         WCtQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=nXgC9Z/LyD2VzbS7Q/pL0FmizCoMeySoW5c4MVg1mrw=;
        b=Wwb3vSSvRK7n09SbPtXQV1Q3DeXUEWGp/ydFxyJeYvFMlKKo1/Uv6eV+VXYFxoX9JU
         BqLcYGKdOhgGr8JmO4of07VdYrlwNlgMML82XO5shASu6O4ev2CpeWoc6EatEyRNU7cJ
         b7EkXJX4eu6RR6ral/SjLQRi9D4L01rZwdbnsK4ayNbr6gTPUXYZerpDkoVLC1+Ztkg3
         gNHZKkpb7GiX7EyhBURFXlqqB7HrzJAC7UWUePpDrVgd7gy6840/eVooaOGjk/H2e+R8
         uTovLhUB1ttUqKGHxlDqUYAPxoQ5m2RKD5YdcjByS+BYYyTQw7SgeUTv8bm7HZa+R0iG
         +q2A==
X-Gm-Message-State: APjAAAXuotEQYqybf8f6Ia+T0EX+0BwjbgT4eef/KgfetuxLuAsU4MD4
        zz7d33jZwj/qrmftb/QtESM4Dnz+cXvpZBHt8cY=
X-Google-Smtp-Source: APXvYqxjBIyNRFDvdS22/Un5cVC+YhxxA/rBoNTidLA362JzJ6bQDJVH4pD3UCsdTq75fyNyfTZlCP06rlvN/bQvQHY=
X-Received: by 2002:a67:dc1:: with SMTP id 184mr25014153vsn.164.1564683855222;
 Thu, 01 Aug 2019 11:24:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190719220116.GA24373@fieldses.org> <CAN-5tyHdxBcEH0xPV2814nUMEHPCsQ9iD_A7K=W3ZeE6b4OJxg@mail.gmail.com>
 <20190723205846.GB19559@fieldses.org> <CAN-5tyFTRr9KPYAzq-EaOMqDeJU31-qHGsLyCmEtd18OMxCFNQ@mail.gmail.com>
 <CAN-5tyEbwjPNbXKWXv+3=geisjH-i=xKWRqgyXa3v9Xk=OvdEw@mail.gmail.com>
 <20190731215118.GA13311@parsley.fieldses.org> <CAN-5tyGz5M1eMFC=CJUEdTB7cAq-PRis8SJMEnrcr4Svmmy03w@mail.gmail.com>
 <20190801151239.GC17654@fieldses.org> <CAN-5tyE8xdJhs5C_bOo0a9yLRUAvkKi7OLOq47He5P0OR8PGyQ@mail.gmail.com>
 <CAN-5tyEx7-kddfgsvSGAsCD3amMXq-iGLkQN2GdmaXOc19GwkA@mail.gmail.com> <20190801181158.GC19461@fieldses.org>
In-Reply-To: <20190801181158.GC19461@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 1 Aug 2019 14:24:04 -0400
Message-ID: <CAN-5tyEiO=kBQC=pLu_aeVfV+3f3KWFbz_1ooG8qBLoBqFaehQ@mail.gmail.com>
Subject: Re: [PATCH v4 5/8] NFSD check stateids against copy stateids
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Aug 1, 2019 at 2:12 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Thu, Aug 01, 2019 at 02:06:46PM -0400, Olga Kornievskaia wrote:
> > On Thu, Aug 1, 2019 at 11:41 AM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > >
> > > On Thu, Aug 1, 2019 at 11:13 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > >
> > > > On Thu, Aug 01, 2019 at 10:12:11AM -0400, Olga Kornievskaia wrote:
> > > > > On Wed, Jul 31, 2019 at 5:51 PM J. Bruce Fields <bfields@redhat.com> wrote:
> > > > > >
> > > > > > On Wed, Jul 31, 2019 at 05:10:01PM -0400, Olga Kornievskaia wrote:
> > > > > > > I'm having difficulty with this patch because there is no good way to
> > > > > > > know when the copy_notify stateid can be freed. What I can propose is
> > > > > > > to have the linux client send a FREE_STATEID with the copy_notify
> > > > > > > stateid and use that as the trigger to free the state. In that case,
> > > > > > > I'll keep a reference on the parent until the FREE_STATEID is
> > > > > > > received.
> > > > > > >
> > > > > > > This is not in the spec (though seems like a good idea to tell the
> > > > > > > source server it's ok to clean up) so other implementations might not
> > > > > > > choose this approach so we'll have problems with stateids sticking
> > > > > > > around.
> > > > > >
> > > > > > https://tools.ietf.org/html/rfc7862#page-71
> > > > > >
> > > > > >         "If the cnr_lease_time expires while the destination server is
> > > > > >         still reading the source file, the destination server is allowed
> > > > > >         to finish reading the file.  If the cnr_lease_time expires
> > > > > >         before the destination server uses READ or READ_PLUS to begin
> > > > > >         the transfer, the source server can use NFS4ERR_PARTNER_NO_AUTH
> > > > > >         to inform the destination server that the cnr_lease_time has
> > > > > >         expired."
> > > > > >
> > > > > > The spec doesn't really define what "is allowed to finish reading the
> > > > > > file" means, but I think the source server should decide somehow whether
> > > > > > the target's done.  And "hasn't sent a read in cnr_lease_time" seems
> > > > > > like a pretty good conservative definition that would be easy to
> > > > > > enforce.
> > > > >
> > > > > "hasn't send a read in cnr_lease_time" is already enforced.
> > > > >
> > > > > The problem is when the copy did start in normal time, it might take
> > > > > unknown time to complete. If we limit copies to all be done with in a
> > > > > cnr_lease_time or even some number of that, we'll get into problems
> > > > > when files are large enough or network is slow enough that it will
> > > > > make this method unusable.
> > > >
> > > > No, I'm just suggesting that if it's been more than cnr_lease_time since
> > > > the target server last sent a read using this stateid, then we could
> > > > free the stateid.
> > >
> > > That's reasonable. Let me do that.
> >
> > Now that I need a global list for the copy_notify stateids, do you
> > have a preference for either to keep it of the nfs4_client structure
> > or the nfsd_net structure? I store async copies under the nfs4_client
> > structure but the laundromat traverses things in nfsd_net structure.
>
> If copy_notify stateids are associated with a client, then they must
> already be reachable from the client somehow so they can be destroyed at
> the time the client is, right?  I'm saying that without looking at the
> code....

yes, i agree. but since we are taking a reference on a parent stateid
and the copy_notify state is destroyed at the destruction of the
parent id, then we'll never get there (or shouldn't get there). But I
can add something to the client destruction to make sure to delete
anything if it's there.

i was just looking at close_lru and delegation_lru but I guess that's
not a list of delegation or open stateids but rather some complex of
not deleting the stateid right away but moving it to nfs4_ol_stateid
and the list on the nfsd_net. Are you looking for something similar
for the copy_notify state or can I just keep a global list of the
nfs4_client and add and delete of that (not move to the delete later)?

> --b.
