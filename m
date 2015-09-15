Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33564 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbbIORBg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2015 13:01:36 -0400
Subject: Re: [PATCH v2 8/9] vfs: copy_file_range() can do a pagecache copy
 with splice
To: "Darrick J. Wong" <darrick.wong@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1442003423-6884-9-git-send-email-Anna.Schumaker@Netapp.com>
 <20150915033217.GG10391@birch.djwong.org> <55F8400C.3000402@Netapp.com>
 <20150915163829.GA12658@birch.djwong.org>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        mtk.manpages@gmail.com, andros@netapp.com, hch@infradead.org
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <55F84EDC.1090200@gmail.com>
Date: Tue, 15 Sep 2015 13:01:16 -0400
MIME-Version: 1.0
In-Reply-To: <20150915163829.GA12658@birch.djwong.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms000209010505050901060408"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms000209010505050901060408
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-09-15 12:38, Darrick J. Wong wrote:
> On Tue, Sep 15, 2015 at 11:58:04AM -0400, Anna Schumaker wrote:
>> On 09/14/2015 11:32 PM, Darrick J. Wong wrote:
>>> On Fri, Sep 11, 2015 at 04:30:21PM -0400, Anna Schumaker wrote:
>>>> The NFS server will need some kind offallback for filesystems that d=
on't
>>>> have any kind of copy acceleration, and it should be generally usefu=
l to
>>>> have an in-kernel copy to avoid lots of switches between kernel and =
user
>>>> space.
>>>>
>>>> I make this configurable by adding two new flags.  Users who only wa=
nt a
>>>> reflink can pass COPY_FR_REFLINK, and users who want a full data cop=
y can
>>>> pass COPY_FR_COPY.  The default (flags=3D0) means to first attempt a=

>>>> reflink, but use the pagecache if that fails.
>>>>
>>>> I moved the rw_verify_area() calls into the fallback code since some=

>>>> filesystems can handle reflinking a large range.
>>>>
>>>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>>> ---
>>>> v2:
>>>> - Rename COPY_REFLINK -> COPY_FR_REFLINK
>>>> - Introduce COPY_FR_COPY flag
>>>> - Flags =3D=3D 0 is really COPY_FR_COPY|COPY_FR_REFLINK
>>>> - Drop check for invalid flags
>>>> - Move call to do_splice_direct() into a new function
>>>> - Move rw_verify_area() checks into the new fallback function
>>>> ---
>>>>   fs/read_write.c           | 56 ++++++++++++++++++++++++++++-------=
------------
>>>>   include/linux/copy.h      |  6 +++++
>>>>   include/uapi/linux/Kbuild |  1 +
>>>>   include/uapi/linux/copy.h |  7 ++++++
>>>>   4 files changed, 48 insertions(+), 22 deletions(-)
>>>>   create mode 100644 include/linux/copy.h
>>>>   create mode 100644 include/uapi/linux/copy.h
>>>>
>>>> diff --git a/fs/read_write.c b/fs/read_write.c
>>>> index 363bd3e..ba24884 100644
>>>> --- a/fs/read_write.c
>>>> +++ b/fs/read_write.c
>>>> @@ -7,6 +7,7 @@
>>>>   #include <linux/slab.h>
>>>>   #include <linux/stat.h>
>>>>   #include <linux/fcntl.h>
>>>> +#include <linux/copy.h>
>>>>   #include <linux/file.h>
>>>>   #include <linux/uio.h>
>>>>   #include <linux/fsnotify.h>
>>>> @@ -1329,6 +1330,29 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_f=
d, int, in_fd,
>>>>   }
>>>>   #endif
>>>>
>>>> +static ssize_t vfs_copy_file_pagecache(struct file *file_in, loff_t=
 pos_in,
>>>> +				       struct file *file_out, loff_t pos_out,
>>>> +				       size_t len)
>>>> +{
>>>> +	ssize_t ret;
>>>> +
>>>> +	ret =3D rw_verify_area(READ, file_in, &pos_in, len);
>>>> +	if (ret >=3D 0) {
>>>> +		len =3D ret;
>>>> +		ret =3D rw_verify_area(WRITE, file_out, &pos_out, len);
>>>> +		if (ret >=3D 0)
>>>> +			len =3D ret;
>>>> +	}
>>>> +	if (ret < 0)
>>>> +		return ret;
>>>> +
>>>> +	file_start_write(file_out);
>>>> +	ret =3D do_splice_direct(file_in, &pos_in, file_out, &pos_out, len=
, 0);
>>>> +	file_end_write(file_out);
>>>> +
>>>> +	return ret;
>>>> +}
>>>> +
>>>>   /*
>>>>    * copy_file_range() differs from regular file read and write in t=
hat it
>>>>    * specifically allows return partial success.  When it does so is=
 up to
>>>> @@ -1338,34 +1362,17 @@ ssize_t vfs_copy_file_range(struct file *fil=
e_in, loff_t pos_in,
>>>>   			    struct file *file_out, loff_t pos_out,
>>>>   			    size_t len, int flags)
>>>>   {
>>>> -	struct inode *inode_in;
>>>> -	struct inode *inode_out;
>>>>   	ssize_t ret;
>>>>
>>>> -	if (flags)
>>>> -		return -EINVAL;
>>>> -
>>>> -	/* copy_file_range allows full ssize_t len, ignoring MAX_RW_COUNT =
 */
