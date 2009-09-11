From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: [pnfs] [PATCH v3 03/12] nfsd41: sunrpc: add new xprt class for
	nfsv4.1 backchannel
Date: Fri, 11 Sep 2009 14:12:35 -0700
Message-ID: <5e24e8930909111412r2c7bdc58u119767517154d6@mail.gmail.com>
References: <4AA8C597.8080809@panasas.com>
	 <1252574732-30108-1-git-send-email-bhalevy@panasas.com>
	 <4AA90E3A.80400@panasas.com> <20090911205821.GE5701@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f172.google.com ([209.85.221.172]:45794 "EHLO
	mail-qy0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756851AbZIKVMd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2009 17:12:33 -0400
Received: by qyk2 with SMTP id 2so1305450qyk.21
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2009 14:12:36 -0700 (PDT)
In-Reply-To: <20090911205821.GE5701@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2009 at 1:58 PM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Thu, Sep 10, 2009 at 05:33:30PM +0300, Benny Halevy wrote:
>> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/=
xprtrdma.h
>> index 54a379c..c2f04e1 100644
>> --- a/include/linux/sunrpc/xprtrdma.h
>> +++ b/include/linux/sunrpc/xprtrdma.h
>> @@ -41,11 +41,6 @@
>> =A0#define _LINUX_SUNRPC_XPRTRDMA_H
>>
>> =A0/*
>> - * RPC transport identifier for RDMA
>> - */
>> -#define XPRT_TRANSPORT_RDMA =A0256
>> -
>> -/*
>> =A0 * rpcbind (v3+) RDMA netid.
>> =A0 */
>> =A0#define RPCBIND_NETID_RDMA =A0 "rdma"
>> diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/=
xprtsock.h
>> index c2a46c4..d7c98d1 100644
>> --- a/include/linux/sunrpc/xprtsock.h
>> +++ b/include/linux/sunrpc/xprtsock.h
>> @@ -20,8 +20,13 @@ void =A0 =A0 =A0 =A0 =A0 =A0 =A0 cleanup_socket_x=
prt(void);
>> =A0 * values. No such restriction exists for new transports, except =
that
>> =A0 * they may not collide with these values (17 and 6, respectively=
).
>> =A0 */
>> -#define XPRT_TRANSPORT_UDP =A0 IPPROTO_UDP
>> -#define XPRT_TRANSPORT_TCP =A0 IPPROTO_TCP
>> +#define XPRT_TRANSPORT_BC =A0 =A0(1 << 31)
>> +enum xprt_transports {
>> + =A0 =A0 XPRT_TRANSPORT_UDP =A0 =A0 =A0=3D IPPROTO_UDP,
>> + =A0 =A0 XPRT_TRANSPORT_TCP =A0 =A0 =A0=3D IPPROTO_TCP,
>> + =A0 =A0 XPRT_TRANSPORT_BC_TCP =A0 =3D IPPROTO_TCP | XPRT_TRANSPORT=
_BC,
>> + =A0 =A0 XPRT_TRANSPORT_RDMA =A0 =A0 =3D 256
>> +};
>
> This fails to compile when CONFIG_SUNRPC_XPRT_RDMA is set.
>
> A minimal fix might be:
>
> =A0 =A0 =A0 =A0--- a/net/sunrpc/xprtrdma/transport.c
> =A0 =A0 =A0 =A0+++ b/net/sunrpc/xprtrdma/transport.c
> =A0 =A0 =A0 =A0@@ -50,6 +50,8 @@
> =A0 =A0 =A0 =A0 #include <linux/module.h>
> =A0 =A0 =A0 =A0 #include <linux/init.h>
> =A0 =A0 =A0 =A0 #include <linux/seq_file.h>
> =A0 =A0 =A0 =A0+#include <linux/in.h>
> =A0 =A0 =A0 =A0+#include <linux/sunrpc/xprtsock.h>
>
> =A0 =A0 =A0 =A0 #include "xprt_rdma.h"
>
> Or maybe just ditch the enum and leave these as they were before.
>

The incentive here was to have all the transports definitions together
so that nobody re-uses a number by mistake (not very likely of
course), so I think the fix you suggested is appropriate.

-alexandros

> --b.
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
