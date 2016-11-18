Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35686 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbcKROQ0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 09:16:26 -0500
Received: by mail-wm0-f47.google.com with SMTP id a197so41073822wmd.0
        for <linux-nfs@vger.kernel.org>; Fri, 18 Nov 2016 06:16:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b702922d-c80c-799b-c83e-ff2d3cb74e08@dit.upm.es>
References: <56743FB6.80903@redhat.com> <20151218200840.GA28692@fieldses.org>
 <5677BCD4.4060009@redhat.com> <20151221164752.GA7869@fieldses.org>
 <56783DCC.1060201@redhat.com> <20151221201403.GB7869@fieldses.org>
 <2443f0d3-6937-ae92-d4d5-6e1f00a19e81@dit.upm.es> <20161108201611.GB26589@fieldses.org>
 <37f8eaf5-128c-ecd5-ae65-3b340c990171@dit.upm.es> <20161111190332.GA28132@fieldses.org>
 <20161111220425.GA30914@fieldses.org> <CAOssrKfupMvmpfk5fV1J6Hv5_FUSCjU0euGkY8aeU3kxgzEXMQ@mail.gmail.com>
 <b702922d-c80c-799b-c83e-ff2d3cb74e08@dit.upm.es>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Fri, 18 Nov 2016 15:16:18 +0100
Message-ID: <CAOssrKeMb7=d-gin1d7xiFSLX3Ak78WS4OJ09srVL_coWUH88g@mail.gmail.com>
Subject: Re: possible bug in nfs-kernel-server
To: Omar Walid Llorente <omar@dit.upm.es>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Soumya Koduri <skoduri@redhat.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        administracion del centro de calculo del dit
        <cdc@dit.upm.es>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 16, 2016 at 7:19 PM, Omar Walid Llorente <omar@dit.upm.es> wrote:

> In any case, the kernel we are using (3.13.0-96-generic #143-Ubuntu SMP Mon
> Aug 29 20:15:20 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux) has fuse included
> (not as a module) so if it would be necessary to change the fuse mount
> options some help would be needed.

Can you reproduce this on latest (e.g 4.8) kernel?

Also fuse debug logs (with whaterver kernel) could be useful; not sure
how to enable it for glusterfs, usual convention for fuse filesystems
is "-d".

Thanks,
Miklos
