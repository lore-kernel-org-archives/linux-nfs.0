Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:39153 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755359AbeEaO0x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 10:26:53 -0400
Received: by mail-oi0-f45.google.com with SMTP id t22-v6so16230065oih.6
        for <linux-nfs@vger.kernel.org>; Thu, 31 May 2018 07:26:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180531140619.GA1298@fieldses.org>
References: <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
 <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de> <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
 <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de> <20180531004554.GA29116@fieldses.org>
 <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com>
 <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
 <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
 <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
 <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com> <20180531140619.GA1298@fieldses.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 31 May 2018 16:26:51 +0200
Message-ID: <CAJfpegtOz-b6frP_jSEwWmgdjiDNkrT=bZALpf8jVAWPFTRi8g@mail.gmail.com>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2018 at 4:06 PM, bfields@fieldses.org
<bfields@fieldses.org> wrote:
> On Thu, May 31, 2018 at 03:30:04PM +0200, Miklos Szeredi wrote:
>> On Thu, May 31, 2018 at 3:10 PM, Trond Myklebust
>> <trondmy@hammerspace.com> wrote:
>> > On Thu, 2018-05-31 at 14:55 +0200, Miklos Szeredi wrote:
>> >> On Thu, May 31, 2018 at 2:47 PM, Trond Myklebust <trondmy@hammerspace.com> wrote:
>> >> > I'm still in strong disagreement with the model you are presenting
>> >> > here. It is a client enforced model, which is not ever going to be
>> >> > compatible with the NFS model.
>> >>
>> >> It's the only sane model that overlayfs can do.
>> >>
>> >> Think of it this way:  creating an image file on NFS, formating it to
>> >> ext4 and mounting it locally through the loop device is not going to
>> >> be compatible with the NFS security model either.  Should we care?
>> >
>> > Yes you should care because you are proposing that the simple act of
>> > mounting through overlayfs will change who can access, read and modify
>> > existing files from a NFS server.
>>
>> Only access/read: NFS can only be read-only layer.  So it's impossible
>> to actually modify a file on NFS through overlayfs.
>
> In addition to being read-only, I assume it's also unchanging?  I wonder
> why you'd want to use NFS at all for this case--sharing a read-only
> ext4-formatted block device would seem more straightforward.

Actually we could allow changes on the server side.   Overlayfs sort
of does this already (calls underlying fs's ->d_revalidate() from
ovl_dentry_revalidate()).  What's still needed is to detect rename by
rechecking parent and d_name to match overlay dentry's parent and
d_name.

But a shared block dev could be used in most cases, I guess.

Thanks,
Miklos
