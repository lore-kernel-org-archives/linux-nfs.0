Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36091 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbdBOPkn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2017 10:40:43 -0500
Received: by mail-io0-f179.google.com with SMTP id j13so91709985iod.3
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2017 07:40:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <f186e424-5050-4651-6621-7ccc3688a49e@gmail.com>
References: <BLUPR06MB54767D9B4746E210D176C3AE1580@BLUPR06MB547.namprd06.prod.outlook.com>
 <f186e424-5050-4651-6621-7ccc3688a49e@gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 15 Feb 2017 10:40:42 -0500
Message-ID: <CAN-5tyE3vXXdzFubUqjZY+domGn4rTuXb-OctFdSG3+PVrkU2Q@mail.gmail.com>
Subject: Re: Question about NFSv4.2 server-side copy implementation
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "Mora, Jorge" <Jorge.Mora@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 15, 2017 at 5:36 AM, Kinglong Mee <kinglongmee@gmail.com> wrote=
:
> On 2/15/2017 04:07, Mora, Jorge wrote:
>> Hello,
>>
>> The NFSv4.2 spec (RFC 7862) on section 15.2.3 (COPY description) says th=
e following:
>>
>> If the source offset or the source offset plus count is greater than
>> the size of the source file, the operation MUST fail with
>> NFS4ERR_INVAL.
>>
>> I can understand failing with NFS4ERR_INVAL when the source offset is be=
yond the end of the file,
>
> Yes, that's right.
>
>> but do you think failing with NFS4ERR_INVAL is too strict when the sourc=
e offset plus the count is beyond the end of the file?
>> What is the rationalization for failing on this specific instance?
>> Why not return a short copy instead?
>
> The man-pages of copy_file_range description as,
>
>        EINVAL Requested range extends beyond the end of the  source  file=
;  or
>               the flags argument is not 0.
>
> So, the specific instance you said isn't allowed.
>
>> Can the COPY return a count less than what it requested (a short copy)?
>
> Yes, the return value of copy_file_range is,
>
> RETURN VALUE
>        Upon successful completion, copy_file_range() will return the numb=
er of
>        bytes copied between files.  This could be less than the length  o=
rigi=E2=80=90
>        nally requested.
>
>>
>> As of right now, the implementation on the Linux server adheres to the s=
pec but copy_file_range succeeds
>> when it is called against the local file system, NFSv4.x or NFSv3.
>
> NFSv3 doesn't support copy_file_range, and only NFSv4.2 supports copy_fil=
e_range.

copy_file_range() can be called with two file description that are
from the NFSv3 mounts and currently as you point NFSv3 does not
support copy_file_range() vfs_copy_file_range() will fall back into
doing "normal" copy via do_splice_direct() what happens here is that
NFSv3 will not fail with EINVAL and instead will return a partial
copy. Thus as Jorge points out, we have inconsistent results of a copy
being done via an NFS protocol v3 vs 4.2 protocol (if we were to
enforce the rule that the spec says).


>> For the local file system, NFSv4.x or NFSv3 copy_file_range falls back t=
o regular copy by
>> reading from the source file and then writing to the destination file bu=
t I do believe the
>> syscall should be consistent regardless of the underlying file system.
>>
>>
>> --Jorge
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
