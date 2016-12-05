Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35487 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbcLETiA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 14:38:00 -0500
MIME-Version: 1.0
In-Reply-To: <20161205162559.GB17517@fieldses.org>
References: <5a6862bd-924d-25e4-2a8e-ba4f51e66604@web.de> <CAJfpeguwUtRWRGmNmimNp-FXzWqMCCQMb24iWPu0w_J0_rOnnw@mail.gmail.com>
 <20161205151933.GA17517@fieldses.org> <CAJfpegtpkavseTFLspaC7svbvHRq-0-7jvyh63+DK5iWHTGnaQ@mail.gmail.com>
 <20161205162559.GB17517@fieldses.org>
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Date: Mon, 5 Dec 2016 20:37:56 +0100
Message-ID: <CAHpGcMKHjic6L+J0qvMYNG9hVCcDO1hEpx4BiEk0ZCKDV39BmA@mail.gmail.com>
Subject: Re: [PATCH] overlayfs: ignore empty NFSv4 ACLs in ext4 upperdir
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>,
        Patrick Plagwitz <Patrick_Plagwitz@web.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2016-12-05 17:25 GMT+01:00 J. Bruce Fields <bfields@fieldses.org>:
> On Mon, Dec 05, 2016 at 04:36:03PM +0100, Miklos Szeredi wrote:
>> On Mon, Dec 5, 2016 at 4:19 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> >> Can NFS people comment on this?  Where does the nfs4_acl come from?
>> >
>> > This is the interface the NFS client provides for applications to modify
>> > NFSv4 ACLs on servers that support them.
>>
>> Fine, but why are we seeing this xattr on exports where no xattrs are
>> set on the exported fs?
>
> I don't know.  I took another look at the original patch and don't see
> any details on the server setup: which server is it (knfsd, ganesha,
> netapp, ...)?  How is it configured?
>
>> >> What can overlayfs do if it's a non-empty ACL?
>> >
>> > As little as possible.  You can't copy it up, can you?  So any attempt
>> > to support it is going to be incomplete.
>>
>> Right.
>>
>> >
>> >> Does knfsd translate posix ACL into NFS acl?  If so, we can translate
>> >> back.  Should we do a generic POSIX<->NFS acl translator?
>> >
>> > knsd does translate between POSIX and NFSv4 ACLs.  It's a complicated
>>
>> This does explain the nfs4_acl xattr on the client.  Question: if it's
>> empty, why have it at all?
>
> I'm honestly not sure what's going on there.  I'd be curious to see a
> network trace if possible.

I do see "system.nfs4_acl" attributes on knfsd exported filesystems
that support POSIX ACLs (for ext4: "mount -o acl"). For exported
filesystem that don't support POSIX ACLs (ext4: mount -o noacl), that
attribute is missing. The attribute shouldn't be empty though; when
the file has no real ACL, "system.nfs4_acl" represents the file mode
permissions. The "system.nfs4_acl" attribute exposes the information
on the wire; there is no resonable way to translate that into an ACL
on another filesystem, really.

Patrick, what does 'getfattr -m- -d /nfs/file' give you?

>> > algorithm, and lossy (in the NFSv4->POSIX direction).  The client
>> > developers have been understandably reluctant to have anything to do
>> > with it.
>> >
>> > So, I think listxattr should omit system.nfs4_acl, and attempts to
>> > set/get the attribute should error out.  The same should apply to any
>> > "system." attribute not supported by both filesystems, I think?
>>
>> Basically that's what happens now.  The problem is that nfsv4 mounts
>> seem always have these xattrs, even when the exported fs doesn't have
>> anything.
>
> I said "both", that's a logical "and".  Whether or not nfs claims
> support would then be irrelevant in this case, since ext4 doesn't
> support system.nfs4_acl.
>
>> We could do the copy up even if the NFS4->POSIX translation was
>> possible (which is the case with POSIX ACL translated by knfsd).  We'd
>> just get back the original ACL, so that's OK.
>
> Note that knfsd is an exception, most NFSv4-acl-supporting servers
> aren't translating from POSIX ACLs.
>
>> NFS is only supported as lower (read-only) layer, so we don't care
>> about changing the ACL on the server.
>
> Out of curiosity, how do you check permissions after copy up?
>
> The client doesn't do much permissions-checking normally, because it's
> hard to get right--even in the absence of ACLs, it may not understand
> the server's owners and groups completely.
>
> I guess that's fine, you may be happy to let people write to the file
> without permissions to the lower file, since the writes aren't going
> there anyway.
>
> So, I don't know what want here.
>
> You're not going to want to use the ACL for actual permission-checking,
> and you can't modify it, so it doesn't seem very useful.

IMO the only thing overlayfs can do is hide those attributes from the
user and ignore them when copying up. Still, the attributes shouldn't
be empty.

Andreas
