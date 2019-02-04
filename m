Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59435C282CB
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 19:07:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 212932082E
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 19:07:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JPZNgqQK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726585AbfBDTHO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 14:07:14 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:59046 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727544AbfBDTHO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 14:07:14 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x14J4KME097259;
        Mon, 4 Feb 2019 19:07:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=EBN7g3BVq/7CRRoCnv7biDh2HWoT6sWdy8yLC1+NWzM=;
 b=JPZNgqQKHw+cov2MttJQIElvVSpG/fiSGzIMQQ9mBKBeRXwBn45te/RTfSrJHBM/BiG9
 FeGjzIrdmWmltvMlvNOf9/09vTygNUwmiQ4sBXP4g85TEdiypVERw58MdvnoWug/jGpX
 wsR9rKRnaCwzcbJM2in1hd1P18J0mDufP6P2tBOu0GJEU9yG08a5Oll4fZfvMsj7M5hO
 mPrYmLgR+lPJCil0LsvKc8dNu3W45MWb8yycfsuuG/P/fN4/2CGw/LdOa9JWH1M8a/qQ
 9Wmog1DRZGAK0vha1n9WBUFucjEn0PKeQ5rUdZLbkSzaYAU4dXsydM1rbKVmJz9ZL1Gx DQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2qd9ar71wr-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 04 Feb 2019 19:07:09 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x14J78Tf017803
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 4 Feb 2019 19:07:09 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x14J78AR009357;
        Mon, 4 Feb 2019 19:07:08 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 04 Feb 2019 19:07:08 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 01/10] SUNRPC: Remove some dprintk() call sites from
 auth functions
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190204190414.GA1816@fieldses.org>
Date:   Mon, 4 Feb 2019 14:07:03 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>, simo@redhat.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <5ED56D0E-89B4-4533-AF47-331F5521F97E@oracle.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195731.11389.69008.stgit@manet.1015granger.net>
 <20190204190414.GA1816@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9157 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902040146
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 4, 2019, at 2:04 PM, bfields@fieldses.org wrote:
>=20
> On Fri, Feb 01, 2019 at 02:57:31PM -0500, Chuck Lever wrote:
>> Clean up: Reduce dprintk noise by removing dprintk() call sites
>> from hot path that do not report exceptions. These are usually
>> replaceable with function graph tracing.
>=20
> Yeah, dprintk's sometimes much to verbose to be useful, thanks for
> looking at this.  How are you deciding what the hot paths are?

Anything that is called one or more times per RPC.

There are some places where low value dprintks are
removed just because. By and large these can often be
replaced by using the ftrace function plug-in.


