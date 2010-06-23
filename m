From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 3/8] SQUASHME pnfs-submit: tell commit to use the MDS
Date: Wed, 23 Jun 2010 10:11:19 -0400
Message-ID: <AANLkTikzfFVMd76tevedVeQ4Q6ot5wxXZ8fxKFNz_zyK@mail.gmail.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com>
	<1277243798-8181-2-git-send-email-andros@netapp.com>
	<1277243798-8181-3-git-send-email-andros@netapp.com>
	<1277243798-8181-4-git-send-email-andros@netapp.com>
	<AANLkTimh37nfPbw5CZmBJv1XhIqrlogV_0nUVSDaxZJ3@mail.gmail.com>
	<F3672AD5-CEF8-477F-8E52-E1FDA3624744@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60032 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259Ab0FWOLV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 10:11:21 -0400
Received: by bwz9 with SMTP id 9so546931bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jun 2010 07:11:20 -0700 (PDT)
In-Reply-To: <F3672AD5-CEF8-477F-8E52-E1FDA3624744@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 23, 2010 at 9:53 AM, Andy Adamson <andros@netapp.com> wrote=
:
>
> On Jun 23, 2010, at 9:34 AM, Fred Isaman wrote:
>
>> On Tue, Jun 22, 2010 at 5:56 PM, =A0<andros@netapp.com> wrote:
>>>
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> =A0fs/nfs/pnfs.c | =A0 =A01 +
>>> =A01 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 9a295cf..c1a8066 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1454,6 +1454,7 @@ pnfs_writepages(struct nfs_write_data *wdata,=
 int
>>> how)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wdata);
>>>
>>> =A0 =A0 =A0 if (trypnfs =3D=3D PNFS_NOT_ATTEMPTED) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wdata->req->wb_lseg =3D NULL;
>>
>> This is wrong. =A0It will be taken care of by
>> _pnfs_clear_lseg_from_pages called by pnfs_try_to_write_data.
>
> A partial write, e.g. one that uses nfs_write_partial_ops, does not s=
et
> nfs_write_data->pages, so _pnfs_clear_lseg_from_pages does not take c=
are of
> clearing the req->wb_lseg.
>

Hmmm, you are right.

> Perhaps it would be cleaner to add this case to _pnfs_clear_lseg_from=
_pages.
>

I'll look into this, but for now your patch does the correct thing.

=46red

> -->Andy
>
>>
>> Fred
>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wdata->pdata.lseg =3D NULL;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_lseg(lseg);
>>> =A0 =A0 =A0 }
>>> --
>>> 1.6.6
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>
>
