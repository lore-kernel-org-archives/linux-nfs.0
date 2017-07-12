Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:56775 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932080AbdGLRTv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Jul 2017 13:19:51 -0400
Content-Type: text/plain; charset=us-ascii
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v3 14/42] NFS if we got partial copy ignore errors
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <910cad89-5ca7-4ebd-97b0-fe96284aebc7@gmail.com>
Date: Wed, 12 Jul 2017 13:19:43 -0400
CC: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Message-ID: <065C1AD4-9F10-489A-96DF-AFFC21EFB8F0@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-15-kolga@netapp.com>
 <910cad89-5ca7-4ebd-97b0-fe96284aebc7@gmail.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 12, 2017, at 10:52 AM, Anna Schumaker =
<schumaker.anna@gmail.com> wrote:
>=20
> Hi Olga,
>=20
> On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> fs/nfs/nfs42proc.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>> index dba2b62..dfd43bc 100644
>> --- a/fs/nfs/nfs42proc.c
>> +++ b/fs/nfs/nfs42proc.c
>> @@ -179,7 +179,8 @@ static int handle_async_copy(struct =
nfs42_copy_res *res,
>> out:
>> 	*ret_count =3D copy->count;
>> 	memcpy(&res->write_res.verifier, &copy->verf, =
sizeof(copy->verf));
>> -	status =3D -copy->error;
>> +	if (copy->count <=3D 0)
>> +		status =3D -copy->error;
>=20
> This is a pretty small change.  Can you squash this patch into patch 8
> ("NFS add support for asynchronous COPY") that way the code is correct =
from
> the time it's added?

Ok.

>=20
> Thanks,
> Anna
>=20
>>=20
>> 	kfree(copy);
>> 	return status;
>>=20

