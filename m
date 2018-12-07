Return-Path: <SRS0=0ybF=OQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11F17C07E85
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 05:38:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C650520892
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 05:38:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Iumi4WQ0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C650520892
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726003AbeLGFiu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 7 Dec 2018 00:38:50 -0500
Received: from mail-yw1-f66.google.com ([209.85.161.66]:45933 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725948AbeLGFiu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Dec 2018 00:38:50 -0500
Received: by mail-yw1-f66.google.com with SMTP id d190so594075ywd.12;
        Thu, 06 Dec 2018 21:38:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eqPB1tUuNjRL0q1onY0MwlQ/ut50khZC8oSQETOo/40=;
        b=Iumi4WQ0a1lju126GJcFgtoviygnVfmeKQ0/Ik1zP3fAnxm0m/KEgdh8Le7RlXyOOZ
         hKSMTBiy9zkXJrz4m4m6ye317ctIkXGXmpmLsVfCIMdxxODtPKvMsRggKTPtroV2tIPd
         bdlN/faj2LpYTns0NPKGcE09u616B3tSobOTvpGiLMSfkWalSUYQmPOim/AVpwfYnqqy
         SkbfaNvwg/+IndYJeD5kf9li3zeJ+wVs0v+DbMyNUOdorjybFn87Z2jgZgK8L0HxVXp5
         KPNUC7BLhmQUCFhcWWC0UGB+iOTF2BoWFQF0UaHca+KJE9/VFTGhyg5nt40A/AmK0qgo
         U9zQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=eqPB1tUuNjRL0q1onY0MwlQ/ut50khZC8oSQETOo/40=;
        b=fadwnJfSnn0X+NWCq7qHexED+RdOKEjXhOg4gzmiOfnLOmqV9TZyOjD77BEafXijPd
         ew4KKISGM5L0cGEpTrdH1Bp1sVKdYRCe/UGDD32/8TCKCvNpb8wPvaNH40qhDcoowTW7
         YUd3/O73LTNwr4tw9yhsBi/bzYZMA4jOiewPLoyVm1tPJHWGA86skyrTHkeQx/Ty+Kyo
         8k+pF7eiAZd+iy3JEXuNDCo5iZP4FXT2ySdektZRT47vxFehxFK2+BAQaPrd3OhaTj7I
         3rYATCRs2hhl8k52BcKQGbIe5vALZcuxQorfBdaaJA9KrF5WgdvOrvWd10m5j2lJ4Kbe
         vdsQ==
X-Gm-Message-State: AA+aEWayErOhDN0G1oEGc8cm/nNWvjTIMP1jS0QBWVbxzdOCoo374UE1
        8mJtIkNp+Zog2dCiOpa95XIgfGB9Qf2+e2eEdvI=
X-Google-Smtp-Source: AFSGD/WyHtbtmvChNgAE0XQd7Zgy0ff2m6OQVSFF3qmN2PSfYcxYbqYfEr/s2WTSJvGzotIIBNAMRXOOS9biIO8VZBo=
X-Received: by 2002:a81:d87:: with SMTP id 129mr786768ywn.248.1544161128455;
 Thu, 06 Dec 2018 21:38:48 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-4-david@fromorbit.com>
 <CAOQ4uxjRErxoOTAr+yzu7s5S4SEYZuw6GcfQ-M7UXAasTG9Knw@mail.gmail.com>
 <20181203230222.GH6311@dastard> <CAOQ4uxgqaGoVs9t9NqWn-uVyeeZzZOUBSYX6=JFn2uCf3rKmUQ@mail.gmail.com>
 <20181206213058.GY6311@dastard>
In-Reply-To: <20181206213058.GY6311@dastard>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Fri, 7 Dec 2018 07:38:36 +0200
Message-ID: <CAOQ4uxjBadFK1MLj0uQvKkQYL=NmK1zqx29yASMH9bwMsTrmFw@mail.gmail.com>
Subject: Re: [PATCH 03/11] vfs: no fallback for ->copy_file_range
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 6, 2018 at 11:31 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Thu, Dec 06, 2018 at 06:16:46AM +0200, Amir Goldstein wrote:
> > On Tue, Dec 4, 2018 at 1:02 AM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > On Mon, Dec 03, 2018 at 12:22:21PM +0200, Amir Goldstein wrote:
> > > > On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
> > > > >
> > > > > From: Dave Chinner <dchinner@redhat.com>
> > > > >
> > > > > Now that we have generic_copy_file_range(), remove it as a fallback
> > > > > case when offloads fail. This puts the responsibility for executing
> > > > > fallbacks on the filesystems that implement ->copy_file_range and
> > > > > allows us to add operational validity checks to
> > > > > generic_copy_file_range().
> > > > >
> > > > > Rework vfs_copy_file_range() to call a new do_copy_file_range()
> > > > > helper to exceute the copying callout, and move calls to
> > > > > generic_file_copy_range() into filesystem methods where they
> > > > > currently return failures.
> > > > >
> > > > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > >
> > > > You may add
> > > > Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> > > >
> > > > After fixing the overlayfs issue below.
> > > > ...
> > > >
> > > > > diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> > > > > index 84dd957efa24..68736e5d6a56 100644
> > > > > --- a/fs/overlayfs/file.c
> > > > > +++ b/fs/overlayfs/file.c
> > > > > @@ -486,8 +486,15 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
> > > > >                                    struct file *file_out, loff_t pos_out,
> > > > >                                    size_t len, unsigned int flags)
> > > > >  {
> > > > > -       return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
> > > > > +       ssize_t ret;
> > > > > +
> > > > > +       ret =  ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
> > > > >                             OVL_COPY);
> > > > > +
> > > > > +       if (ret == -EOPNOTSUPP)
> > > > > +               ret = generic_copy_file_range(file_in, pos_in, file_out,
> > > > > +                                       pos_out, len, flags);
> > > > > +       return ret;
> > > > >  }
> > > > >
> > > >
> > > > This is unneeded, because ovl_copyfile(OVL_COPY) is implemented
> > > > by calling vfs_copy_file_range() (on the underlying files) and it is
> > > > not possible
> > > > to get EOPNOTSUPP from vfs_copy_file_range().
> > >
> > > Except that it is possible. e.g. If the underlying filesystem tries
> > > a copy offload, gets a "not supported" failure from the remote
> > > server and then doesn't implement a fallback.
> > >
> >
> > I'm in the opinion that ovl_copy_file_range() and do_copy_file_range()
> > are a like. If you choose not to fallback in the latter to
> > generic_copy_file_range() for misbehaving filesystem and WARN_ON
> > this case, there is no reason for overlayfs to cover up for the
> > misbehaving underlying filesystem.
> >
> > If you want to cover up for misbehaving filesystem, please do it
> > in do_copy_file_range() and drop the WARN_ON_ONCE().
> > Come to think about it, I understand your reasoning for pushing
> > generic_copy_file_range() down to filesystems so they can fallback to
> > it in several error conditions.
> > I do not follow the reasoning of NOT falling back to
> > generic_copy_file_range() in vfs if EOPNOTSUPP is returned from
> > filesystem. IOW, if we want to cover up for misbehaving filesystem,
> > this would have been a more robust code:
>
> Since when have we defined a filesystem returning -EOPNOTSUPP as a
> "misbehaving filesystem"?

