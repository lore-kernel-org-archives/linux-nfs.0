Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58278 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751502AbeFANue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 09:50:34 -0400
Date: Fri, 1 Jun 2018 09:50:33 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
Message-ID: <20180601135033.GA10666@fieldses.org>
References: <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com>
 <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
 <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
 <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
 <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
 <d6fab628-6fd1-de33-2ca4-d82917205ce7@suse.de>
 <95e00ce46fe1f5fed50fe24947eee0dda51e0140.camel@hammerspace.com>
 <c59d0be3-a10b-02c3-8126-3402a6a0eab1@suse.de>
 <828f320cde910a45983d91bddb6477d21c5cae33.camel@hammerspace.com>
 <CAJfpegvuvFzNwSZRLCMCrhms-K4Ge=PTcn4uezLgV8U3ag+4xQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegvuvFzNwSZRLCMCrhms-K4Ge=PTcn4uezLgV8U3ag+4xQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 01, 2018 at 03:32:59PM +0200, Miklos Szeredi wrote:
> How do you define "safely"?
> 
> Is it safe for root to do
> 
>   cp -a /nfs/remotedir /tmp/localdir
> 
> ?
> 
> That's essentially what an overlayfs mount with an NFS layer does with
> respect to access permissions:
> 
>  - remote files are not modifiable to anyone, unless server allows
> 
>  - remote files *readable to root* will provide access based on local DAC check.
> 
> Does that need to be made clear in the docs?  Surely.  But it does NOT
> mean it's dangerous or that it's not useful with an arbitrary NFS
> server

We should definitely have clear documentation, but despite that, in
practice lots of people *will* be surprised when permissions are
enforced differently after copy-up, and those surprises may well have
unpleasant implications.

And the differences will depend on details of the server implementation,
which makes documenting the behavior and giving people the correct
expectations that much more complicated.

> (although my guess is that 99% will involve knfsd).

Why is that?  There are a *lot* of Linux clients out there talking to
non-knfsd servers.  I wouldn't have thought knfsd is even a
majority--but of course it depends very much on what kind of use exactly
we're measuring.  And I don't have any numbers.

--b.
