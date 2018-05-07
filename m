Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:55470 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbeEGOLq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 10:11:46 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH v1 01/19] xprtrdma: Add proper SPDX tags for
 NetApp-contributed source
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4da36188-17d2-7b68-2974-80402c96359c@Netapp.com>
Date: Mon, 7 May 2018 10:11:42 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <AD3908D5-D04C-4CDB-8ABD-14AB62984A2B@oracle.com>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
 <20180504193432.31688.65935.stgit@manet.1015granger.net>
 <4da36188-17d2-7b68-2974-80402c96359c@Netapp.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Thanks for the review!


> On May 7, 2018, at 9:27 AM, Anna Schumaker <anna.schumaker@netapp.com> =
wrote:
>=20
> Hi Chuck,
>=20
> On 05/04/2018 03:34 PM, Chuck Lever wrote:
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/rpc_rdma.h |    1 +
>> include/linux/sunrpc/xprtrdma.h |    1 +
>> net/sunrpc/xprtrdma/module.c    |    1 +
>> net/sunrpc/xprtrdma/rpc_rdma.c  |    1 +
>> net/sunrpc/xprtrdma/transport.c |    1 +
>> net/sunrpc/xprtrdma/verbs.c     |    1 +
>> net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
>> 7 files changed, 7 insertions(+)
>>=20
>> diff --git a/include/linux/sunrpc/rpc_rdma.h =
b/include/linux/sunrpc/rpc_rdma.h
>> index 8f144db..92d182f 100644
>> --- a/include/linux/sunrpc/rpc_rdma.h
>> +++ b/include/linux/sunrpc/rpc_rdma.h
>> @@ -1,3 +1,4 @@
>> +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
>> /*
>>  * Copyright (c) 2015-2017 Oracle. All rights reserved.
>>  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights =
reserved.
>> diff --git a/include/linux/sunrpc/xprtrdma.h =
b/include/linux/sunrpc/xprtrdma.h
>> index 5859563..86fc38f 100644
>> --- a/include/linux/sunrpc/xprtrdma.h
>> +++ b/include/linux/sunrpc/xprtrdma.h
>> @@ -1,3 +1,4 @@
>> +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
>> /*
>>  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights =
reserved.
>>  *
>> diff --git a/net/sunrpc/xprtrdma/module.c =
b/net/sunrpc/xprtrdma/module.c
>> index a762d19..f338065 100644
>> --- a/net/sunrpc/xprtrdma/module.c
>> +++ b/net/sunrpc/xprtrdma/module.c
>> @@ -1,3 +1,4 @@
>> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>=20
> I'm not familiar with hte SPDX-License-Identifier tag.  Is there a =
reason it has to exist in a separate comment block at the top of the =
file instead of getting rolled in with the copyright stuff right below =
it?

I believe that each tag is meant to be parsed by a script
to produce a license manifest file for packaging. Thus the
tag is maintained on a separate line using a specific
format.

More information is at https://spdx.org


> Either way, can you use the C-style ("/* ... */") comments here (and =
in a few other places below) for consistency?

Here is a mechanical survey of familiar kernel source
files that already have an SPDX tag.

[cel@klimt linux]$ grep SPDX net/sunrpc/*
grep: net/sunrpc/auth_gss: Is a directory
net/sunrpc/auth_null.c:// SPDX-License-Identifier: GPL-2.0
net/sunrpc/auth_unix.c:// SPDX-License-Identifier: GPL-2.0
net/sunrpc/debugfs.c:// SPDX-License-Identifier: GPL-2.0
net/sunrpc/Makefile:# SPDX-License-Identifier: GPL-2.0
net/sunrpc/netns.h:/* SPDX-License-Identifier: GPL-2.0 */
net/sunrpc/xprtmultipath.c:// SPDX-License-Identifier: GPL-2.0
grep: net/sunrpc/xprtrdma: Is a directory
net/sunrpc/xprtsock.c:// SPDX-License-Identifier: GPL-2.0
[cel@klimt linux]$ grep SPDX fs/nfs/*
grep: fs/nfs/blocklayout: Is a directory
fs/nfs/cache_lib.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/cache_lib.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/callback.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/callback.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/callback_proc.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/callback_xdr.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/delegation.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/dns_resolve.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/dns_resolve.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/export.c:// SPDX-License-Identifier: GPL-2.0
grep: fs/nfs/filelayout: Is a directory
grep: fs/nfs/flexfilelayout: Is a directory
fs/nfs/internal.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/io.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/iostat.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/Makefile:# SPDX-License-Identifier: GPL-2.0
fs/nfs/mount_clnt.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/netns.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/nfs2xdr.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs3acl.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs3_fs.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/nfs3proc.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs3xdr.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs42.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/nfs42proc.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs42xdr.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs4file.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs4_fs.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/nfs4getroot.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs4namespace.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs4session.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/nfs4sysctl.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs4trace.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfs4trace.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/nfs.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/nfsroot.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfstrace.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/nfstrace.h:/* SPDX-License-Identifier: GPL-2.0 */
fs/nfs/proc.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/symlink.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/sysctl.c:// SPDX-License-Identifier: GPL-2.0
fs/nfs/unlink.c:// SPDX-License-Identifier: GPL-2.0
[cel@klimt linux]$

The tags I've proposed are consistent with other usage:

-> .c files use // ... comments
-> .h files use /* ... */ comments
-> Makefiles use # comments

There were no complaints from checkpatch.pl about the
comment style in my patch.


> Thanks,
> Anna
>=20
>> /*
>>  * Copyright (c) 2015, 2017 Oracle.  All rights reserved.
>>  */
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c =
b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index e8adad3..8f89e3f 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -1,3 +1,4 @@
>> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>> /*
>>  * Copyright (c) 2014-2017 Oracle.  All rights reserved.
>>  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights =
reserved.
>> diff --git a/net/sunrpc/xprtrdma/transport.c =
b/net/sunrpc/xprtrdma/transport.c
>> index cc1aad3..4717578 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -1,3 +1,4 @@
>> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>> /*
>>  * Copyright (c) 2014-2017 Oracle.  All rights reserved.
>>  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights =
reserved.
>> diff --git a/net/sunrpc/xprtrdma/verbs.c =
b/net/sunrpc/xprtrdma/verbs.c
>> index c345d36..10f5032 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -1,3 +1,4 @@
>> +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
>> /*
>>  * Copyright (c) 2014-2017 Oracle.  All rights reserved.
>>  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights =
reserved.
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h =
b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index cb41b12..e83ba758 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -1,3 +1,4 @@
>> +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
>> /*
>>  * Copyright (c) 2014-2017 Oracle.  All rights reserved.
>>  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights =
reserved.
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



