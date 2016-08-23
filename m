Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:59195 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755474AbcHWWW0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 18:22:26 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Lever Chuck <chuck.lever@oracle.com>
CC: Fields Bruce James <bfields@fieldses.org>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/6] SUNRPC: Silence WARN_ON when NFSv4.1 over RDMA is
 in use
Date: Tue, 23 Aug 2016 22:21:40 +0000
Message-ID: <BB84506B-BC92-4325-A81C-4BC7D39F471C@primarydata.com>
References: <20160822185459.12076.43516.stgit@klimt.1015granger.net>
 <20160822185742.12076.34446.stgit@klimt.1015granger.net>
 <3E0207D8-CFB2-4233-B92B-165B10E9920E@oracle.com>
 <20160823205355.GA29452@fieldses.org>
 <AD25F201-01A4-4F4F-BAE7-9E984E12EE8D@oracle.com>
In-Reply-To: <AD25F201-01A4-4F4F-BAE7-9E984E12EE8D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 23, 2016, at 17:05, Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
>>=20
>> On Aug 23, 2016, at 4:53 PM, J. Bruce Fields <bfields@fieldses.org> wrot=
e:
>>=20
>> On Tue, Aug 23, 2016 at 01:39:15PM -0400, Chuck Lever wrote:
>>> Hi Bruce-
>>>=20
>>>=20
>>>> On Aug 22, 2016, at 2:57 PM, Chuck Lever <chuck.lever@oracle.com> wrot=
e:
>>>>=20
>>>> Using NFSv4.1 on RDMA should be safe, so broaden the new checks in
>>>> rpc_create().
>>>>=20
>>>> WARN_ON_ONCE is used, matching most other WARN call sites in clnt.c.
>>>>=20
>>>> Fixes: 39a9beab5acb ("rpc: share one xps between all backchannels")
>>>> Fixes: d50039ea5ee6 ("nfsd4/rpc: move backchannel create logic...")
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>=20
>>> Do you want to take this, or should it go through Trond/Anna ?
>>=20
>> I don't care, feel free to add my reviewed-by: if it goes through
>> someone else.
>>=20
>> Looks like this should be for 4.8 (and stable), not 4.9?
>=20
> I won't disagree with that.
>=20
> I think Trond or Anna need to weigh in on all questions
> (who takes it, does it go to stable as well).

If you want it in for 4.8, then I can pull it in together with the current =
bugfixes. Does that work for everyone?

>=20
>=20
>> --b.
>>=20
>>>=20
>>>=20
>>>> net/sunrpc/clnt.c |    4 ++--
>>>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>>>=20
>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>> index 7f79fb7..66f23b3 100644
>>>> --- a/net/sunrpc/clnt.c
>>>> +++ b/net/sunrpc/clnt.c
>>>> @@ -453,7 +453,7 @@ static struct rpc_clnt *rpc_create_xprt(struct rpc=
_create_args *args,
>>>> =09struct rpc_xprt_switch *xps;
>>>>=20
>>>> =09if (args->bc_xprt && args->bc_xprt->xpt_bc_xps) {
>>>> -=09=09WARN_ON(args->protocol !=3D XPRT_TRANSPORT_BC_TCP);
>>>> +=09=09WARN_ON_ONCE(!(args->protocol & XPRT_TRANSPORT_BC));
>>>> =09=09xps =3D args->bc_xprt->xpt_bc_xps;
>>>> =09=09xprt_switch_get(xps);
>>>> =09} else {
>>>> @@ -520,7 +520,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args=
 *args)
>>>> =09char servername[48];
>>>>=20
>>>> =09if (args->bc_xprt) {
>>>> -=09=09WARN_ON(args->protocol !=3D XPRT_TRANSPORT_BC_TCP);
>>>> +=09=09WARN_ON_ONCE(!(args->protocol & XPRT_TRANSPORT_BC));
>>>> =09=09xprt =3D args->bc_xprt->xpt_bc_xprt;
>>>> =09=09if (xprt) {
>>>> =09=09=09xprt_get(xprt);
>>>>=20
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" i=
n
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>=20
>>> --
>>> Chuck Lever
>=20
> --
> Chuck Lever

