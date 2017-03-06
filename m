Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:4052 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753652AbdCFQ2E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Mar 2017 11:28:04 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 01/19] Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170304021008.GB21609@fieldses.org>
Date: Mon, 6 Mar 2017 11:27:23 -0500
CC: Christoph Hellwig <hch@infradead.org>,
        <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Message-ID: <924FF7A2-27CD-4848-BD61-748758C2533F@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org> <20170303204747.GE13877@fieldses.org>
 <4B2A2E86-AFC8-49EA-9D53-7A53AD824CF1@netapp.com>
 <20170303213230.GF13877@fieldses.org>
 <B3F80DA0-B4F8-4628-88C5-E5C047620F17@netapp.com>
 <20170304021008.GB21609@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 3, 2017, at 9:10 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Fri, Mar 03, 2017 at 05:46:05PM -0500, Olga Kornievskaia wrote:
>>=20
>>> On Mar 3, 2017, at 4:32 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>>>=20
>>> On Fri, Mar 03, 2017 at 04:08:19PM -0500, Olga Kornievskaia wrote:
>>>>=20
>>>>> On Mar 3, 2017, at 3:47 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>>>>>=20
>>>>> On Thu, Mar 02, 2017 at 08:22:21AM -0800, Christoph Hellwig wrote:
>>>>>> On Thu, Mar 02, 2017 at 11:01:05AM -0500, Olga Kornievskaia =
wrote:
>>>>>>> +	if (pos_in >=3D i_size_read(inode_in))
>>>>>>> +		return -EINVAL;
>>>>>>=20
>>>>>> That's not how the syscall is supposed to work, we'd rather do a
>>>>>> short read^^^^^copy.
>>>>>=20
>>>>> That's what I think too, but then is COPY(2) wrong?:
>>>>>=20
>>>>> 	EINVAL Requested  range  extends beyond the end of the source
>>>>> 	  file; or the flags argument is not 0.
>>>>>=20
>>>>> Also, copy_file_range can be implemented by ->clone_file_range, =
where
>>>>> these kinds of checks make more sense, I think; e.g. from btrfs:
>>>>>=20
>>>>> 	ret =3D -EINVAL;
>>>>> 	if (off + len > src->i_size || off + len < off)
>>>>> 		goto out_unlock;
>>>>>=20
>>>>> Well, so the caller just has to be prepared for either behavior, I
>>>>> guess, but that may make it more complicated to use.
>>>>>=20
>>>>=20
>>>> I=E2=80=99m still rather very confused again by the comment and =
what it is proposing.
>>>>=20
>>>> There are two checks to consider for the validity of the arguments
>>>>=20
>>>> 1. If the offset of the source file is beyond the end of the source =
file.
>>>> 2. If the offset + len is beyond the end of the file.
>>>>=20
>>>> I read that the man page is talking about #2.  This is actually =
what the NFSv4.2 spec required for the COPY too but we=E2=80=99ve been =
discussing that it should be a short read instead.
>>>>=20
>>>> This patch address is to address case #1. As far as I can tell it =
applies to all file systems.
>>>>=20
>>>> Are you suggesting that the checks for the validity of the =
arguments do not belong in VFS but instead should be in each of the =
underlying file systems?
>>>>=20
>>>> Not all vfs_copy_file_range() are implemented via =
clone_file_range(). At least I hope that =E2=80=9Cinter=E2=80=9D NFSv4.2 =
COPY will also use vfs_file_copy_range() and it would not be calling =
clone().
>>>=20
>>> I think it'd be acceptable for copy_file_range() to just return 0 =
even
>>> in your case 1.  I believe that's what ordinary read and pread does.
>>>=20
>>> You probably can't perform it atomically with the copy, so it's =
possible
>>> that the size will change right after you check it.
>>>=20
>>> I don't see a benefit to the check.
>>=20
>=20
>> In read() you don=E2=80=99t specify the offset from which to read. It =
is read
>> from the current file descriptor offset. I don=E2=80=99t find the =
comparison
>> equal.=20
>>=20
>> It=E2=80=99s it more fair to compare it to lseek() which does return =
EINVAL if
>> you specify position beyond the end of the file.=20
>=20
> Or pread(), which takes an offset.
>=20
> But read() can read at an offset at the end of file, or even past that
> (if the file was truncated), and I believe it just returns 0 in those
> cases.
>=20

I don=E2=80=99t see copy_file_range() specifying that 0 means end of the =
file. Are you arguing to add that meaning to the function call? I guess =
in that case we=E2=80=99d need to take extra care to never return 0bytes =
to the client as a =E2=80=9Cpartial=E2=80=9D copy (say due to server =
rebooting).

Unless changed, NFS4.2 mandates the two checks that I=E2=80=99ve =
specified. I can add the checks in the NFS implementation itself. =
However, we thought at least this check belonged in the VFS layer. I=E2=80=
=99m really not super attached to getting into VFS. Actually the 2nd =
check is something that copy_file_range() man pages say should return =
EINVAL but the VFS code doesn=E2=80=99t enforce it.=20





