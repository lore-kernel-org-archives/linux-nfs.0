Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:37165 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbeFANdA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 09:33:00 -0400
Received: by mail-oi0-f41.google.com with SMTP id l22-v6so14763521oib.4
        for <linux-nfs@vger.kernel.org>; Fri, 01 Jun 2018 06:33:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <828f320cde910a45983d91bddb6477d21c5cae33.camel@hammerspace.com>
References: <f74fae81-d1bc-1c0e-7b41-69502bd7c489@suse.de> <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
 <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de> <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
 <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de> <20180531004554.GA29116@fieldses.org>
 <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com>
 <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
 <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
 <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
 <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
 <d6fab628-6fd1-de33-2ca4-d82917205ce7@suse.de> <95e00ce46fe1f5fed50fe24947eee0dda51e0140.camel@hammerspace.com>
 <c59d0be3-a10b-02c3-8126-3402a6a0eab1@suse.de> <828f320cde910a45983d91bddb6477d21c5cae33.camel@hammerspace.com>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 1 Jun 2018 15:32:59 +0200
Message-ID: <CAJfpegvuvFzNwSZRLCMCrhms-K4Ge=PTcn4uezLgV8U3ag+4xQ@mail.gmail.com>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 1, 2018 at 3:16 PM, Trond Myklebust <trondmy@hammerspace.com> wrote:

> ...and all I'm doing is pointing out that as long as you insist on
> client enforcement of file security, then you are heavily limiting the
> list of servers and server configurations that you will be able to work
> safely with. There is a reason why, in all the 30 years since the NFSv2
> spec was released, nobody has built such a client.

How do you define "safely"?

Is it safe for root to do

  cp -a /nfs/remotedir /tmp/localdir

?

That's essentially what an overlayfs mount with an NFS layer does with
respect to access permissions:

 - remote files are not modifiable to anyone, unless server allows

 - remote files *readable to root* will provide access based on local DAC check.

Does that need to be made clear in the docs?  Surely.  But it does NOT
mean it's dangerous or that it's not useful with an arbitrary NFS
server (although my guess is that 99% will involve knfsd).

Thanks,
Miklos
