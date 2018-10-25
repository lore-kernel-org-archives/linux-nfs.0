Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36425C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 16:57:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D417B20848
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 16:57:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SI39smA4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D417B20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727775AbeJZBbG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 21:31:06 -0400
Received: from mail-yb1-f196.google.com ([209.85.219.196]:38451 "EHLO
        mail-yb1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727319AbeJZBbF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 21:31:05 -0400
Received: by mail-yb1-f196.google.com with SMTP id v92-v6so3980782ybi.5;
        Thu, 25 Oct 2018 09:57:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PDNexdhxmMel1eUHiztmm6TngPsZSouiVRC3BzZS1m8=;
        b=SI39smA4eKINrrjwNW7GzqVcnV+bwgbpf8L2DMehO+/cCEJhdFTm7bhQ3tZKP4vqIr
         2bx+XbWjjLoTe1BVClURCc/SMb74pTN0tb+3jLPFgz5YC2m43WnBqYrXMd79EaI8FgMD
         GwDx4rXe5mh29ZK7nf+tWLqQO2aJeGV9Uf5boewAo9qDio85M9aKXp73lA4jTA4t6laK
         yiudzbY/enQSXL0fMraY2EsFkLHklOfzHXULD6Z5eKuwgn53su73Lv2eNAIyf4AfDihz
         vWKJQzQEZndqDt1wbmipUUCeViLCme1TRVFiIzY5Vt8MxsfTP06IfoWPvF9tkeB7e/sX
         XGaA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=PDNexdhxmMel1eUHiztmm6TngPsZSouiVRC3BzZS1m8=;
        b=ncYVz6ruDxou27feLyrsx1bYL42ngv03GRkzdUAenlzmpiTjEH222vEV1fy93VNtes
         WQNZ4HfrWh0bdgMoNFZo1X63aj+5b/I7VzvtODZMOcUblI7htQM6PZkonYzayOz3VJ36
         5zwLvuOS3otBuKRoq7F4y8cFv72K78Xk+gSuLPM9D32vktqjJhoLIN2bAZ6608i97teR
         YKBm5Tfs/Ndxd9JnwiWdx1GkBzw8e5O2SMI2iFdUepiwXEUewqXfdmjjKyH0CCAEFrL8
         sYidnRLFsEQT92uACrskcMWifzyrqTkjRFFj3KTan0ETu7hDdEp7I4p3a3nuntPW+Ger
         gRVQ==
X-Gm-Message-State: AGRZ1gKP6qJPMuejEwDNIb7YOWZDjHcojvXPgSOYP3Zej3k+QEqx/j/g
        a0b/OPjs4rpfAXwkDta5CaWT0Ra5OLuVEKfvs/g=
X-Google-Smtp-Source: AJdET5cmtUCLgT186Kt0W2OiB/ElZE7487UhH2iblz7O+M2QTB1SWh7YrxyA93DTNrC/ag/W0scxs9SlzURctQRPRow=
X-Received: by 2002:a25:bdd0:: with SMTP id g16-v6mr2370021ybk.397.1540486647823;
 Thu, 25 Oct 2018 09:57:27 -0700 (PDT)
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
 <20181022190620.GA8863@bombadil.infradead.org> <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
 <a4a3ac1e840444871f3bc87606b111668c66618b.camel@redhat.com>
 <CAOQ4uxiRnyxtOXBrdCvUcTa8GkTb2OyaJYJ58Ddoik0=3Y9pyA@mail.gmail.com>
 <CAN-5tyHQc3M2YprFJm35XUxJdAx11a85o1NygE5FQFyHq3SQew@mail.gmail.com>
 <CAN-5tyEtRSQMS-u0gbheFn5f2siOy8Qva2vnXW6rwb7pr_GDkA@mail.gmail.com>
 <CAN-5tyEXvnekZJpOhNBkCBCLTpXjM5PghJxDSeo0dwn94_7wDw@mail.gmail.com>
 <4f35382683c96f03a88c90f0a1fcced36f290d72.camel@redhat.com>
 <CAN-5tyEQMtWepkhr8m4HjR0pkbbF1a3_-bL4iFJs2xjKervD2A@mail.gmail.com>
 <CAOQ4uxgW+AAxGszy=rsNCZLAJPpJbz6O4Xtnje-=WeDo+oATag@mail.gmail.com>
 <CAN-5tyGpp15S34b4OUEyO6p+7KAn61xQAF-ozMoBi6PKh1fC2g@mail.gmail.com> <CAN-5tyH93_iLCKYazWoLNeFv=jLZiekYsNShwB1dj=HGBcGeuQ@mail.gmail.com>
In-Reply-To: <CAN-5tyH93_iLCKYazWoLNeFv=jLZiekYsNShwB1dj=HGBcGeuQ@mail.gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 25 Oct 2018 19:57:16 +0300
Message-ID: <CAOQ4uxjCX0evX9YnPLhr-mkMDXkz318_Q6zZ8TFeQn+TwRyA+g@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     Jeff Layton <jlayton@redhat.com>,
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

On Thu, Oct 25, 2018 at 7:00 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Thu, Oct 25, 2018 at 11:58 AM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > On Thu, Oct 25, 2018 at 12:59 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > >
> > > On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> > > <olga.kornievskaia@gmail.com> wrote:
> > > >
> > > [...]
> > > > It feels like folks are now ok with either the check being in the
> > > > drivers or doing the check in the VFS layer.
> > > >
> > > > I'm picking the choice of not doing the check in the VFS layer because
> > > > it allows for do_splice_direct() by any caller.
> > >
> > > I'm sorry, but this reasoning in flawed and this is not the reason that
> > > Matthew promoted not doing same fs type check in vfs.
> >
> > I stated the reason why I picked to do the check at the driver layer.
> > Looking at your version of the sb type check to be only applied to the
> > copy_file_range indeed makes my argument invalid. I was under the
> > impression that sb type check was being proposed as a standalone check
> > (just like the sb check was standalone). Thus, yes I didn't completely
> > understand what you proposed.
> >
> > > You did not understand the option that I was promoting to begin with.
> > > What I suggested was:
> > >
> > > 1. Remove current same sb check in beginning of vfs_copy_file_range()
> > > 2. Check sb && ->clone_file_range
> > > 3. Check same sb type && ->copy_file_range
> > > 4. Cross fs do_splice_direct()
> > >
> > > It's fine that you chose not to check for same fs type in VFS before calling
> > > copy_file_range() method, but still requires an ACK from Al that he agrees
> > > with passing in file * of another filesystem on the interface.
> >
> > Al, can you please provide a final decision as to which way you would
> > prefer for this to be done.
> >
> > > > I'm about to submit
> > > > the new version of the patches (this time I will include the NFS patch
> > > > series). We can continue with the discussion on the new version.
> > > >
> > > > I have added checks for the CIFS and OverlayFS to be consistent with
> > > > the previous behavior -- no cross-device copy_offload, I assume if and
> > > > when those file systems are ready to make use of it they'll remove the
> > > > check.
> > > >
> > >
> > > Actually overlayfs code is "ready" for cross sb copy, but neither nfs nor
> > > cifs are supported as upper file system, so it doesn't matter much.
> >
> > So then the commit statement is still true. When overlayfs will have
> > upper file systems that do support it, this check can be removed.
>
> Ops sorry I meant them as questions. Do you feel that commit message
> needs to be changed then?

Commit message is fine by me.

Thanks,
Amir.