Since you wrote:

WARN_ON_ONCE(ret == -EOPNOTSUPP);

If filesystem is allowed to return EOPNOTSUPP from ->copy_file_range()
then what is this warning about?

> Userspace has to handle errors in
> copy_file_range() with it's own fallback copy code (i.e. it cannot
> rely on the kernel actually supporting copy_file_range at all).
> Hence it's perfectly fine for a filesystem implementation to encode
> "offload or fail entirely" semantics if they want.
>
> Yes, I've been shouted at by developers quite recently who
> *demanded* that copy_file_range (and other offloads like
> fallocate(ZERO_RANGE)) *fail* if they cannot "offload" the operation
> to make it "fast". The application developers want to use different
> algorithms if the kernel offload isn't any faster than userspace
> doing the dumb thing and phsyically pushing bytes around itself.
>
> I've pushed back on this as much as I can, but it doesn't change the
> fact that for many situations doing do_splice_direct() is exactly
> the wrong thing to do (e.g. because copy_file_range() on a TB+ scale
> file couldn't be offloaded by the filesystem because the server said
> EOPNOTSUPP)
>
> IOWs, for some filesystems or situations where it makes sense to
> have fail-fast semantics and leave the decision of what to do next
> in the hands of the userspace application that has the context
> necessary to determine what the best action to take is.  And to do
> that, we need to give control of the fallback to the filesystems.
>
> Flexibility is what is needed here, not a dumb, hard coded "the VFS
> always know what's right for you" policy that triggers when nobody
> really wants it to.
>

You misunderstood me.
Please remove the fallback to generic_copy_file_range() in
ovl_copy_file_range() as I requested in initial review for the exact
same reasons that you list above.

The overlayfs implementation of ovl_copy_file_range() is just
handing over the call to underlying vfs_copy_file_range().
If the latter is expected to return EOPNOTSUPP, so does the
overlayfs implementation.

Thanks,
Amir.
