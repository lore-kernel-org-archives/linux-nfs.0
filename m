From: Jovi Zhang <bookjovi@gmail.com>
Subject: Re: [PATCH] nfs: fix compilation warning
Date: Mon, 7 Mar 2011 12:11:57 +0800
Message-ID: <AANLkTi=CLqfMa_Sxq5YUTpbBCi+UoVKoD+n7hAMEW82K@mail.gmail.com>
References: <1299107978-3248-1-git-send-email-bookjovi@gmail.com>
	<20110305160153.a37899b3.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "open list:NFS, linux-kernel@vger.kernel.org (open list)"
	<linux-nfs@vger.kernel.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:40217 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256Ab1CGEL6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Mar 2011 23:11:58 -0500
Received: by yxs7 with SMTP id 7so1476173yxs.19
        for <linux-nfs@vger.kernel.org>; Sun, 06 Mar 2011 20:11:57 -0800 (PST)
In-Reply-To: <20110305160153.a37899b3.rdunlap@xenotime.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 6, 2011 at 8:01 AM, Randy Dunlap <rdunlap@xenotime.net> wro=
te:
> On Wed, =C2=A02 Mar 2011 18:19:37 -0500 bookjovi@gmail.com wrote:
>
>> From: Jovi Zhang <bookjovi@gmail.com>
>>
>> this commit fix compilation warning as following:
>> linux-2.6/fs/nfs/nfs4proc.c:3265: warning: comparison of distinct po=
inter types lacks a cast
>>
>> Signed-off-by: Jovi Zhang <bookjovi@gmail.com>
>> ---
>> =C2=A0fs/nfs/nfs4proc.c | =C2=A0 =C2=A02 +-
>> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 1ff76ac..c7eb4ee 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -3262,7 +3262,7 @@ static int buf_to_pages_noslab(const void *buf=
, size_t buflen,
>> =C2=A0 =C2=A0 =C2=A0 spages =3D pages;
>>
>> =C2=A0 =C2=A0 =C2=A0 do {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 len =3D min(PAGE_CACHE_S=
IZE, buflen);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 len =3D min((size_t)PAGE=
_CACHE_SIZE, buflen);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 newpage =3D alloc_p=
age(GFP_KERNEL);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (newpage =3D=3D =
NULL)
>> --
>
> or use
> =C2=A0 =C2=A0 =C2=A0 =C2=A0len =3D min_t(size_t, PAGE_SIZE_CACHE, buf=
len);
>
That's good, Thanks.
