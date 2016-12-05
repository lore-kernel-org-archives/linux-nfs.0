Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33958 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbcLEXYd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 18:24:33 -0500
MIME-Version: 1.0
In-Reply-To: <CAHpGcMKmtppfn7PVrGKEEtVphuLV=YQ2GDYKOqje4ZANhzSgDw@mail.gmail.com>
References: <5a6862bd-924d-25e4-2a8e-ba4f51e66604@web.de> <CAJfpeguwUtRWRGmNmimNp-FXzWqMCCQMb24iWPu0w_J0_rOnnw@mail.gmail.com>
 <20161205151933.GA17517@fieldses.org> <CAJfpegtpkavseTFLspaC7svbvHRq-0-7jvyh63+DK5iWHTGnaQ@mail.gmail.com>
 <20161205162559.GB17517@fieldses.org> <CAHpGcMKHjic6L+J0qvMYNG9hVCcDO1hEpx4BiEk0ZCKDV39BmA@mail.gmail.com>
 <266c571f-e4e2-7c61-5ee2-8ece0c2d06e9@web.de> <CAHpGcMKmtppfn7PVrGKEEtVphuLV=YQ2GDYKOqje4ZANhzSgDw@mail.gmail.com>
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Date: Tue, 6 Dec 2016 00:24:30 +0100
Message-ID: <CAHpGcMKjscfhmrAhwGes0ag2xTkbpFvCO6eiLL_rHz87XE-ZmA@mail.gmail.com>
Subject: Re: [PATCH] overlayfs: ignore empty NFSv4 ACLs in ext4 upperdir
To: Patrick Plagwitz <Patrick_Plagwitz@web.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Miklos Szeredi <miklos@szeredi.hu>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2016-12-06 0:19 GMT+01:00 Andreas Gr=C3=BCnbacher <andreas.gruenbacher@gmai=
l.com>:
> 2016-12-05 23:58 GMT+01:00 Patrick Plagwitz <Patrick_Plagwitz@web.de>:
>> On 12/05/2016 08:37 PM, Andreas Gr=C3=BCnbacher wrote:
>>> 2016-12-05 17:25 GMT+01:00 J. Bruce Fields <bfields@fieldses.org>:
>>>> On Mon, Dec 05, 2016 at 04:36:03PM +0100, Miklos Szeredi wrote:
>>>>> On Mon, Dec 5, 2016 at 4:19 PM, J. Bruce Fields <bfields@fieldses.org=
> wrote:
>>>>>>> Can NFS people comment on this?  Where does the nfs4_acl come from?
>>>>>>
>>>>>> This is the interface the NFS client provides for applications to mo=
dify
>>>>>> NFSv4 ACLs on servers that support them.
>>>>>
>>>>> Fine, but why are we seeing this xattr on exports where no xattrs are
>>>>> set on the exported fs?
>>>>
>>>> I don't know.  I took another look at the original patch and don't see
>>>> any details on the server setup: which server is it (knfsd, ganesha,
>>>> netapp, ...)?  How is it configured?
>>>>
>>>>>>> What can overlayfs do if it's a non-empty ACL?
>>>>>>
>>>>>> As little as possible.  You can't copy it up, can you?  So any attem=
pt
>>>>>> to support it is going to be incomplete.
>>>>>
>>>>> Right.
>>>>>
>>>>>>
>>>>>>> Does knfsd translate posix ACL into NFS acl?  If so, we can transla=
te
>>>>>>> back.  Should we do a generic POSIX<->NFS acl translator?
>>>>>>
>>>>>> knsd does translate between POSIX and NFSv4 ACLs.  It's a complicate=
d
>>>>>
>>>>> This does explain the nfs4_acl xattr on the client.  Question: if it'=
s
>>>>> empty, why have it at all?
>>>>
>>>> I'm honestly not sure what's going on there.  I'd be curious to see a
>>>> network trace if possible.
>>>
>>> I do see "system.nfs4_acl" attributes on knfsd exported filesystems
>>> that support POSIX ACLs (for ext4: "mount -o acl"). For exported
>>> filesystem that don't support POSIX ACLs (ext4: mount -o noacl), that
>>> attribute is missing. The attribute shouldn't be empty though; when
>>> the file has no real ACL, "system.nfs4_acl" represents the file mode
>>> permissions. The "system.nfs4_acl" attribute exposes the information
>>> on the wire; there is no resonable way to translate that into an ACL
>>> on another filesystem, really.
>>>
>>> Patrick, what does 'getfattr -m- -d /nfs/file' give you?
>>>
>> getfattr -m - -d nfs/folder -e text gives
>>
>> # file: nfs/folder/
>> system.nfs4_acl=3D"\000\000\000^C\000\000\000\000\000\000\000\000\000^V^=
A<E7>\000\000\000^FOWNER@\000\000\000\000\000\000\000\000\000\000\000^R\000=
<A1>\000\000\000^FGROUP@\000\000\000\000\000\000\000\000\000\000\000^R\000<=
A1>\000\000\000
>>     EVERYONE@\000\000"
>>
>> Those are 80 bytes. I checked again and vfs_getxattr indeed returns size=
=3D80.
>> It just looked empty because the first byte is 0... Ok, so nfs4_acl is n=
ot
>> empty after all and checking *value =3D=3D 0 does not tell if there are =
actually
>> ACLs present or not, sorry for the confusion.
>>
>> You are right, when I mount the exported fs with noacl the problem goes =
away.
>> You already helped me there, thanks.
>>
>> Still, I think there should be a way to copy up files that actually have=
 no
>> ACLs since acl is often the default for ext4 mounts and giving an "Opera=
tion
>> not supported" for random open(2)s is not a very good way to convey what=
's
>> going on.
>
> It's not hard to come up with a heuristic that determines if a
> system.nfs4_acl value is equivalent to a file mode, and to ignore the
> attribute in that case. (The file mode is transmitted in its own
> attribute already, so actually converting .) That way, overlayfs could
> still fail copying up files that have an actual ACL. It's still an
> ugly hack ...

Actually, that kind of heuristic would make sense in the NFS client
which could then hide the "system.nfs4_acl" attribute.

Andreas
