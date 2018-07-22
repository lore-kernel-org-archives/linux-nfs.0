Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:46152 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730190AbeGVT64 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jul 2018 15:58:56 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] fs/nfsd: Delete invalid assignment statements in
 nfsd4_decode_exchange_id
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <a6be2d3bf2ff5ac43f82dcb7b29ba32faccbbdaf.camel@hammerspace.com>
Date: Sun, 22 Jul 2018 15:01:02 -0400
Cc: "nixiaoming@huawei.com" <nixiaoming@huawei.com>,
        Bruce Fields <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Message-Id: <8B9E4DFD-F651-4478-A82E-CDB759BB1A69@oracle.com>
References: <20180722085044.50701-1-nixiaoming@huawei.com>
 <2C39A9CD-4591-46C8-BB25-5FA2C85149CE@oracle.com>
 <a6be2d3bf2ff5ac43f82dcb7b29ba32faccbbdaf.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jul 22, 2018, at 2:33 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Sun, 2018-07-22 at 14:12 -0400, Chuck Lever wrote:
>>> On Jul 22, 2018, at 4:50 AM, nixiaoming <nixiaoming@huawei.com>
>>> wrote:
>>>=20
>>> dummy =3D be32_to_cpup(p++);
>>> dummy =3D be32_to_cpup(p++);
>>> Assigning value to "dummy" here, but that stored value
>>> is overwritten before it can be used.
>>>=20
>>> delete invalid assignment statements in nfsd4_decode_exchange_id
>>>=20
>>> Signed-off-by: n00202754 <nixiaoming@huawei.com>
>>> ---
>>> fs/nfsd/nfs4xdr.c | 4 ++--
>>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>>=20
>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>> index a96843c..8e78541 100644
>>> --- a/fs/nfsd/nfs4xdr.c
>>> +++ b/fs/nfsd/nfs4xdr.c
>>> @@ -1392,8 +1392,8 @@ nfsd4_decode_exchange_id(struct
>>> nfsd4_compoundargs *argp,
>>>=20
>>> 		/* ssp_window and ssp_num_gss_handles */
>>> 		READ_BUF(8);
>>> -		dummy =3D be32_to_cpup(p++);
>>> -		dummy =3D be32_to_cpup(p++);
>>> +		be32_to_cpup(p++);
>>> +		be32_to_cpup(p++);
>>=20
>> If these values are not used, what's the point of byte swapping them?
>> Surely "p +=3D 2;" should be enough.
>>=20
>>=20
>>> 		break;
>>> 	default:
>>> 		goto xdr_error;
>>=20
>=20
> Given that the value of 'p' isn't used either, why not just delete
> those two lines altogether?

Sounds OK, READ_BUF is tracking progress through the buffer,
and it already updates "p" as a side-effect.

Might there be some nearby instances of open-coded "p" updates
that could also be removed, for similar reasons?


--
Chuck Lever



