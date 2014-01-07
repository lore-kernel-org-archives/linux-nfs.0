Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38182 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaAGFWA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jan 2014 00:22:00 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so17787538pab.33
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 21:22:00 -0800 (PST)
Message-ID: <52CB8EF3.30300@gmail.com>
Date: Tue, 07 Jan 2014 13:21:55 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Dr Fields James Bruce <bfields@fieldses.org>,
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
> 
> Just move the 'args->bc_xprt->xpt_bc_xprt = xprt’ line into the caller 
> (see earlier discussion about xs_setup_bc_tcp()).
> Quite frankly, I don’t see why the client code should be modifying this variable in the first place.
> An svc_xprt is a server construct.

That's really better.

I will check those codes for NFSv4.1 backchannel in sunrpc, 
maybe I will cleanup the client code from svc_xprt.

thanks,
Kinglong Mee


