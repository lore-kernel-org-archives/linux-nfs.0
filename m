Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABD44ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 16:00:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 623B52083E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 16:00:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="frMuvJ3b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 623B52083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727400AbeJZAeV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 20:34:21 -0400
Received: from mail-vs1-f66.google.com ([209.85.217.66]:35977 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727319AbeJZAeV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 20:34:21 -0400
Received: by mail-vs1-f66.google.com with SMTP id c205so5842092vsd.3;
        Thu, 25 Oct 2018 09:00:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GLQzaRaUd8ECJYWTVECQbc7njaWqLrak9tIhqZHgXos=;
        b=frMuvJ3bbtTT4IU20qZ+Tr22XhRTQoQNcq3R8mFwB9vO8SvFZ/SkNPcdanByegaEvr
         mtlBUE4VFi2Ts56fY2rBsYC9bIfcDBhoCc1bJXf3PbrhAKkG1TNmXmM68tGLP7K01cWo
         sOWdADshFwj8YvAQEwglgr089Sws5gGifGG5kFAO55H9eeKFTei/pry92wbIB9zE8nZc
         v0k3Eul5F63q86b/NDGq7g73DA1FRdwQ1bI+0Xc/lSnaZQq2eIYb3hgowuSxCmGMr9sG
         9wOSfHmC5crMxkMAo8Jotnkw+YctmjjY6F0nlBUNgfLjpcn1nvm76B5SoRamu/yk8vaZ
         KNhQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=GLQzaRaUd8ECJYWTVECQbc7njaWqLrak9tIhqZHgXos=;
        b=k8/1ULYF2YgW4U7P4+o5/TpuATFdJw7z9+DI5JXNlMoOIXjSFEYazo7XWNso4pBPOs
         OlZgfps7QLZfKZ3s7Uck4UgqUhpnRpo7Ev5hiXxEBfZv7UbZR3KKWWg0TuxBaNG+k9GD
         MQQnBGlc1sCYYW5lkbdgKj1BDANUgZFW8wUbgQQsLDPhCzLRF3LJXImkoGhmnS5bydnV
         oVnUzhUfS0nMHunuROSdZGmVGF70EeL/X194Je8bhs+lMXfmALZMSX/qa/n9kr6h3VNo
         oWkHmpHVCcpkpKtsKMVsZ6qENcxliACQe5c+nKcPa4CfCp/7R9AxKmhyFA3wJqIxwtCd
         OMWw==
X-Gm-Message-State: AGRZ1gI/QpD8lbFFcbVycOtedtsxDJTNsbCk1SpunoJGJLKgSdlmDZ2v
        75p3dAxab4uiDVeJN7H6eJ5BVq3brPCY3Wawfd4=
X-Google-Smtp-Source: AJdET5fNWZc6ptTgp7mfgh0c8dSSPDZoUKa7RgW99nERK89o0KQ/JPQtCHFeBwCddRr2koXDw3tLIGBdkKbQluIRfu8=
X-Received: by 2002:a67:f441:: with SMTP id r1mr964702vsn.164.1540483256781;
 Thu, 25 Oct 2018 09:00:56 -0700 (PDT)
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
 <CAOQ4uxgW+AAxGszy=rsNCZLAJPpJbz6O4Xtnje-=WeDo+oATag@mail.gmail.com> <CAN-5tyGpp15S34b4OUEyO6p+7KAn61xQAF-ozMoBi6PKh1fC2g@mail.gmail.com>
In-Reply-To: <CAN-5tyGpp15S34b4OUEyO6p+7KAn61xQAF-ozMoBi6PKh1fC2g@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 25 Oct 2018 12:00:44 -0400
Message-ID: <CAN-5tyH93_iLCKYazWoLNeFv=jLZiekYsNShwB1dj=HGBcGeuQ@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Jeff Layton <jlayton@redhat.com>, willy@infradead.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Oct 25, 2018 at 11:58 AM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Thu, Oct 25, 2018 at 12:59 AM Amir Goldstein <amir73il@gmail.com> wrote:
> >
> > On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > >
> > [...]
> > > It feels like folks are now ok with either the check being in the
> > > drivers or doing the check in the VFS layer.
> > >
> > > I'm picking the choice of not doing the check in the VFS layer because
> > > it allows for do_splice_direct() by any caller.
> >
> > I'm sorry, but this reasoning in flawed and this is not the reason that
> > Matthew promoted not doing same fs type check in vfs.
>
> I stated the reason why I picked to do the check at the driver layer.
> Looking at your version of the sb type check to be only applied to the
> copy_file_range indeed makes my argument invalid. I was under the
> impression that sb type check was being proposed as a standalone check
> (just like the sb check was standalone). Thus, yes I didn't completely
> understand what you proposed.
>
> > You did not understand the option that I was promoting to begin with.
> > What I suggested was:
> >
> > 1. Remove current same sb check in beginning of vfs_copy_file_range()
> > 2. Check sb && ->clone_file_range
> > 3. Check same sb type && ->copy_file_range
> > 4. Cross fs do_splice_direct()
> >
> > It's fine that you chose not to check for same fs type in VFS before calling
> > copy_file_range() method, but still requires an ACK from Al that he agrees
> > with passing in file * of another filesystem on the interface.
>
> Al, can you please provide a final decision as to which way you would
> prefer for this to be done.
>
> > > I'm about to submit
> > > the new version of the patches (this time I will include the NFS patch
> > > series). We can continue with the discussion on the new version.
> > >
> > > I have added checks for the CIFS and OverlayFS to be consistent with
> > > the previous behavior -- no cross-device copy_offload, I assume if and
> > > when those file systems are ready to make use of it they'll remove the
> > > check.
> > >
> >
> > Actually overlayfs code is "ready" for cross sb copy, but neither nfs nor
> > cifs are supported as upper file system, so it doesn't matter much.
>
> So then the commit statement is still true. When overlayfs will have
> upper file systems that do support it, this check can be removed.

Ops sorry I meant them as questions. Do you feel that commit message
needs to be changed then?
>
> >
> > Thanks,
> > Amir.
