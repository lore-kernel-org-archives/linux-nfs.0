Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:36763 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751206AbdCBSeL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 13:34:11 -0500
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 1/3] fs: Don't copy beyond the end of the file
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170302165839.GC5269@birch.djwong.org>
Date: Thu, 2 Mar 2017 13:21:49 -0500
CC: <linux-fsdevel@vger.kernel.org>, <hch@lst.de>,
        <linux-nfs@vger.kernel.org>
Message-ID: <9265113A-877D-4C62-9A3F-65D09D0FC404@netapp.com>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-2-kolga@netapp.com>
 <20170302165839.GC5269@birch.djwong.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 2, 2017, at 11:58 AM, Darrick J. Wong <darrick.wong@oracle.com> =
wrote:
>=20
> On Thu, Mar 02, 2017 at 11:02:09AM -0500, Olga Kornievskaia wrote:
>> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>=20
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>> ---
>> fs/read_write.c | 3 +++
>> 1 file changed, 3 insertions(+)
>>=20
>> diff --git a/fs/read_write.c b/fs/read_write.c
>> index 5816d4c..1d9e305 100644
>> --- a/fs/read_write.c
>> +++ b/fs/read_write.c
>> @@ -1526,6 +1526,9 @@ ssize_t vfs_copy_file_range(struct file =
*file_in, loff_t pos_in,
>> 	if (unlikely(ret))
>> 		return ret;
>>=20
>> +	if (pos_in >=3D i_size_read(inode_in))
>> +		return -EINVAL;
>> +
>=20
> This ought to go in vfs_clone_file_prep_inodes.
>=20
> (He says, noticing that btrfs never got updated to use that =
validator=E2=80=A6)

I apologize I=E2=80=99m not fully understanding the suggestion here. How =
btrfs is related to the check that I=E2=80=99m suggesting for the =
copy_file_range().  I don=E2=80=99t see how it would fix the problem for =
the copy_file_range().

Is the suggestion that NFS=E2=80=99s clone implementation is suppose to =
call vfs_clone_file_prep_inodes() where the check would be added and =
thus because vfs_copy_file_range() first decides to call clone() instead =
of copy() then that check would be met?

>=20
> --D
>=20
>> 	if (!(file_in->f_mode & FMODE_READ) ||
>> 	    !(file_out->f_mode & FMODE_WRITE) ||
>> 	    (file_out->f_flags & O_APPEND))
>> --=20
>> 1.8.3.1
>>=20

