Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:36398 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752996AbeFGLuL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2018 07:50:11 -0400
Received: by mail-ot0-f196.google.com with SMTP id c15-v6so1306635otl.3
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jun 2018 04:50:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180602005040.GH10666@fieldses.org>
References: <828f320cde910a45983d91bddb6477d21c5cae33.camel@hammerspace.com>
 <CAJfpegvuvFzNwSZRLCMCrhms-K4Ge=PTcn4uezLgV8U3ag+4xQ@mail.gmail.com>
 <20180601135033.GA10666@fieldses.org> <CAJfpegvG4rkesopg=qj1H288X6H9CXu=N_fuYEsuWJ-O=5785A@mail.gmail.com>
 <20180601142640.GC10666@fieldses.org> <CAJfpegtmSK5yuU-Vz7mPODy=iP+=BLMs2fy=sH-iWG8g3jeBfg@mail.gmail.com>
 <20180601160857.GE10666@fieldses.org> <CAJfpeguFobmD5EdvYU7eFaaShMYxt9j72k=GKGHyh3-D-uCB-Q@mail.gmail.com>
 <20180601174336.GF10666@fieldses.org> <CAJfpegsjGEoych6QE2YcH8kkJ9B=Hfk47BMuJ7ECjMViMUpisA@mail.gmail.com>
 <20180602005040.GH10666@fieldses.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 7 Jun 2018 13:50:09 +0200
Message-ID: <CAJfpegtt8jZ0j_3gwSSUUc6bC7NF6s6qtFEJELztsevLdWROZQ@mail.gmail.com>
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

On Sat, Jun 2, 2018 at 2:50 AM, bfields@fieldses.org
<bfields@fieldses.org> wrote:
> On Fri, Jun 01, 2018 at 09:14:38PM +0200, Miklos Szeredi wrote:
>> On Fri, Jun 1, 2018 at 7:43 PM, bfields@fieldses.org
>> <bfields@fieldses.org> wrote:
>> > On Fri, Jun 01, 2018 at 07:02:20PM +0200, Miklos Szeredi wrote:
>> >> On Fri, Jun 1, 2018 at 6:08 PM, bfields@fieldses.org
>> >> <bfields@fieldses.org> wrote:
>> >> > On Fri, Jun 01, 2018 at 04:43:51PM +0200, Miklos Szeredi wrote:
>> >> >> Look at ovl_permission(), I think it pretty clearly describes this model.
>> >> >
>> >> > Thanks!  Uh, so generic_permission is the thing that just does the usual
>> >> > mode/acl checks on the in-core inode, and inode_permission is the one
>> >> > that also calls into the filesystem?
>> >>
>> >> Right.
>> >>
>> >> > But I'm still a little confused--if I'm reading right, "realinode" is
>> >> > the lower inode before copyup, and the upper inode after, so can't
>> >> > inode_permission(realinode, mask) return different results before and
>> >> > after copyup?
>> >>
>> >> Theoretically, yes.  Not in any sane setup, though.
>> >
>> > If root squashing is enabled and you mount as root, then it will change.
>> >
>> > That's not an unlikely case, it's pretty much the default.
>>
>> Let's see: root squashing will change root creds to nobody's creds, right?
>>
>> That results in a weird situation, where user foo is trying to access
>> a file owned by foo, but which doesn't have read permission for
>> "other" will not be able to perform a read on that file.  In fact, no
>> user will be able to read that file, including root.   Copying up the
>> file will also fail, since that requires read permission.
>>
>> So for that case it's not true that permission will change, since
>> copy-up won't be possible.
>
> Fair enough.  That's still pretty weird behavior.
>
> Arguably if you're going to do something different here then maybe it's
> good for the difference to manifest in a way that's really obvious in
> common cases, so people don't just overlook it.
>
>> That leaves the case where no read or write permissions are involved,
>> which is execute.  I think we should just mask that out from the
>> inode_permission() check.  Makes no sense to ask underlying filesystem
>> about execute permission.
>
> I suppose so.
>
>> With that we'll have consistent permissions before and after copy-up.
>> Right?
>
> Hm.  If inode_permission(realinode, mask) changes across copy-up:
>
>         - if the difference is in execute, you're telling me we'll
>           ignore that.
>         - if it changes from denying to allowing read, you don't care
>           since that will prevent the copy up in the first place.
>         - if it changes from denying to allowing write, that has no
>           effect since you only care about read permission for copyup in
>           the case someone requests write permission.  (Hm, the special
>           file case should be weird.  I guess those just don't get
>           copied up?  Still I think people will be surprised by
>           permission failures here.)

Special file can get copied up on metadata change.  We shoudln't ask
server at all for permissions in this case.  That would be consistent
with the "cp -a" model.

>         - if it changes from allowing read or write to denying--then
>           we're no longer talking about root, assuming the permission
>           check on the copied-up inode wouldn't fail for root.  We don't
>           currently allow non-root to mount NFS, but there are people
>           that would like to see that change.

The "cp -a" model should work even for userns unprivileged mounts.  We
do assume a certain sanity with setups: I'm sure someone could come up
with a setup (e.g. with selinux) where weirdness happens after
copy-up.

Thanks,
Miklos



>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-unionfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
