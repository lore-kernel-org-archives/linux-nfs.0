Return-Path: <SRS0=5YGM=OL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D6AC04EB8
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 15:20:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A1E0E20851
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 15:20:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lJ1hH8uz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1E0E20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725869AbeLBPUE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 10:20:04 -0500
Received: from mail-vk1-f196.google.com ([209.85.221.196]:43955 "EHLO
        mail-vk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725856AbeLBPUD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 10:20:03 -0500
Received: by mail-vk1-f196.google.com with SMTP id o130so2333968vke.10;
        Sun, 02 Dec 2018 07:19:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Rns7xDRBC7nKomCqQohCAxaivC1kID20oRESu5xovcI=;
        b=lJ1hH8uzRmHbO7KORfFyro/r+L8qHmgClbt4gJSkPEShZaRlPUteDdtAkyhMl8IFyU
         UtQZFI9+Uh/aQ3zSt2Kg87dfCoezl76D1qIgZiDl90y0X796FKhJRUg5JYJLmohUYzRA
         aN8ikxO4Gb3ZPw3wzqUt1AihsrSLQQdhd+e1j0SdNPwtrkr9vXPcruYv3wG9SY/mWzN3
         ayFA/1pH3Ao3b13wg9gBneURRcQzS1mrtjJNxce0FcRYVNFpwwi+4yWu477fGb7OFDAR
         0NeRpN7laEwwDdFCL8pxHKsCgu1/uRpkK7aMtLWn/PRZm/YLC0pcUEjRRYdlR2nOFMpo
         viTg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Rns7xDRBC7nKomCqQohCAxaivC1kID20oRESu5xovcI=;
        b=I5OqvsGqX4Rkhb1R3iPGJWl3KujS7ahcKchkAxU1XONj1VkE4bDF6nO+WqD98d81tp
         EEfgqI9TjFQsi2FhWg584ZslS7C+ie8swTDGp19SLi4dxFYuQocDXICeLdQcze/0fUtN
         0Yo1TIo71V4q4cL40mBCxkZrktYZHvrJ6bMXqGSQN2zpGmQW+6KMFFWOCthfSdy7VPeS
         XTJmu3YQKp6an1XZIiaMY2Dh5WNloGulgqukv0Vu3wSx2nSjNC6ssWa/ajlPK4HjubK6
         IJG5wy1MOpxBcuygR3fG2tO7b5Wv8lmDqDrcXJsnwdeBrVPu9OII/q5CzWSysGZugEn2
         vUkg==
X-Gm-Message-State: AA+aEWYlWqB3YDWk7PNua6VCriZUfhJm0mfAR6xZtKqwsB77n15SVQS0
        H06WXOzrGWnrXdZyWElJsUNiusTq8jY3jQ2n2+k=
X-Google-Smtp-Source: AFSGD/XuDHrEOGp+PkBEWFFyyNH0gN0+n9RQom5u7jRdFZt7XSWa9sgI7PxizUL8/zembxIicC6qIANTgLMJQUUmI1A=
X-Received: by 2002:a1f:bfc6:: with SMTP id p189mr5532638vkf.83.1543763998894;
 Sun, 02 Dec 2018 07:19:58 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com> <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
 <20181201220045.GQ19305@dastard> <CAN-5tyFBjVM6HOGZbjy+k4eCOHyDdvXsiGOHSR+gRXCHS3fosA@mail.gmail.com>
In-Reply-To: <CAN-5tyFBjVM6HOGZbjy+k4eCOHyDdvXsiGOHSR+gRXCHS3fosA@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Sun, 2 Dec 2018 10:19:47 -0500
Message-ID: <CAN-5tyE9u7RTSmWYR6PXmJn+VnJvxRZbDocxvaKQbpj0MYo0Hg@mail.gmail.com>
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
To:     david@fromorbit.com
Cc:     Amir Goldstein <amir73il@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, willy@infradead.org,
        jlayton@kernel.org, stfrench@microsoft.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Dec 1, 2018 at 10:12 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Sat, Dec 1, 2018 at 5:00 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Sat, Dec 01, 2018 at 10:11:48AM +0200, Amir Goldstein wrote:
> > > On Fri, Nov 30, 2018 at 10:04 PM Olga Kornievskaia
> > > <olga.kornievskaia@gmail.com> wrote:
> > > >
> > > > Relax the condition that input files must be from the same
> > > > file systems.
> > > >
> > > > Add checks that input parameters adhere semantics.
> > > >
> > > > If no copy_file_range() support is found, then do generic
> > > > checks for the unsupported page cache ranges, LFS, limits,
> > > > and clear setuid/setgid if not running as root before calling
> > > > do_splice_direct(). Update atime,ctime,mtime afterwards.
> > > >
> > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > ---
> > >
> > > This patch is either going to bring you down or make you stronger ;-)
> > >
> > > This is not how its done. Behavior change and refactoring mixed into
> > > one patch is wrong for several reasons. And when you relax same sb
> > > check you need to restrict it inside filesystems, like your previous patch
> > > did.
> > .....
> > > In any case, I hear that Dave is neck deep in fixing copy_file_range()
> > > so changes to this function should be collaborated with him. Or better
> > > yet, wait until he posts his fixes and carry on from there.
> >
> > Yeah, because I've heard nothing for a month and this is kinda
> > important
>
> Dave I think that's unfair. It is important. NFS is actually the file
> system that needed VFS support for cross fs copy_file_range and I was
> working on it. If you were in doubt, you could have emailed and asked
> me.

Just to be clear. What I think was unfair in that comment was the
wording "this is kinda important". I think a lot stems from lack of
clarity in the the mailing list communications. I object to the fact
that it wasn't clear who was going to implement the functionality.
Since the work was needed by NFS I didn't want to assume that somebody
in VFS would just do it for us. At the time nobody in VFS stood up and
said they would do the work and thus I tried to do my best.

I'm grateful, and would have been in the first place, that somebody
did support generic cross-filesystem functionality. Thus I'm by no
means speaking against Dave's work.

> I'm unsure now what does this mean. I have a patch series with a VFS
> patch that went thru the extensive review (people spend time on it)
> and an NFS patch series that depends on it that is ready for the
> upstream push. Are you saying that the VFS patch is no longer welcomed
> and thus NFS series is no longer viable either?

I'm unclear of the fate of the patch set that has the (v7) VFS patch
that was reviewed and approved and is thought to be pushed for 4.21.
It is unclear if the new work is on top of that or not.

> , I have a series of 8-9 patches that make all the fixes we
> > need, push the cross-filesystem checks down into the filesystems,
> > and let filesystems handle the fallback to a splice based copy
> > themselves (because there are way more fallback cases than just
> > EOPNOPSUPP and EXDEV).
>
> Are you saying it is each individual filesystem responsibility to
> fallback on splice? Isn't that a step backwards? Each individual
> filesystem is going to implement the same code of calling
> do_splice_direct() to do the functionally that could and should be in
> VFS?
>
> >
> > I also have a patch for the man page that document all the missing
> > failure cases, and document where things are filesystem specific or
> > not.
> >
> > And I also have a fstests patch that exercises all the failure cases
> > so that all filesystems will end up behaving the same way for all
> > the same cases they should.
> >
> > I'm still sorting out the fstests patch (it requires changes
> > to xfs_io's copy-range command) so I've got some confidence that the
> > code actually does what it says in the man page, but I should have
> > that sorted in a couple of days.
> >
> > Cheers,
> >
> > Dave.
> >
> > --
> > Dave Chinner
> > david@fromorbit.com
