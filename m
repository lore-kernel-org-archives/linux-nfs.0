Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72874C46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 06:05:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4593520671
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 06:05:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HRxZPz0B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4593520671
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727023AbeJWO1j (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 10:27:39 -0400
Received: from mail-yw1-f66.google.com ([209.85.161.66]:37112 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727017AbeJWO1j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 10:27:39 -0400
Received: by mail-yw1-f66.google.com with SMTP id v77-v6so78465ywc.4;
        Mon, 22 Oct 2018 23:05:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gwXVRvCykzk9RZFyEAWHsiwI1woKxMDQRbUUPumjgE8=;
        b=HRxZPz0BU7l3xDcdS5DJnUkKl616Q06nU0DVw0yqjSfzTOywCo0EscCx1+vbDl6aNP
         or+IQI6t4/AeHMZ5g3CN1akoWd10p/XSExR/yCLa72mBB7LE2FvpZsHccV67cWyBgO2p
         8D37pulEGG8Iy9jYaK9rj2JTlbo0thvFcX95R7Bvc5xyYZrCBRotHPEUxix16U51t8lO
         1+9uZdbU89D5ZTftg3FgSutagPPMovOee6pqHubkOngbMkb3uc2ketryvp3g+Fj7Q098
         tVFAX24T1+fE6B2EQzTuOgkMoeXVr43JiqRlnySfrCryDfSvArtZeNCLhvnyZ6dP+/WR
         GKog==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=gwXVRvCykzk9RZFyEAWHsiwI1woKxMDQRbUUPumjgE8=;
        b=hRzepzS+Gsv7wtQiTKuz5bpVwFKL+NMrVzdsXAqwAuaY6dXxFgMeLUbrdsAKM5QsuN
         mHR15PfcqtvOSAxzFLpFYLWmLBTHuDozss3SzhqT1GQ5aAM/XODSSjs0/IydVif/9MS9
         bQdd6TYD0gabm0LrJwSyfi8G1LXXdEKojM8dofnhSAhAeg36IVolKZP5EQj4fu789skB
         iOq//o0mdLLJm5WsgQf9/g6BZ2zE0xges3aRKOKNQkL8hIXTrBYGW67Q4RP0UypvAL/s
         RsuGZJOGR+jz5QdoYL1U8Hs2Fvqb+LUUeAdynczhqsZcY3PeP/ehoD8705cQhiJDmIpX
         rrzA==
X-Gm-Message-State: ABuFfoiPTZb3NN6JDcZ+2ZXcrEGNQLhWqSGx3g26FVq8BY9GMoeQpeHk
        2M5vD65zY43PD7gC3EHree4hp+CyN/0pTfaS+y8=
X-Google-Smtp-Source: ACcGV63EO/gTXTz02cvyshkJ0KB52dxH9/NO9/sDpHmQFAgpS6tQugml4gNhUkQ4AJATmvMpXPNnGp2Rm8RtDWGWqP0=
X-Received: by 2002:a81:6505:: with SMTP id z5-v6mr34155815ywb.34.1540274744609;
 Mon, 22 Oct 2018 23:05:44 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
 <20181022190620.GA8863@bombadil.infradead.org> <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
 <a4a3ac1e840444871f3bc87606b111668c66618b.camel@redhat.com>
In-Reply-To: <a4a3ac1e840444871f3bc87606b111668c66618b.camel@redhat.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Tue, 23 Oct 2018 09:05:33 +0300
Message-ID: <CAOQ4uxiRnyxtOXBrdCvUcTa8GkTb2OyaJYJ58Ddoik0=3Y9pyA@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     Jeff Layton <jlayton@redhat.com>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Matthew Wilcox <willy@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fweimer@redhat.com, Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 23, 2018 at 2:39 AM Jeff Layton <jlayton@redhat.com> wrote:
>
> On Mon, 2018-10-22 at 15:34 -0400, Olga Kornievskaia wrote:
> > On Mon, Oct 22, 2018 at 3:06 PM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Mon, Oct 22, 2018 at 02:45:04PM -0400, Olga Kornievskaia wrote:
> > > > On Sat, Oct 20, 2018 at 4:54 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > > > > Another thing is the commit message claims to:
> > > > > "Allow copy_file_range to copy between different superblocks but only
> > > > > of the same file system types"
> > > > >
> > > > > But what the patch actually does is:
> > > > > "Allow copy_file_range() syscall to copy between different filesystems
> > > > > AND allow calling the filesystems' copy_file_range() method
> > > > > between different superblocks but only of the same file system types"
> > > > >
> > > > > It's probably OK and quite useful to do the former, but maybe man page
> > > > > should be fixed to explicitly mention that the copy is expected to work
> > > > > across filesystems since kernel version XXX (?)
> > > > >
> > > > > If you don't wish to change cross filesystem type behavior and only
> > > > > relax cross super block limitation, then you should replace the
> > > > > same inode->i_sb check above with same inode->i_sb->s_type
> > > > > check instead of doing the check only for calling the filesystem
> > > > > copy_file_range() method.
> > > >
> > > > Thank you for the feedback. In the next version, I will remove the
> > > > check for the functions and instead check for the same file system
> > > > types.
> > >
> > > Jeff and I agree that this is the wrong way to go.  Instead, the
> > > cross-device check should be in the individual instances, not the top
> > > level code.
> >
> > So remove the check all together for the VFS (that was my original
> > patch to begin with (like #1 not this one). So am I missing the point
> > again, I keep getting different corrections every time.
>
> Sorry if I wasn't clear before:
>
> Basically, I think Willy and I are both envisioning that some
> copy_file_range implementations may eventually not be subject to the
> limitations of the checks you're adding.
>

Yes. Eventually. And even Matthew is (quote) "dubious" about that ever
happening. Changing the interface as Matthew proposed has a price
and we need to compare this price to the alleged backporting price
that nobody may ever need to pay.

As far as I can tell, passing a struct file * on a file_operations method
that does not belong to that filesystem in unprecedented (*) and is a far
more lethal landmine than the alleged backporting landmine.

(*) prior to v4.19-rc1, filesystems could get an overlayfs file, but
     file_inode(file) has always belonged to the filesystem.

Olga,

I do not strongly object to Matthew's proposal, so don't feel
obligated to choose my side of the argument. I am just trying
to offer a different perspective.

In any case, my outstanding concerns with the patch are:

1. If you change syscall to support cross fs type copy (which is
    good IMO) need to document that in commit message
    and possibly follow up later with a note in man page

2. Commit message says:
    "This feature was of interest of ... NFS"
    "This feature is needed by NFSv4.2..."
    "NFS will allow for copies between different NFS servers."
    It is not clear to me if we are talking about present of future
    NFSv4.2 code. If NFSv4.2 currently does not support cross
    sb copy (??) than your patch need to enforce same sb
    in nfs4_copy_file_range(). If it does support cross sb copy
    than please edit the commit message to make that clear.

Thanks,
Amir.
