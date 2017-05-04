Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41536 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751907AbdEDNxe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2017 09:53:34 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 2/5] NFS: Add a mount option to specify number of TCP connections to use
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <EC0AD66D-D8B5-4912-A2DC-5B9167D2A01A@oracle.com>
Date: Thu, 4 May 2017 09:53:29 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5E9D117A-ACE7-4572-8984-5DD2CE43D72C@oracle.com>
References: <20170428172535.7945-1-trond.myklebust@primarydata.com> <20170428172535.7945-2-trond.myklebust@primarydata.com> <20170428172535.7945-3-trond.myklebust@primarydata.com> <EC0AD66D-D8B5-4912-A2DC-5B9167D2A01A@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 4, 2017, at 9:45 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> Hi Trond-
> 
> 
>> On Apr 28, 2017, at 1:25 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>> Allow the user to specify that the client should use multiple connections
>> to the server. For the moment, this functionality will be limited to
>> TCP and to NFSv4.x (x>0).
> 
> Some initial reactions:
> 
> - 5/5 could be squashed into this patch (2/5).
> 
> - 4/5 adds support for using NFSv3 with a DS. Why can't you add NFSv3
> support for multiple connections in the non-pNFS case? If there is a
> good reason, it should be stated in 4/5's patch description or added
> as a comment somewhere in the source code.
> 
> - Testing with a Linux server shows that the basic NFS/RDMA pieces
> work, but any OPEN operation gets NFS4ERR_GRACE, forever, when I use
> nconnect > 1. I'm looking into it.
> 
> - Testing with a Solaris 12 server prototype that supports NFSv4.1
> works fine with nconnect=[23]. Not seeing much performance improvement
> there because the server is using QDR and a single SATA SSD.
> 
> Thus I don't see a strong need to keep the TCP-only limitation. However,
> if you do keep it, the logic that implements the second sentence in the
> patch description above is added in 3/5. Should this sentence be in that
> patch description instead? Or, instead:
> 
> s/For the moment/In a subsequent patch

Oops, I forgot to mention: mountstats data looks a little confused
when nconnect > 1. For example:

WRITE:
           3075342 ops (131%)
        avg bytes sent per op: 26829    avg bytes received per op: 113
        backlog wait: 162.375128        RTT: 1.481101   total execute time: 163.861735 (milliseconds)

Haven't looked closely at that 131%, but it could be either the kernel
or the script itself is assuming one connection per mount.


>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> fs/nfs/internal.h |  1 +
>> fs/nfs/super.c    | 10 ++++++++++
>> 2 files changed, 11 insertions(+)
>> 
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 31b26cf1b476..31757a742e9b 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -117,6 +117,7 @@ struct nfs_parsed_mount_data {
>> 		char			*export_path;
>> 		int			port;
>> 		unsigned short		protocol;
>> +		unsigned short		nconnect;
>> 	} nfs_server;
>> 
>> 	struct security_mnt_opts lsm_opts;
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 54e0f9f2dd94..7eb48934dc79 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -76,6 +76,8 @@
>> #define NFS_DEFAULT_VERSION 2
>> #endif
>> 
>> +#define NFS_MAX_CONNECTIONS 16
>> +
>> enum {
>> 	/* Mount options that take no arguments */
>> 	Opt_soft, Opt_hard,
>> @@ -107,6 +109,7 @@ enum {
>> 	Opt_nfsvers,
>> 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
>> 	Opt_addr, Opt_mountaddr, Opt_clientaddr,
>> +	Opt_nconnect,
>> 	Opt_lookupcache,
>> 	Opt_fscache_uniq,
>> 	Opt_local_lock,
>> @@ -179,6 +182,8 @@ static const match_table_t nfs_mount_option_tokens = {
>> 	{ Opt_mounthost, "mounthost=%s" },
>> 	{ Opt_mountaddr, "mountaddr=%s" },
>> 
>> +	{ Opt_nconnect, "nconnect=%s" },
>> +
>> 	{ Opt_lookupcache, "lookupcache=%s" },
>> 	{ Opt_fscache_uniq, "fsc=%s" },
>> 	{ Opt_local_lock, "local_lock=%s" },
>> @@ -1544,6 +1549,11 @@ static int nfs_parse_mount_options(char *raw,
>> 			if (mnt->mount_server.addrlen == 0)
>> 				goto out_invalid_address;
>> 			break;
>> +		case Opt_nconnect:
>> +			if (nfs_get_option_ul_bound(args, &option, 1, NFS_MAX_CONNECTIONS))
>> +				goto out_invalid_value;
>> +			mnt->nfs_server.nconnect = option;
>> +			break;
>> 		case Opt_lookupcache:
>> 			string = match_strdup(args);
>> 			if (string == NULL)
>> -- 
>> 2.9.3
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



