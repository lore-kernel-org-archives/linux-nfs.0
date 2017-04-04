Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33254 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752574AbdDDCRQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Apr 2017 22:17:16 -0400
Received: by mail-io0-f195.google.com with SMTP id f84so13915310ioj.0
        for <linux-nfs@vger.kernel.org>; Mon, 03 Apr 2017 19:17:16 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] nfs: flexfilelayout: remove v3-only data server
 limitation
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <555419275.7370836.1491228611932.JavaMail.zimbra@desy.de>
Date: Mon, 3 Apr 2017 22:17:14 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <70D144DE-A0D2-436E-A90A-5F65BA65F4BA@monkey.org>
References: <20170403121026.14142-1-tigran.mkrtchyan@desy.de>
 <FB99D377-D3F4-4CA5-9900-7E3CCC1B8EAE@monkey.org>
 <555419275.7370836.1491228611932.JavaMail.zimbra@desy.de>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 3, 2017, at 10:10 AM, Mkrtchyan, Tigran =
<tigran.mkrtchyan@desy.de> wrote:
>=20
> Hi Dros,
>=20
> ----- Original Message -----
>> From: "Weston Andros Adamson" <dros@monkey.org>
>> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
>> Cc: "linux-nfs list" <linux-nfs@vger.kernel.org>, "Trond Myklebust" =
<trond.myklebust@primarydata.com>
>> Sent: Monday, April 3, 2017 3:54:59 PM
>> Subject: Re: [PATCH] nfs: flexfilelayout: remove v3-only data server =
limitation
>=20
>> Hey Tigran!
>>=20
>>> On Apr 3, 2017, at 8:10 AM, Tigran Mkrtchyan =
<tigran.mkrtchyan@desy.de> wrote:
>>>=20
>>> Flexfilelayout supports data servers which talk NFS v3 and v4.{0,1}.
>>> However, this code path is disabled and v3 only servers are =
accepted.
>>> This change removes this limitation.
>>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>>> ---
>>> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 18 ++++++++++++------
>>> 1 file changed, 12 insertions(+), 6 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> index 457cfeb..fac0ef2 100644
>>> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> @@ -119,12 +119,18 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server =
*server,
>>> struct pnfs_device *pdev,
>>> 		if (ds_versions[i].wsize > NFS_MAX_FILE_IO_SIZE)
>>> 			ds_versions[i].wsize =3D NFS_MAX_FILE_IO_SIZE;
>>>=20
>>> -		if (ds_versions[i].version !=3D 3 || =
ds_versions[i].minor_version !=3D 0) {
>>> -			dprintk("%s: [%d] unsupported ds version =
%d-%d\n", __func__,
>>> -				i, ds_versions[i].version,
>>> -				ds_versions[i].minor_version);
>>> -			ret =3D -EPROTONOSUPPORT;
>>> -			goto out_err_drain_dsaddrs;
>>> +		/* check for valid major minor combination */
>>> +		switch (ds_versions[i].version * 100 + =
ds_versions[i].minor_version) {
>>=20
>> I'm not sure I love this method of matching
>=20
> I didn't find a better way without flood of if-statements. Any =
suggestions?

Not really. That is clever, just not immediately obvious (to me). Plus =
what happens when we have NFSv4.100? ;)

I was thinking you could simply check for > nfsv3, but that's not very =
specific.

Lets see what Trond and Anna say.

-dros

>=20
>>=20
>>> +			case 300: /* v3   */
>>> +			case 400: /* v4.0 */
>>> +			case 401: /* v4.1 */
>>> +				break;
>>=20
>> v4.2?
>=20
> Right!
>=20
> Tigran.
>>=20
>> -dros
>>=20
>>> +			default:
>>> +				dprintk("%s: [%d] unsupported ds version =
%d-%d\n", __func__,
>>> +					i, ds_versions[i].version,
>>> +					ds_versions[i].minor_version);
>>> +				ret =3D -EPROTONOSUPPORT;
>>> +				goto out_err_drain_dsaddrs;
>>> 		}
>>>=20
>>> 		dprintk("%s: [%d] vers %u minor_ver %u rsize %u wsize %u =
coupled %d\n",
>>> --
>>> 2.9.3
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

