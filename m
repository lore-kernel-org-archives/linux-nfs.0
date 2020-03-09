Return-Path: <SRS0=ypvk=42=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66AFDC18E5A
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Mar 2020 13:12:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 40D9D2253D
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Mar 2020 13:12:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jgmg7AQO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726427AbgCINMo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 9 Mar 2020 09:12:44 -0400
Received: from mail-oi1-f193.google.com ([209.85.167.193]:36596 "EHLO
        mail-oi1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725956AbgCINMo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2020 09:12:44 -0400
Received: by mail-oi1-f193.google.com with SMTP id t24so10089272oij.3;
        Mon, 09 Mar 2020 06:12:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YMXkCHfi6tRjigLBwiP/Sb8yB6KUUIstGIL9eSbm0bM=;
        b=jgmg7AQODy6ArktDYFhSC5bvkoB84U/ZJaWMvQCDcDb0xjtZovx2vu6MsllR5obLkx
         r26y2Yrs6uCYe8ISzVfIxisOp56N76S/BSC0Bi1ClmUVRt/w1HxcTYfdnwZ0SGP4MluD
         vtbBl+9UuyX61nK3/4mcWprAHgl8Dwda0Ry56rPFZMWOdQyqTd1kbgoQneqPE/JWHXso
         3uMoP6vtMfvJ6RSvdJS0pY+0zISDb9E2KhroK3+gKb9NVB74sP4C33DFj4iz6PPWrfu3
         wYYZVly9LpY6ydONDIcZ1v8T6Wu94y+1n7Ro9I8VaPtBGsKgw6xYLvMMFPpRuNYXG6/w
         +T0w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=YMXkCHfi6tRjigLBwiP/Sb8yB6KUUIstGIL9eSbm0bM=;
        b=VhvxBa4qVnePAZpJLcYoolU2jdF2MPTEhGXIGfSm9bNomGZ/DmaonnKnzogtt3CviC
         fgkGPg3Rgq4D1lIv4LO9Q4/li7xBgeiqCXRG2tzr3TxpoHCD/9sqFyNvKBN3Fy98KFrj
         owBcTBXtbwghe6hdxvnskSp5lZFNmsPOGgEQ1vinzgHKDjzMlrTYp0fmAwpwpR0Ckdbj
         X5a01r5Zg2Yz/54XNR09JT8EA2uKfg0+a2shPhQaWZsGxmKFtgoKmB0twssJ5tYu+n0S
         6PLXzF68qh0oGmFenqOfntAvTIJT/8OQ3y7r0UVamdFS5Cgp+o2shb+toJmTd/zRfWjb
         X49A==
X-Gm-Message-State: ANhLgQ3v4dzmZnKN0ZRdhQcPe92XzEumFfqbplt09ejkibS6hDX0s39a
        quLonF8XA31s2hU2cc9pphey6FsyHgU/4ji4SZdpzlGs
X-Google-Smtp-Source: ADFU+vtGXNpeFPg+WeR7uhlMwhqgvgsClXO+332D7czk0EJc5VEHbsNbQzkY+WapxbTIOYnxmQkej9W2Yz0lNAN5RhI=
X-Received: by 2002:a05:6808:34c:: with SMTP id j12mr10737228oie.92.1583759563233;
 Mon, 09 Mar 2020 06:12:43 -0700 (PDT)
MIME-Version: 1.0
References: <20200303225837.1557210-1-smayhew@redhat.com> <6bb287d1687dc87fe9abc11d475b3b9df061f775.camel@btinternet.com>
 <20200304143701.GB3175@aion.usersys.redhat.com> <CAEjxPJ7A1KRJ3+o0-edW3byYBSjGa7=KnU5QaYCiVt6Lq6ZfpA@mail.gmail.com>
 <20200306220132.GD3175@aion.usersys.redhat.com>
In-Reply-To: <20200306220132.GD3175@aion.usersys.redhat.com>
From:   Stephen Smalley <stephen.smalley.work@gmail.com>
Date:   Mon, 9 Mar 2020 09:14:19 -0400
Message-ID: <CAEjxPJ4MhEOVsZLopVgKNF-E2-OwuL3a-c167ngO68B6uUdqNw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Ensure security label is set for root inode
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     Richard Haines <richard_c_haines@btinternet.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>, linux-nfs@vger.kernel.org,
        SElinux list <selinux@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 6, 2020 at 5:01 PM Scott Mayhew <smayhew@redhat.com> wrote:
>
> On Wed, 04 Mar 2020, Stephen Smalley wrote:
> > I'm not sure that rootcontext= should be supported or is supportable
> > over labeled NFS.
>
> Should rootcontext= be supported for NFS versions < 4.2?  If not then
> maybe it that option should be rejected for nfs and nfs4 fstypes in
> selinux_set_mnt_opts().

Looks like it gets ignored currently?
$ sudo exportfs -orw,no_root_squash localhost:/home
$ sudo mkdir -p /mnt/selinux-testsuite
$ sudo mount -t nfs -o vers=4.0,rootcontext=system_u:object_r:etc_t:s0
localhost:/home/sds/selinux-testsuite /mnt/selinux-testsuite
$ ls -Zd /mnt/selinux-testsuite
system_u:object_r:nfs_t:s0 /mnt/selinux-testsuite
$ mount | grep testsuite
localhost:/home/sds/selinux-testsuite on /mnt/selinux-testsuite type
nfs4 (rw,relatime,rootcontext=system_u:object_r:etc_t:s0,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp6,timeo=600,retrans=2,sec=sys,clientaddr=::1,local_lock=none,addr=::1)

I don't think we need to support it, but I don't know if we explicitly
need to test and reject it for nfs/nfs4.

> > It's primary use case is to allow assigning a specific context other
> > than the default policy-defined one
> > to the root directory for filesystems that support labeling but don't
> > have existing labels on their root
> > directories, e.g. tmpfs mounts.  Even if we set the rootcontext based
> > on rootcontext= during mount(2),
> > it would likely get overridden by subsequent attribute fetches from
> > the server I would think (e.g. it probably
> > already switches to the context from the server after 30 seconds or
>
> Yes, that's what happens.  If we wanted to retain that behavior moving
> forward, then we need to avoid calling nfs_setsecurity() for the root
> inode when the rootcontext= option was used.  To do that, I think we'd
> need to add a flag that could be passed back to NFS via the
> set_kern_flags parameter of selinux_set_mnt_opts().

Doesn't seem justified.

> > so?). As long as the separate context= option
> > continues to work correctly on NFS, I'm not overly concerned about this.
>
> Yep, the context= option still works.

Great, then I have no objections to this patch.
