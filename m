Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:38236 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751722AbdCCVNT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 3 Mar 2017 16:13:19 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170303204747.GE13877@fieldses.org>
Date: Fri, 3 Mar 2017 16:08:19 -0500
CC: Christoph Hellwig <hch@infradead.org>,
        <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Message-ID: <4B2A2E86-AFC8-49EA-9D53-7A53AD824CF1@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org> <20170303204747.GE13877@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 3, 2017, at 3:47 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Thu, Mar 02, 2017 at 08:22:21AM -0800, Christoph Hellwig wrote:
>> On Thu, Mar 02, 2017 at 11:01:05AM -0500, Olga Kornievskaia wrote:
>>> +	if (pos_in >=3D i_size_read(inode_in))
>>> +		return -EINVAL;
>>=20
>> That's not how the syscall is supposed to work, we'd rather do a
>> short read^^^^^copy.
>=20
> That's what I think too, but then is COPY(2) wrong?:
>=20
> 	EINVAL Requested  range  extends beyond the end of the source
> 	  file; or the flags argument is not 0.
>=20
> Also, copy_file_range can be implemented by ->clone_file_range, where
> these kinds of checks make more sense, I think; e.g. from btrfs:
>=20
> 	ret =3D -EINVAL;
> 	if (off + len > src->i_size || off + len < off)
> 		goto out_unlock;
>=20
> Well, so the caller just has to be prepared for either behavior, I
> guess, but that may make it more complicated to use.
>=20

I=E2=80=99m still rather very confused again by the comment and what it =
is proposing.

There are two checks to consider for the validity of the arguments

1. If the offset of the source file is beyond the end of the source =
file.
2. If the offset + len is beyond the end of the file.

I read that the man page is talking about #2.  This is actually what the =
NFSv4.2 spec required for the COPY too but we=E2=80=99ve been discussing =
that it should be a short read instead.

This patch address is to address case #1. As far as I can tell it =
applies to all file systems.

Are you suggesting that the checks for the validity of the arguments do =
not belong in VFS but instead should be in each of the underlying file =
systems?

Not all vfs_copy_file_range() are implemented via clone_file_range(). At =
least I hope that =E2=80=9Cinter=E2=80=9D NFSv4.2 COPY will also use =
vfs_file_copy_range() and it would not be calling clone().


> --b.

