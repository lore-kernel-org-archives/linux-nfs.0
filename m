Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EF6AECDE4B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 19:32:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D9F00204FD
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 19:32:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZM89Hh2t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9F00204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726140AbeKIFJM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 00:09:12 -0500
Received: from mail-vs1-f65.google.com ([209.85.217.65]:36486 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725884AbeKIFJL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2018 00:09:11 -0500
Received: by mail-vs1-f65.google.com with SMTP id v205so12312303vsc.3
        for <linux-nfs@vger.kernel.org>; Thu, 08 Nov 2018 11:32:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JDvT6NrE4mY7odF9izgWrLoTA/FObaJzTviUBYkU7hQ=;
        b=ZM89Hh2tC/3WN+euXFzHG+M6HgxdRK8PVar+RWl7IfaX2ArVC7PIJwOXV9Vx4d+5Ay
         fpA0bhzWZLzvntjLITfL0f/MyflkuW986U0jnlksCUfpZ/JqUjIiI7Pq5JdoX/35FjUc
         cO9JdQJzroQXXE5cSean8LwxsoTG7lPRCXN+QLg2OAdHQYBMDxz5BkuN/fQ06bx826Fm
         sPYj3qSz9qxDU8KIdGOkG9JgMax6rmGBFWwC6ruryEeGdkmsT2Z3L0pLXmjUa/bIn/wp
         n1TGmYWEYpe09PzQNxA0jm7VVfyRQhxnq/WCfKsewP6oDgntLgoDL3XIyAui/A4ANw3q
         rM0Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=JDvT6NrE4mY7odF9izgWrLoTA/FObaJzTviUBYkU7hQ=;
        b=ngmVMaEBPCjN4733KjTE1R8vhcGaXL4PnhfeqIkt14qMZSmmDBNTb1OpWh7GURfE9n
         6AnO3wyTIlb0Bp1vWXlwSUesUS6lBuVIZGqFBox1ezPz/YqQShcIciEHkKQD4G1rnOjY
         ONZ4dYUEAf6VU1Q+Q2c+4YNW+6kGDMkpxXBI4zbS2Jk/bU2B2OnCH8fYtbbHsPfsIGow
         hA8SPaKfceunZOTJ2PfylrCDo0JcNNIcarJqD8gKvo2CAeX+QbpnaHuy/WvSU7IoDBux
         /TW0AqYZ5+zAzom3vZhwa8GlYx4+s2X3iSTrgxuBRmqHmfqkrCvie3SZregChtpFORca
         PXdA==
X-Gm-Message-State: AGRZ1gLUCgTNLhB3zed5j6Xfn9jwpWHPjCf8Jm7nWK1d8HoHq9KhU/hg
        L53zcgF4g+03x3KLuQxWWrHWW+t2YAOgqkKzIWY=
X-Google-Smtp-Source: AJdET5cdpBUqOyv5wjr+zU8rpw29yW8/ourGUpubQsMZu/jCdrtv+SBbNDsmjZY8yg2KsRmjaV0vHuILMkG3RhAJx1g=
X-Received: by 2002:a67:f453:: with SMTP id r19mr2585627vsn.164.1541705536603;
 Thu, 08 Nov 2018 11:32:16 -0800 (PST)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-13-olga.kornievskaia@gmail.com> <20181107185753.GB19588@fieldses.org>
 <CAN-5tyH7XWsnf8VU-sMDTcxFdvk-Q7=ST5hHz=uxSk01xDk7ug@mail.gmail.com>
 <20181108192502.GB6090@fieldses.org> <20181108192759.GC6090@fieldses.org>
In-Reply-To: <20181108192759.GC6090@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 8 Nov 2018 14:32:04 -0500
Message-ID: <CAN-5tyHuv_UbCVppP_gcsKBoU-a=u26nA1kw3QAgtyL1+xV1bQ@mail.gmail.com>
Subject: Re: [PATCH v1 12/13] NFSD: allow inter server COPY to have a STALE
 source server fh
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 8, 2018 at 2:28 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Thu, Nov 08, 2018 at 02:25:02PM -0500, J. Bruce Fields wrote:
> > On Thu, Nov 08, 2018 at 01:51:58PM -0500, Olga Kornievskaia wrote:
> > > On Wed, Nov 7, 2018 at 1:57 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > >
> > > > On Fri, Oct 19, 2018 at 11:29:04AM -0400, Olga Kornievskaia wrote:
> > > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > > >
> > > > > The inter server to server COPY source server filehandle
> > > > > is a foreign filehandle as the COPY is sent to the destination
> > > > > server.
> > > >
> > > > Compounds can do a lot of different strange things, and I'm not
> > > > convinced this code handles every case correctly.  Examples: I think
> > > > that
> > > >
> > > >         PUTFH
> > > >         TEST_STATEID
> > > >         SAVEFH
> > > >         COPY
> > > >
> > > > will incorrectly return nfserr_stale if the PUTHF gets a foreign
> > > > filehandle, even though that filehandle is only used as the source of
> > > > the COPY.  And:
> > > >
> > > >         PUTFH
> > > >         SAVEFH
> > > >         RENAME
> > > >         COPY
> > > >
> > > > will pass an unverified source filehandle to rename.
> > > >
> > > > I can think of a couple ways to get this right for certain:
> > > >
> > > >         - delay all filehandle verification till the time the filehandle
> > > >           isused.  That would make checking this simple, but it would
> > > >           change our behavior so, for example PUTFH+READ with a bad
> > > >           filehandle will return the error on the READ where it used to
> > > >           return it on the PUTFH.  I don't know if that's a problem.
> > > >
> > > >         - somewhere at the start of nfsd4_proc_compound, do one pass
> > > >           through the compound checking where the filehandles will be
> > > >           used and marking those ops that can skip checking.  E.g.:
> > > >
> > > >                 nfsd4_op *current, *saved
> > > >
> > > >                 foreach op in compound:
> > > >                         - if op is putfh:
> > > >                                 current := op
> > > >                         - if op is savefh:
> > > >                                 saved := current
> > > >                         - if op is restorefh:
> > > >                                 current := saved
> > > >                         - etc.
> > > >                         - if op is copy:
> > > >                                 mark_no_verify(saved)
> > > >
> > > >           Or something like that.
> > >
> > > Do you have a preference over the 2 proposed methods? I'm not sure if
> > > there is anything wrong with returning ERR_STALE  on READ instead of
> > > the PUTFH but for historical reasons it seems wrong to change it. Thus
> > > I'd say doing it the 2nd way is better. But then 2nd approach adds an
> > > overhead of going thru operations twice for any compound. Is that
> > > acceptable?
> >
> > I think so.  Most compounds are pretty short and I don't think it'll be
> > a big deal.
>
> So, yes, could you try the second approach?

Yes of course.

> I've been working on the 1st approach--I have a patch here and I may
> experiment with it some more.  But I'm starting to think that the
> separate scan will work better.
>
> --b.
