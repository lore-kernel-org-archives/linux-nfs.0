From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 3 Nov 2008 17:33:09 -0500
Message-ID: <4d569c330811031433k7ae18d4enfbda349e8f90a951@mail.gmail.com>
References: <1225724721.2247.29.camel@brian-laptop>
	 <1225731544.6958.6.camel@heimdal.trondhjem.org>
	 <1225734631.2247.76.camel@brian-laptop>
	 <4d569c330811031158r26963e0w5bcf8331e0fb14b7@mail.gmail.com>
	 <1225742958.2247.128.camel@brian-laptop>
	 <4d569c330811031228r5bb9aefs7a970303910810e2@mail.gmail.com>
	 <1225746764.2247.133.camel@brian-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:42390 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707AbYKCWdL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 17:33:11 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1065145yxm.1
        for <linux-nfs@vger.kernel.org>; Mon, 03 Nov 2008 14:33:09 -0800 (PST)
In-Reply-To: <1225746764.2247.133.camel@brian-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 3, 2008 at 4:12 PM, Brian J. Murrell <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org> wrote:
> On Mon, 2008-11-03 at 15:28 -0500, Kevin Coffman wrote:
>>
>> There should definitely be corresponding debug output from rpc.gssd
>> (-vvv) if you got those librpcsecgss (-rrr) messages.
>
> Yes, but by my last post I had debug only on the client and not the
> server but when I enabled on the server I couldn't elicit the client at
> will.
>
>> Re: the upcall.  Any new mount using Kerberos should cause the upcall
>> to create a new context with the server.  Make sure the filesystem is
>> not already mounted.
>
> It was definitely not mounted the last time I tried to mount it and
> produce the upcall output but it just never happened.
>
>> After the mount, any new user accessing that
>> mounted filesystem should cause an upcall to create a context for that
>> user.
>
> I seem to have since gotten an upcall and here is the corresponding
> client and server debug:
>
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_create_default()
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_create()
> Nov  3 15:17:33 pc rpc.gssd[2937]: authgss_create: name is 0x98fd358
> Nov  3 15:17:33 pc rpc.gssd[2937]: authgss_create: gd->name is 0x98f9cc8
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_refresh()
> Nov  3 15:17:33 pc rpc.gssd[2937]: struct rpc_gss_sec:
> Nov  3 15:17:33 pc rpc.gssd[2937]:      mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 }
> Nov  3 15:17:33 pc rpc.gssd[2937]:      qop: 0
> Nov  3 15:17:33 pc rpc.gssd[2937]:      service: 1
> Nov  3 15:17:33 pc rpc.gssd[2937]:      cred: 0x98fb568
> Nov  3 15:17:33 pc rpc.gssd[2937]:      req_flags: 00000002
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_marshal()
> Nov  3 15:17:33 pc rpc.gssd[2937]: xdr_rpc_gss_buf: encode success ((nil):0)
> Nov  3 15:17:33 pc rpc.gssd[2937]: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_wrap()
> Nov  3 15:17:33 pc rpc.gssd[2937]: xdr_rpc_gss_buf: encode success (0x98fbc08:459)
> Nov  3 15:17:33 pc rpc.gssd[2937]: xdr_rpc_gss_init_args: encode success (token 0x98fbc08:459)
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_validate()
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_unwrap()
> Nov  3 15:17:33 pc rpc.gssd[2937]: xdr_rpc_gss_buf: decode success (0x98fd428:4)
> Nov  3 15:17:33 pc rpc.gssd[2937]: xdr_rpc_gss_buf: decode success (0x990e428:114)
> Nov  3 15:17:33 pc rpc.gssd[2937]: xdr_rpc_gss_init_res decode success (ctx 0x98fd428:4, maj 0, min 0, win 128, token 0x990e428:114)
> Nov  3 15:17:33 pc rpc.gssd[2937]: authgss_create_default: freeing name 0x98fd358
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_get_private_data()
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_free_private_data()
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_destroy()
> Nov  3 15:17:33 pc rpc.gssd[2937]: in authgss_destroy_context()
> Nov  3 15:17:33 pc rpc.gssd[2937]: authgss_destroy: freeing name 0x98f9cc8

Once again, this is all from librpcsecgss.  No messages originating
from rpc.gssd itself here.

> Nov  3 15:17:33 linux krb5kdc[5006]: TGS_REQ (1 etypes {1}) 10.75.22.1: ISSUE: authtime 1225740577, etypes {rep=1 tkt=1 ses=1}, brian@ILINX for nfs/linux.interlinx.bc.ca@ILINX
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: leaving poll
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: handling null request
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: sname = brian@ILINX
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: DEBUG: serialize_krb5_ctx: lucid version!
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: doing downcall
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: mech: krb5, hndl len: 4, ctx len 85, timeout: 2147483647, uid: 1001, gid: 1001, num aux grps: 13:
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   1) 1001
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   2) 117
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   3) 1010
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   4) 1011
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   5) 2000
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   6) 29
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   7) 20
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   8) 24
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (   9) 25
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (  10) 30
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (  11) 44
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (  12) 46
> Nov  3 15:17:33 linux rpc.svcgssd[13724]:   (  13) 111
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: sending null reply
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: writing message: ...
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: finished handling null request
> Nov  3 15:17:33 linux rpc.svcgssd[13724]: entering poll

This looks like the server (the svcgssd/user-land part anyway) was
happy, and replied with a context.  There were a couple of reports in
the past where the server returned error 524288 (GSS_S_NO_CONTEXT)
after getting through the user-land part successfully.  If you can get
a packet trace between the client and server during the mount /
context negotiation, check the NULL reply from the server for this
error code.

K.C.
