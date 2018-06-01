Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:40206 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751964AbeFATOj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 15:14:39 -0400
Received: by mail-oi0-f42.google.com with SMTP id f79-v6so9444423oib.7
        for <linux-nfs@vger.kernel.org>; Fri, 01 Jun 2018 12:14:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180601174336.GF10666@fieldses.org>
References: <95e00ce46fe1f5fed50fe24947eee0dda51e0140.camel@hammerspace.com>
 <c59d0be3-a10b-02c3-8126-3402a6a0eab1@suse.de> <828f320cde910a45983d91bddb6477d21c5cae33.camel@hammerspace.com>
 <CAJfpegvuvFzNwSZRLCMCrhms-K4Ge=PTcn4uezLgV8U3ag+4xQ@mail.gmail.com>
 <20180601135033.GA10666@fieldses.org> <CAJfpegvG4rkesopg=qj1H288X6H9CXu=N_fuYEsuWJ-O=5785A@mail.gmail.com>
 <20180601142640.GC10666@fieldses.org> <CAJfpegtmSK5yuU-Vz7mPODy=iP+=BLMs2fy=sH-iWG8g3jeBfg@mail.gmail.com>
 <20180601160857.GE10666@fieldses.org> <CAJfpeguFobmD5EdvYU7eFaaShMYxt9j72k=GKGHyh3-D-uCB-Q@mail.gmail.com>
 <20180601174336.GF10666@fieldses.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 1 Jun 2018 21:14:38 +0200
Message-ID: <CAJfpegsjGEoych6QE2YcH8kkJ9B=Hfk47BMuJ7ECjMViMUpisA@mail.gmail.com>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 1, 2018 at 7:43 PM, bfields@fieldses.org
<bfields@fieldses.org> wrote:
> On Fri, Jun 01, 2018 at 07:02:20PM +0200, Miklos Szeredi wrote:
>> On Fri, Jun 1, 2018 at 6:08 PM, bfields@fieldses.org
>> <bfields@fieldses.org> wrote:
>> > On Fri, Jun 01, 2018 at 04:43:51PM +0200, Miklos Szeredi wrote:
>> >> Look at ovl_permission(), I think it pretty clearly describes this model.
>> >
>> > Thanks!  Uh, so generic_permission is the thing that just does the usual
>> > mode/acl checks on the in-core inode, and inode_permission is the one
>> > that also calls into the filesystem?
>>
>> Right.
>>
>> > But I'm still a little confused--if I'm reading right, "realinode" is
>> > the lower inode before copyup, and the upper inode after, so can't
>> > inode_permission(realinode, mask) return different results before and
>> > after copyup?
>>
>> Theoretically, yes.  Not in any sane setup, though.
>
> If root squashing is enabled and you mount as root, then it will change.
>
> That's not an unlikely case, it's pretty much the default.

Let's see: root squashing will change root creds to nobody's creds, right?

That results in a weird situation, where user foo is trying to access
a file owned by foo, but which doesn't have read permission for
"other" will not be able to perform a read on that file.  In fact, no
user will be able to read that file, including root.   Copying up the
file will also fail, since that requires read permission.

So for that case it's not true that permission will change, since
copy-up won't be possible.

That leaves the case where no read or write permissions are involved,
which is execute.  I think we should just mask that out from the
inode_permission() check.  Makes no sense to ask underlying filesystem
about execute permission.   With that we'll have consistent
permissions before and after copy-up.  Right?

Thanks,
Miklos
