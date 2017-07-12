Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:20145 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932272AbdGLRWA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Jul 2017 13:22:00 -0400
Content-Type: text/plain; charset=us-ascii
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v3 11/42] NFS test for intra vs inter COPY
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <bd9f4062-6c6d-d310-b4b9-812c1a1628b9@gmail.com>
Date: Wed, 12 Jul 2017 13:21:46 -0400
CC: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Message-ID: <47399256-1578-48C8-91BD-834641BB1C42@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-12-kolga@netapp.com>
 <bd9f4062-6c6d-d310-b4b9-812c1a1628b9@gmail.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 12, 2017, at 10:06 AM, Anna Schumaker =
<schumaker.anna@gmail.com> wrote:
>=20
> Hi Olga,
>=20
> On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> fs/nfs/internal.h | 10 ++++++++++
>> 1 file changed, 10 insertions(+)
>>=20
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 3e24392..dcbcffb 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -7,6 +7,7 @@
>> #include <linux/security.h>
>> #include <linux/crc32.h>
>> #include <linux/nfs_page.h>
>> +#include <linux/sunrpc/addr.h>
>>=20
>> #define NFS_MS_MASK =
(MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC|MS_SYNCHRONOUS)
>>=20
>> @@ -766,3 +767,12 @@ static inline bool nfs_error_is_fatal(int err)
>> 		return false;
>> 	}
>> }
>> +
>> +static inline bool nfs42_files_from_same_server(struct file *in, =
struct file *out)
>> +{
>> +	struct nfs_client *c_in =3D =
(NFS_SERVER(file_inode(in)))->nfs_client;
>> +	struct nfs_client *c_out =3D =
(NFS_SERVER(file_inode(out)))->nfs_client;
>> +
>> +	return rpc_cmp_addr((struct sockaddr *)&c_in->cl_addr,
>> +				(struct sockaddr *)&c_out->cl_addr);
>> +}
>=20
> Can you move this to nfs42.h instead of internal.h?
>=20

Ok.

> Thanks,
> Anna
>=20
>>=20