>>>> -	ret =3D rw_verify_area(READ, file_in, &pos_in, len);
>>>> -	if (ret >=3D 0)
>>>> -		ret =3D rw_verify_area(WRITE, file_out, &pos_out, len);
>>>> -	if (ret < 0)
>>>> -		return ret;
>>>> +	if (flags =3D=3D 0)
>>>> +		flags =3D COPY_FR_COPY | COPY_FR_REFLINK;
>>>
>>> This function must return -EINVAL if any of the undefined flags bits =
are
>>> set.
>>
>> Sure, I'll add that.
>>
>>>
>>>>
>>>>   	if (!(file_in->f_mode & FMODE_READ) ||
>>>>   	    !(file_out->f_mode & FMODE_WRITE) ||
>>>>   	    (file_out->f_flags & O_APPEND) ||
>>>> -	    !file_out->f_op || !file_out->f_op->copy_file_range)
>>>> +	    !file_in->f_op)
>>>>   		return -EBADF;
>>>>
>>>> -	inode_in =3D file_inode(file_in);
>>>> -	inode_out =3D file_inode(file_out);
>>>> -
>>>> -	/* make sure offsets don't wrap and the input is inside i_size */
>>>> -	if (pos_in + len < pos_in || pos_out + len < pos_out ||
>>>> -	    pos_in + len > i_size_read(inode_in))
>>>> -		return -EINVAL;
>>>> -
>>>>   	if (len =3D=3D 0)
>>>>   		return 0;
>>>>
>>>> @@ -1373,8 +1380,13 @@ ssize_t vfs_copy_file_range(struct file *file=
_in, loff_t pos_in,
>>>>   	if (ret)
>>>>   		return ret;
>>>>
>>>> -	ret =3D file_out->f_op->copy_file_range(file_in, pos_in, file_out,=
 pos_out,
>>>> -					      len, flags);
>>>> +	ret =3D -EOPNOTSUPP;
>>>> +	if (file_out->f_op->copy_file_range)
>>>> +		ret =3D file_out->f_op->copy_file_range(file_in, pos_in, file_out=
,
>>>> +						      pos_out, len, flags);
>>>> +	if ((ret < 0) && (flags & COPY_FR_COPY))
>>>> +		ret =3D vfs_copy_file_pagecache(file_in, pos_in, file_out,
>>>> +					      pos_out, len);
>>>>   	if (ret > 0) {
>>>>   		fsnotify_access(file_in);
>>>>   		add_rchar(current, ret);
>>>> diff --git a/include/linux/copy.h b/include/linux/copy.h
>>>> new file mode 100644
>>>> index 0000000..fd54543
>>>> --- /dev/null
>>>> +++ b/include/linux/copy.h
>>>> @@ -0,0 +1,6 @@
>>>> +#ifndef _LINUX_COPY_H
>>>> +#define _LINUX_COPY_H
>>>> +
>>>> +#include <uapi/linux/copy.h>
>>>> +
>>>> +#endif /* _LINUX_COPY_H */
>>>> diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
>>>> index 70ff1d9..d46830a 100644
>>>> --- a/include/uapi/linux/Kbuild
>>>> +++ b/include/uapi/linux/Kbuild
>>>> @@ -90,6 +90,7 @@ header-y +=3D coda_psdev.h
>>>>   header-y +=3D coff.h
>>>>   header-y +=3D connector.h
>>>>   header-y +=3D const.h
>>>> +header-y +=3D copy.h
>>>>   header-y +=3D cramfs_fs.h
>>>>   header-y +=3D cuda.h
>>>>   header-y +=3D cyclades.h
>>>> diff --git a/include/uapi/linux/copy.h b/include/uapi/linux/copy.h
>>>> new file mode 100644
>>>> index 0000000..2da59a8
>>>> --- /dev/null
>>>> +++ b/include/uapi/linux/copy.h
>>>> @@ -0,0 +1,7 @@
>>>> +#ifndef _UAPI_LINUX_COPY_H
>>>> +#define _UAPI_LINUX_COPY_H
>>>> +
>>>> +#define COPY_FR_COPY		(1 << 0)  /* Only do a pagecache copy.  */
>>>> +#define COPY_FR_REFLINK		(1 << 1)  /* Only make a reflink.       */=

>>>
>>> Could I have a COPY_FR_DEDUPE flag too, please?
>>>
>>> (I don't mind adding it myself when I get around to hooking up XFS, b=
ut I
>>> was hoping to get it in during the first round).
>>
>> I guess I can, but only iff everybody has agreed on using copy for ded=
upes
>> instead of somethink like fallocate.
>
> I don't see how fallocate could even handle userspace-directed deduplic=
ation
> since the dedupe operation compares two file ranges and reflinks them i=
f the
> contents match whereas fallocate only operates on a single file range.
>
> A single file range would work if userspace was telling the kernel to s=
tart a
> lengthy search for all duplicates of a particular file's range, but ...=

> yuck.
>
> (Granted, the btrfs extent_same ioctl lets userspace call dedupe on mul=
tiple
> files simultaneously, but that's for another day.)
>
Agreed, having something equivalent to reflinking would be the most=20
sensible interface for deduplicating two files.  I can however see=20
fallocate possibly having some value when in-band deduplication is=20
considered (ie, use fallocate to tell the system to include/exclude=20
certain file ranges from in-band deduplication).



--------------ms000209010505050901060408
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxBuVTANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwOTE1MTcwMTE2WjBPBgkq
hkiG9w0BCQQxQgRA53fWSjAkIvQ7MCfmq6DwnkZVT91l3LvPeatOawEykIAIaZ8kUfox1f+w
Y+t5H79X47aQ+d9qQQkwXxSCT22FJzBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxBuVTCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxBuVTAN
BgkqhkiG9w0BAQEFAASCAgA5ASoz5JVszuDYPlaPXYPh+27LQWZhgYVd2Yle1U4yGd4Zb0PW
hIRLpSWknd+XZhE8Hwdf/tav/aC/XLNY6EZ9TdpQkaop1Un9RW36h6jfULurBnhCn+nEbMB1
UJY1M7jyL6943KWdqp3T5uBGRmHyBmlHAQ5n+0PmHjx/Bfqqsp/l3oZKaHjnHgylRX91APWQ
R+EKwnBig+brYcDOWquGEBsVz2OOIDwBvhpab2kobpamCTubHv82h00Dn3xg5WL8cgmANY4O
q11PyY/u1nRW3IE429dwQhTo44s81fC5VOBSvcbmIzo1cEypvrEDTUnWJS0a0TYg38ruy6pz
HUWUqDF3w8jfOIHmNCaF5xGNwWS5Z36CJbxRTZDzhUxx5lUiG0OcfD1VtnGEIOIZPX4Ra6/z
neFaGHnAfkFEuECi+rqKqtupItVntCi2dSd6EMyFEhcHEMQTyfdiunWlmC5JbQv67gz0P1wb
jn9JwPRd2VG84D3ZTPeEfFCEbukPHjPpzOkRuJvkT24k+bwzdZXPax/G3Haeuug3c58CJ6XQ
3ACO5//FgaJ7LNFWmmSJTRyBvEvbwSHaHXn9WQ7Rn86XtetNlYA6yKbM//nomm+BRvBpchbq
qWEBXST1CeclDfWN2NcQIhVQ3wFRwGxwVDck1GOfC12J38QFzb7wK19WpAAAAAAAAA==
--------------ms000209010505050901060408--
