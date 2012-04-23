Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:49866 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755205Ab2DWVrs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 17:47:48 -0400
Subject: Re: [PATCH 18/20] NFS: Detect NFSv4 server trunking when mounting
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1335216465.11427.34.camel@lade.trondhjem.org>
Date: Mon, 23 Apr 2012 17:47:42 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <D8A65C3B-980B-4A99-AE36-3A451568AE31@oracle.com>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net> <20120423205552.11446.58714.stgit@degas.1015granger.net> <1335216465.11427.34.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 23, 2012, at 5:27 PM, Myklebust, Trond wrote:

> On Mon, 2012-04-23 at 16:55 -0400, Chuck Lever wrote:
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 6a1a305..df59951 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -57,10 +57,12 @@
>> #include "internal.h"
>> #include "pnfs.h"
>> 
>> +#define NFSDBG_FACILITY		NFSDBG_CLIENT
> 
> Most of the stuff in nfs4state.c is dealing with NFSv4-specific state.
> It does not make sense to lump that in with the nfs_client debugging.
> 

It was the closest convenient.  Shall I create an NFSDBG_STATE?

>> +
>> #define OPENOWNER_POOL_SIZE	8
>> 
>> const nfs4_stateid zero_stateid;
>> -
>> +static DEFINE_MUTEX(nfs_clid_init_mutex);
>> static LIST_HEAD(nfs4_clientid_list);
>> 
>> int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




