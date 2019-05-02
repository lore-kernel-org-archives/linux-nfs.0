Return-Path: <SRS0=hurI=TC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41D47C43219
	for <linux-nfs@archiver.kernel.org>; Thu,  2 May 2019 02:55:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 054562086C
	for <linux-nfs@archiver.kernel.org>; Thu,  2 May 2019 02:55:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NNca5O+W"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726231AbfEBCzF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 May 2019 22:55:05 -0400
Received: from mail-yw1-f66.google.com ([209.85.161.66]:40378 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726205AbfEBCzF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 May 2019 22:55:05 -0400
Received: by mail-yw1-f66.google.com with SMTP id t79so510484ywc.7;
        Wed, 01 May 2019 19:55:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=z26n6/sH1AsDLpioQphX4q8VPU5RJ6kDUqodat8Mtow=;
        b=NNca5O+WSrABeS7FxwX2kVyi55yKQZ3Y0LgWmt/HcJXj4uY1JAUHblmApUu4o+Ci+s
         xWyL61X7MmIpAYoUr07WZD3vGP9xoPa0uM1nf1w7pgLgA4bD94jozmXKMYhpU6vHx9RK
         PpsfYnjaeLfrjJ0uc7SnPZpmQcetdMuJh2eMZZ2KGY1FiQGCdRRh8kCW8mfY44M9U46q
         1Z7qjI+oZ+DTvgMGWlWhYajGM5Cg1tSztOL8Mv1xBSSqJMuOMwa3ObGCnPbJoJHeQlM4
         YA9poXCVtSl9iVUyrEAsmMR+ACiDbmArDwl77rypSOCxY9HwP2itpZzFM0SSXRRY3Lhf
         H5Mg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=z26n6/sH1AsDLpioQphX4q8VPU5RJ6kDUqodat8Mtow=;
        b=k+Dqx0mjLyp74WzDDLcdFOC6yfNNjN/+ixbr5tIX9P53aablHP0X05mG1bpzPhfejT
         cncR3lY0EYAETROVsxTF7ySxfEzfjnezqMVvHpfsrPzPpMBkdHV7scvmbF88055EJenj
         9pmnMyH1LwwQUJDOwsHQPXeY9F7GnZO9RI/SuZ1IW2VAy0vC4E219Uffrf3JYW2R/2Iy
         ZggIwubbwhkRbxjyq/mtDrnV5WxPxfIKcOqNUqQvTvgS++KoiedNhmcNEGP4hKhVqG22
         +g22/wyzZPo1TYit02DRDETycs781pkpvB0icfgil2XeyTMXcE5hPuPAnYUItR7xF+ZO
         BJoQ==
X-Gm-Message-State: APjAAAUTDB28aAInIa60i5mWuguboq/99SsntZb9NsDa2Os+VDGLwJTl
        BGMsTtHkfthv77E7bo9QVHcxBGFRcScXAKXkyIU=
X-Google-Smtp-Source: APXvYqznaWNQLzQJptPPiF6oL+1IzIuegKrmT2CGGjSizksqtM7XGR6nr9+kccqVb+vnJbWv3cWxnjocNb/7rtuT1bY=
X-Received: by 2002:a25:d64a:: with SMTP id n71mr1069731ybg.462.1556765703443;
 Wed, 01 May 2019 19:55:03 -0700 (PDT)
MIME-Version: 1.0
References: <CAJfpeguwUtRWRGmNmimNp-FXzWqMCCQMb24iWPu0w_J0_rOnnw@mail.gmail.com>
 <20161205151933.GA17517@fieldses.org> <CAJfpegtpkavseTFLspaC7svbvHRq-0-7jvyh63+DK5iWHTGnaQ@mail.gmail.com>
 <20161205162559.GB17517@fieldses.org> <CAHpGcMKHjic6L+J0qvMYNG9hVCcDO1hEpx4BiEk0ZCKDV39BmA@mail.gmail.com>
 <266c571f-e4e2-7c61-5ee2-8ece0c2d06e9@web.de> <CAHpGcMKmtppfn7PVrGKEEtVphuLV=YQ2GDYKOqje4ZANhzSgDw@mail.gmail.com>
 <CAHpGcMKjscfhmrAhwGes0ag2xTkbpFvCO6eiLL_rHz87XE-ZmA@mail.gmail.com>
 <CAJfpegvRFGOc31gVuYzanzWJ=mYSgRgtAaPhYNxZwHin3Wc0Gw@mail.gmail.com>
 <CAHc6FU4JQ28BFZE9_8A06gtkMvvKDzFmw9=ceNPYvnMXEimDMw@mail.gmail.com>
 <20161206185806.GC31197@fieldses.org> <87bm0l4nra.fsf@notabene.neil.brown.name>
In-Reply-To: <87bm0l4nra.fsf@notabene.neil.brown.name>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Wed, 1 May 2019 22:54:52 -0400
Message-ID: <CAOQ4uxjYEjqbLcVYoUaPzp-jqY_3tpPBhO7cE7kbq63XrPRQLQ@mail.gmail.com>
Subject: Re: [PATCH] overlayfs: ignore empty NFSv4 ACLs in ext4 upperdir
To:     NeilBrown <neilb@suse.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>,
        Patrick Plagwitz <Patrick_Plagwitz@web.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, May 1, 2019 at 10:03 PM NeilBrown <neilb@suse.com> wrote:
>
> On Tue, Dec 06 2016, J. Bruce Fields wrote:
>
> > On Tue, Dec 06, 2016 at 02:18:31PM +0100, Andreas Gruenbacher wrote:
> >> On Tue, Dec 6, 2016 at 11:08 AM, Miklos Szeredi <miklos@szeredi.hu> wr=
ote:
> >> > On Tue, Dec 6, 2016 at 12:24 AM, Andreas Gr=C3=BCnbacher
> >> > <andreas.gruenbacher@gmail.com> wrote:
> >> >> 2016-12-06 0:19 GMT+01:00 Andreas Gr=C3=BCnbacher <andreas.gruenbac=
her@gmail.com>:
> >> >
> >> >>> It's not hard to come up with a heuristic that determines if a
> >> >>> system.nfs4_acl value is equivalent to a file mode, and to ignore =
the
> >> >>> attribute in that case. (The file mode is transmitted in its own
> >> >>> attribute already, so actually converting .) That way, overlayfs c=
ould
> >> >>> still fail copying up files that have an actual ACL. It's still an
> >> >>> ugly hack ...
> >> >>
> >> >> Actually, that kind of heuristic would make sense in the NFS client
> >> >> which could then hide the "system.nfs4_acl" attribute.
> >> >
> >> > Even simpler would be if knfsd didn't send the attribute if not
> >> > necessary.  Looks like there's code actively creating the nfs4_acl o=
n
> >> > the wire even if the filesystem had none:
> >> >
> >> >     pacl =3D get_acl(inode, ACL_TYPE_ACCESS);
> >> >     if (!pacl)
> >> >         pacl =3D posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
> >> >
> >> > What's the point?
> >>
> >> That's how the protocol is specified.
> >
> > Yep, even if we could make that change to nfsd it wouldn't help the
> > client with the large number of other servers that are out there
> > (including older knfsd's).
> >
> > --b.
> >
> >> (I'm not saying that that's very helpful.)
> >>
> >> Andreas
>
> Hi everyone.....
>  I have a customer facing this problem, and so stumbled onto the email
>  thread.
>  Unfortunately it didn't resolve anything.  Maybe I can help kick things
>  along???
>
>  The core problem here is that NFSv4 and ext4 use different and largely
>  incompatible ACL implementations.  There is no way to accurately
>  translate from one to the other in general (common specific examples
>  can be converted).
>
>  This means that either:
>    1/ overlayfs cannot use ext4 for upper and NFS for lower (or vice
>       versa) or
>    2/ overlayfs need to accept that sometimes it cannot copy ACLs, and
>       that is OK.
>
>  Silently not copying the ACLs is probably not a good idea as it might
>  result in inappropriate permissions being given away.

For example? permissions given away to do what?
Note that ovl_permission() only check permissions of *mounter*
to read the lower NFS file and ovl_open()/ovl_read_iter() access
the lower file with *mounter* credentials.

I might be wrong, but seems to me that once admin mounted
overlayfs with lower NFS, NFS ACLs are not being enforced at all
even before copy up.

> So if the
>  sysadmin wants this (and some clearly do), they need a way to
>  explicitly say "I accept the risk".  If only standard Unix permissions
>  are used, there is no risk, so this seems reasonable.
>
>  So I would like to propose a new option for overlayfs
>     nocopyupacl:   when overlayfs is copying a file (or directory etc)
>         from the lower filesystem to the upper filesystem, it does not
>         copy extended attributes with the "system." prefix.  These are
>         used for storing ACL information and this is sometimes not
>         compatible between different filesystem types (e.g. ext4 and
>         NFSv4).  Standard Unix ownership permission flags (rwx) *are*
>         copied so this option does not risk giving away inappropriate
>         permissions unless the lowerfs uses unusual ACLs.
>
>

I am wondering if it would make more sense for nfs to register a
security_inode_copy_up_xattr() hook.
That is the mechanism that prevents copying up other security.*
xattrs?

Thanks,
Amir.
