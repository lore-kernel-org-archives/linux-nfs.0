Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36967 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941583AbcKOKN3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Nov 2016 05:13:29 -0500
Received: by mail-wm0-f50.google.com with SMTP id t79so157840388wmt.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Nov 2016 02:13:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161111220425.GA30914@fieldses.org>
References: <56743FB6.80903@redhat.com> <20151218200840.GA28692@fieldses.org>
 <5677BCD4.4060009@redhat.com> <20151221164752.GA7869@fieldses.org>
 <56783DCC.1060201@redhat.com> <20151221201403.GB7869@fieldses.org>
 <2443f0d3-6937-ae92-d4d5-6e1f00a19e81@dit.upm.es> <20161108201611.GB26589@fieldses.org>
 <37f8eaf5-128c-ecd5-ae65-3b340c990171@dit.upm.es> <20161111190332.GA28132@fieldses.org>
 <20161111220425.GA30914@fieldses.org>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Tue, 15 Nov 2016 11:13:27 +0100
Message-ID: <CAOssrKfupMvmpfk5fV1J6Hv5_FUSCjU0euGkY8aeU3kxgzEXMQ@mail.gmail.com>
Subject: Re: possible bug in nfs-kernel-server
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Omar Walid Llorente <omar@dit.upm.es>,
        Soumya Koduri <skoduri@redhat.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        =?UTF-8?Q?administraci=C3=B3n_del_centro_de_c=C3=A1lculo_del_dit?=
        <cdc@dit.upm.es>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 11, 2016 at 11:04 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> So if I'm reading right, the setup is
>
>         nfs client---NFSv3--->knfsd---FUSE-->gluster
>
> I hate to just pass the buck, but my bet is on the issue being either on
> the gluster side, or on limitations of the fuse protocol itself.
>
> Cc'ing Miklos as I believe he did the original fuse nfsd export
> implementation.  Miklos, does fuse has a way for file owners to override
> permissions?  We need this sometimes because for example, an application
> may hold a write open on a read-only file, but the server doesn't itself
> already have an open (which can happen for lots of reasons).

Is glusterfs using "default_permissions" fuse option?

If so, then the above shouldn't be an issue, since permission checking
is done by generic_permission() which works the same for all
filesystems.

If not, then there's the same problem as re-exporting NFSv4 as NFSv3
would have: the permissions are not checked in ->permission(), but in
e.g. ->atomic_open() so nfsd's override mechanism wouldn't work.

Thanks,
Miklos