> --b.
>=20
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/auth.c      |   29 -----------------------------
>> net/sunrpc/auth_unix.c |    9 +--------
>> 2 files changed, 1 insertion(+), 37 deletions(-)
>>=20
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index 8dfab61..275e84e 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -17,10 +17,6 @@
>> #include <linux/sunrpc/gss_api.h>
>> #include <linux/spinlock.h>
>>=20
>> -#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
>> -# define RPCDBG_FACILITY	RPCDBG_AUTH
>> -#endif
>> -
>> #define RPC_CREDCACHE_DEFAULT_HASHBITS	(4)
>> struct rpc_cred_cache {
>> 	struct hlist_head	*hashtable;
>> @@ -267,8 +263,6 @@ static int param_get_hashtbl_sz(char *buffer, =
const struct kernel_param *kp)
>> 		}
>> 	}
>> 	rcu_read_unlock();
>> -
>> -	dprintk("RPC:       %s returns %d\n", __func__, result);
>> 	return result;
>> }
>> EXPORT_SYMBOL_GPL(rpcauth_list_flavors);
>> @@ -636,9 +630,6 @@ struct rpc_cred *
>> 	struct rpc_cred *ret;
>> 	const struct cred *cred =3D current_cred();
>>=20
>> -	dprintk("RPC:       looking up %s cred\n",
>> -		auth->au_ops->au_name);
>> -
>> 	memset(&acred, 0, sizeof(acred));
>> 	acred.cred =3D cred;
>> 	ret =3D auth->au_ops->lookup_cred(auth, &acred, flags);
>> @@ -670,8 +661,6 @@ struct rpc_cred *
>> 	};
>> 	struct rpc_cred *ret;
>>=20
>> -	dprintk("RPC: %5u looking up %s cred\n",
>> -		task->tk_pid, =
task->tk_client->cl_auth->au_ops->au_name);
>> 	ret =3D auth->au_ops->lookup_cred(auth, &acred, lookupflags);
>> 	put_cred(acred.cred);
>> 	return ret;
>> @@ -688,8 +677,6 @@ struct rpc_cred *
>>=20
>> 	if (!acred.principal)
>> 		return NULL;
>> -	dprintk("RPC: %5u looking up %s machine cred\n",
>> -		task->tk_pid, =
task->tk_client->cl_auth->au_ops->au_name);
>> 	return auth->au_ops->lookup_cred(auth, &acred, lookupflags);
>> }
>>=20
>> @@ -698,8 +685,6 @@ struct rpc_cred *
>> {
>> 	struct rpc_auth *auth =3D task->tk_client->cl_auth;
>>=20
>> -	dprintk("RPC: %5u looking up %s cred\n",
>> -		task->tk_pid, auth->au_ops->au_name);
>> 	return rpcauth_lookupcred(auth, lookupflags);
>> }
>>=20
>> @@ -776,9 +761,6 @@ struct rpc_cred *
>> {
>> 	struct rpc_cred	*cred =3D task->tk_rqstp->rq_cred;
>>=20
>> -	dprintk("RPC: %5u marshaling %s cred %p\n",
>> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>> -
>> 	return cred->cr_ops->crmarshal(task, p);
>> }
>>=20
>> @@ -787,9 +769,6 @@ struct rpc_cred *
>> {
>> 	struct rpc_cred	*cred =3D task->tk_rqstp->rq_cred;
>>=20
>> -	dprintk("RPC: %5u validating %s cred %p\n",
>> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>> -
>> 	return cred->cr_ops->crvalidate(task, p);
>> }
>>=20
>> @@ -808,8 +787,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t =
encode, struct rpc_rqst *rqstp,
>> {
>> 	struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
>>=20
>> -	dprintk("RPC: %5u using %s cred %p to wrap rpc data\n",
>> -			task->tk_pid, cred->cr_ops->cr_name, cred);
>> 	if (cred->cr_ops->crwrap_req)
>> 		return cred->cr_ops->crwrap_req(task, encode, rqstp, =
data, obj);
>> 	/* By default, we encode the arguments normally. */
>> @@ -833,8 +810,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t =
encode, struct rpc_rqst *rqstp,
>> {
>> 	struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
>>=20
>> -	dprintk("RPC: %5u using %s cred %p to unwrap rpc data\n",
>> -			task->tk_pid, cred->cr_ops->cr_name, cred);
>> 	if (cred->cr_ops->crunwrap_resp)
>> 		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
>> 						   data, obj);
>> @@ -865,8 +840,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t =
encode, struct rpc_rqst *rqstp,
>> 			goto out;
>> 		cred =3D task->tk_rqstp->rq_cred;
>> 	}
>> -	dprintk("RPC: %5u refreshing %s cred %p\n",
>> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>>=20
>> 	err =3D cred->cr_ops->crrefresh(task);
>> out:
>> @@ -880,8 +853,6 @@ static void rpcauth_wrap_req_encode(kxdreproc_t =
encode, struct rpc_rqst *rqstp,
>> {
>> 	struct rpc_cred *cred =3D task->tk_rqstp->rq_cred;
>>=20
>> -	dprintk("RPC: %5u invalidating %s cred %p\n",
>> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>> 	if (cred)
>> 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>> }
>> diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
>> index 387f6b3..fc8a591 100644
>> --- a/net/sunrpc/auth_unix.c
>> +++ b/net/sunrpc/auth_unix.c
>> @@ -28,8 +28,6 @@
>> static struct rpc_auth *
>> unx_create(const struct rpc_auth_create_args *args, struct rpc_clnt =
*clnt)
>> {
>> -	dprintk("RPC:       creating UNIX authenticator for client =
%p\n",
>> -			clnt);
>> 	refcount_inc(&unix_auth.au_count);
>> 	return &unix_auth;
>> }
>> @@ -37,7 +35,6 @@
>> static void
>> unx_destroy(struct rpc_auth *auth)
>> {
>> -	dprintk("RPC:       destroying UNIX authenticator %p\n", auth);
>> }
>>=20
>> /*
>> @@ -48,10 +45,6 @@
>> {
>> 	struct rpc_cred *ret =3D mempool_alloc(unix_pool, GFP_NOFS);
>>=20
>> -	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
>> -			from_kuid(&init_user_ns, acred->cred->fsuid),
>> -			from_kgid(&init_user_ns, acred->cred->fsgid));
>> -
>> 	rpcauth_init_cred(ret, acred, auth, &unix_credops);
>> 	ret->cr_flags =3D 1UL << RPCAUTH_CRED_UPTODATE;
>> 	return ret;
>> @@ -61,7 +54,7 @@
>> unx_free_cred_callback(struct rcu_head *head)
>> {
>> 	struct rpc_cred *rpc_cred =3D container_of(head, struct =
rpc_cred, cr_rcu);
>> -	dprintk("RPC:       unx_free_cred %p\n", rpc_cred);
>> +
>> 	put_cred(rpc_cred->cr_cred);
>> 	mempool_free(rpc_cred, unix_pool);
>> }

--
Chuck Lever



