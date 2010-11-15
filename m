From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 08/22] SQUASHME: allow cb_sequence changes to compile
 without v4.1
Date: Mon, 15 Nov 2010 10:07:26 -0500
Message-ID: <AANLkTi=MQOVPf1FS9XV1jbE=Vt-NgMgCEK5-Z44fsMJL@mail.gmail.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
	<1289551724-18575-9-git-send-email-iisaman@netapp.com>
	<4CDFD07A.5040300@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52810 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757811Ab0KOPH2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Nov 2010 10:07:28 -0500
Received: by bwz15 with SMTP id 15so5261131bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 07:07:26 -0800 (PST)
In-Reply-To: <4CDFD07A.5040300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 14, 2010 at 7:05 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On 2010-11-12 10:48, Fred Isaman wrote:
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> =A0fs/nfs/callback.h =A0 =A0 =A0| =A0 26 ++++++++++++++++++++++++++
>> =A0fs/nfs/callback_proc.c | =A0 =A06 ------
>> =A0fs/nfs/callback_xdr.c =A0| =A0 =A03 +--
>> =A0fs/nfs/internal.h =A0 =A0 =A0| =A0 =A04 ++++
>> =A04 files changed, 31 insertions(+), 8 deletions(-)
>>
>> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
>> index 89fee05..0b1f3c4 100644
>> --- a/fs/nfs/callback.h
>> +++ b/fs/nfs/callback.h
>> @@ -8,6 +8,8 @@
>> =A0#ifndef __LINUX_FS_NFS_CALLBACK_H
>> =A0#define __LINUX_FS_NFS_CALLBACK_H
>>
>> +#include "internal.h"
>> +
>> =A0#define NFS4_CALLBACK 0x40000000
>> =A0#define NFS4_CALLBACK_XDRSIZE 2048
>> =A0#define NFS4_CALLBACK_BUFSIZE (1024 + NFS4_CALLBACK_XDRSIZE)
>> @@ -158,6 +160,30 @@ extern unsigned nfs4_callback_layoutrecall(
>> =A0 =A0 =A0 struct cb_layoutrecallargs *args,
>> =A0 =A0 =A0 void *dummy, struct cb_process_state *cps);
>>
>> +static inline void put_session_client(struct nfs4_session *session)
>> +{
>> + =A0 =A0 if (session) =A0/* matched by cb_sequence find_client_with=
_session */
>
> nit: comment out of scope. =A0belongs to the call site, not here...
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 nfs_put_client(session->clp);
>> +}
>> +
>> +static inline struct nfs_client *
>> +find_client_from_cps(struct cb_process_state *cps, struct sockaddr =
*addr)
>> +{
>> + =A0 =A0 return cps->session ? cps->session->clp : nfs_find_client(=
addr, 4);
>> +}
>> +
>> +#else
>
> nit: /* CONFIG_NFS_V4_1 */ comment missing
>
> (I'll fix both in my tree)
>
> Benny

OK, thanks.

=46red

>
>> +
>> +static inline struct nfs_client *
>> +find_client_from_cps(struct cb_process_state *cps, struct sockaddr =
*addr)
>> +{
>> + =A0 =A0 return nfs_find_client(addr, 4);
>> +}
>> +
>> +static inline void put_session_client(struct nfs4_session *session)
>> +{
>> +}
>> +
>> =A0#endif /* CONFIG_NFS_V4_1 */
>>
>> =A0extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 2e62155..d02997a 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -21,12 +21,6 @@
>> =A0#define NFSDBG_FACILITY NFSDBG_CALLBACK
>> =A0#endif
>>
>> -static struct nfs_client *
>> -find_client_from_cps(struct cb_process_state *cps, struct sockaddr =
*addr)
>> -{
>> - =A0 =A0 return cps->session ? cps->session->clp : nfs_find_client(=
addr, 4);
>> -}
>> -
>> =A0__be32 nfs4_callback_getattr(struct cb_getattrargs *args,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cb_get=
attrres *res,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cb_pro=
cess_state *cps)
>> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
>> index 1650ab0..01688ce 100644
>> --- a/fs/nfs/callback_xdr.c
>> +++ b/fs/nfs/callback_xdr.c
>> @@ -770,8 +770,7 @@ static __be32 nfs4_callback_compound(struct svc_=
rqst *rqstp, void *argp, void *r
>>
>> =A0 =A0 =A0 *hdr_res.status =3D status;
>> =A0 =A0 =A0 *hdr_res.nops =3D htonl(nops);
>> - =A0 =A0 if (cps.session) /* matched by cb_sequence find_client_wit=
h_session */
>> - =A0 =A0 =A0 =A0 =A0 =A0 nfs_put_client(cps.session->clp);
>> + =A0 =A0 put_session_client(cps.session);
>> =A0 =A0 =A0 dprintk("%s: done, status =3D %u\n", __func__, ntohl(sta=
tus));
>> =A0 =A0 =A0 return rpc_success;
>> =A0}
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 755e555..6f14089 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -2,6 +2,8 @@
>> =A0 * NFS internal definitions
>> =A0 */
>>
>> +#ifndef __LINUX_FS_NFS_INTERNAL_H
>> +#define __LINUX_FS_NFS_INTERNAL_H
>> =A0#include "nfs4_fs.h"
>> =A0#include <linux/mount.h>
>> =A0#include <linux/security.h>
>> @@ -415,3 +417,5 @@ static inline int nfs_restart_rpc(struct rpc_tas=
k *task, const struct nfs_client
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return rpc_restart_call_prepare(task);
>> =A0 =A0 =A0 return rpc_restart_call(task);
>> =A0}
>> +
>> +#endif /* __LINUX_FS_NFS_INTERNAL_H */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
