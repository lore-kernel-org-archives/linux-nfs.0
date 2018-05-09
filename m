Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:41772 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935279AbeEIUmX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2018 16:42:23 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH v1 01/19] svcrdma: Add proper SPDX tags for
 NetApp-contributed source
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180509202323.GA31959@fieldses.org>
Date: Wed, 9 May 2018 16:42:19 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <32DBD8DB-07FD-4D89-B88A-348B0F6103BB@oracle.com>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
 <20180507192655.4608.26260.stgit@klimt.1015granger.net>
 <20180509202323.GA31959@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 9, 2018, at 4:23 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> Looking at the git history, it looks like others are taking this as an
> opportunity to replace the existing boilerplate.  Could we do this =
here?
> Looks like "BSD-3-Clause" does in fact refer to a license that's
> word-for-word the same as the one included here (except for the name =
of
> the copyright holder), so I wonder if we need it written out here any
> more.
>=20
> (Minor point, I'm applying this anyway and you can follow up with the
> remval patch or not.)

Because the holder's name is part of the boilerplate, I feel
that it is up to the holder to submit a patch removing the
whole copyright notice if they are comfortable doing that.

But IANAL. Feel free to convince me that I'm being prudish.


> --b.
>=20
> On Mon, May 07, 2018 at 03:26:55PM -0400, Chuck Lever wrote:
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/svc_rdma.h          |    1 +
>> net/sunrpc/xprtrdma/svc_rdma.c           |    1 +
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
>> net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    1 +
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
>> 5 files changed, 5 insertions(+)
>>=20
>> diff --git a/include/linux/sunrpc/svc_rdma.h =
b/include/linux/sunrpc/svc_rdma.h
>> index 7337e12..88da0c9 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -1,3 +1,4 @@
>> +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
>> /*
>>  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights =
reserved.
>>  *
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c =
b/net/sunrpc/xprtrdma/svc_rdma.c
>> index dd8a431..a490532 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
>> @@ -1,3 +1,4 @@
>> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>> /*
>>  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights =
reserved.
>>  *
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c =
b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> index 3d45015..9eae95d 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> @@ -1,3 +1,4 @@
>> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>> /*
>>  * Copyright (c) 2016, 2017 Oracle. All rights reserved.
>>  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c =
b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> index 649441d..79bd3a3 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> @@ -1,3 +1,4 @@
>> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>> /*
>>  * Copyright (c) 2016 Oracle. All rights reserved.
>>  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c =
b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 96cc8f6..3633254 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -1,3 +1,4 @@
>> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>> /*
>>  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
>>  * Copyright (c) 2005-2007 Network Appliance, Inc. All rights =
reserved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



