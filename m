Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31607 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757883Ab3GVROg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jul 2013 13:14:36 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] NFSv4.1 Use clientid management rpc_clnt for secinfo
Date: Mon, 22 Jul 2013 17:14:35 +0000
Message-ID: <D7467F6B-6C29-475F-B7CF-785C0E3B533C@netapp.com>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
 <1374511328-49579-3-git-send-email-andros@netapp.com>
 <1374512315.7972.6.camel@leira.trondhjem.org>
In-Reply-To: <1374512315.7972.6.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2013, at 12:58 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Mon, 2013-07-22 at 12:42 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> As per RFC 3530 and RFC 5661 Security Considerations
> 
> RFC3530-bis, not RFC3530...
> 
>> Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
>> uses the nfs_client cl_rpcclient for all clientid management operations.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 7761802..6a30a72 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5806,9 +5806,10 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
>> 		.rpc_argp = &args,
>> 		.rpc_resp = &res,
>> 	};
>> +	struct rpc_clnt *clnt = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
>> 
>> 	dprintk("NFS call  secinfo %s\n", name->name);
>> -	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
>> +	status = nfs4_call_sync(clnt, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
>> 	dprintk("NFS reply  secinfo: %d\n", status);
>> 	return status;
>> }
> 
> Has this been tested against a variety of server implementations? I know
> what the spec says, but the behaviour we're relying on here is subtly
> changed from what was originally documented in RFC3530.


Not yet. I'll set up some tests.

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

