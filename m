From: Pavel Shilovsky <piastry@etersoft.ru>
Subject: Re: [PATCH] mountd: Fix missing varialble assignment in auth_unix_gid
Date: Wed, 8 Jun 2011 09:51:30 +0400
Message-ID: <BANLkTi=W-Ywxjqmb0z78-azOnMuuSCszjA@mail.gmail.com>
References: <1306954641-2560-1-git-send-email-piastry@etersoft.ru>
	<4DEE8846.3010009@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:62332 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab1FHFvb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 01:51:31 -0400
Received: by yie30 with SMTP id 30so58526yie.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2011 22:51:30 -0700 (PDT)
In-Reply-To: <4DEE8846.3010009-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2011/6/8 Steve Dickson <SteveD@redhat.com>:
>
>
> On 06/01/2011 02:57 PM, Pavel Shilovsky wrote:
>> When we get into auth_unix_gid at the second time, groups_len
>> is not 0 and ngroups variable leave as 0. Then we use ngroups
>> in getgrouplist that fails in this case. This patch fixes it.
>>
>> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
>> ---
>> =A0utils/mountd/cache.c | =A0 =A06 ++++--
>> =A01 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>> index df6b38f..dbe20e9 100644
>> --- a/utils/mountd/cache.c
>> +++ b/utils/mountd/cache.c
>> @@ -138,7 +138,7 @@ static void auth_unix_gid(FILE *f)
>> =A0 =A0 =A0 static gid_t *groups =3D NULL;
>> =A0 =A0 =A0 static int groups_len =3D 0;
>> =A0 =A0 =A0 gid_t *more_groups;
>> - =A0 =A0 int ngroups =3D 0;
>> + =A0 =A0 int ngroups;
>> =A0 =A0 =A0 int rv, i;
>> =A0 =A0 =A0 char *cp;
>>
>> @@ -147,9 +147,11 @@ static void auth_unix_gid(FILE *f)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!groups)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 groups_len =3D ngroups =3D INITIAL_MANAGED=
_GROUPS;
>> + =A0 =A0 =A0 =A0 =A0 =A0 groups_len =3D INITIAL_MANAGED_GROUPS;
>> =A0 =A0 =A0 }
>>
>> + =A0 =A0 ngroups =3D groups_len;
>> +
>> =A0 =A0 =A0 if (readline(fileno(f), &lbuf, &lbuflen) !=3D 1)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
> Committed...
>
> steved.
>

See it, thanks!

--=20
Best regards,
Pavel Shilovsky.
