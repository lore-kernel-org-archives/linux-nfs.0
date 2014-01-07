Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64484 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbaAGH0N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jan 2014 02:26:13 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so12951pdi.24
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 23:26:10 -0800 (PST)
Message-ID: <52CBAC0C.9000309@gmail.com>
Date: Tue, 07 Jan 2014 15:26:04 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Dr Fields James Bruce <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed
References: <52CB8564.6040002@gmail.com> <11FBA3CF-C026-42F8-943E-326B11A55929@primarydata.com>
In-Reply-To: <11FBA3CF-C026-42F8-943E-326B11A55929@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/07/2014 01:01 PM, Trond Myklebust wrote:
> 
> On Jan 6, 2014, at 23:41, Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> If try_module_get failed, xpt_bc_xprt should be set to NULL,
>> because xprt will be free.
>>
>> Don't needed using xprt_put to free xprt, because it is always new.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>> net/sunrpc/xprtsock.c | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 4fcdf74..5ed124f 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -2986,10 +2986,10 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
>> 	 */
>> 	xprt_set_connected(xprt);
>>
>> -
>> 	if (try_module_get(THIS_MODULE))
>> 		return xprt;
>> -	xprt_put(xprt);
>> +
>> +	args->bc_xprt->xpt_bc_xprt = NULL;
>> 	ret = ERR_PTR(-EINVAL);
>> out_err:
>> 	xs_xprt_free(xprt);
> 
> Just move the 'args->bc_xprt->xpt_bc_xprt = xprt’ line into the caller (see earlier discussion about xs_setup_bc_tcp()). Quite frankly, I don’t see why the client code should be modifying this variable in the first place. An svc_xprt is a server construct.

Hi Bruce, 

When reviewing those codes for bc_xprt, I found commit d75faea330dbd1873c9094e9926ae306590c0998
'rpc: move sk_bc_xprt to svc_xprt'. I'd like recording bc_xprt in svc_sock.

thanks,
Kinglong Mee

