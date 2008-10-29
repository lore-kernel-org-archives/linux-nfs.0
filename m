From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/14] NSM: Support IPv6 version of mon_name
Date: Wed, 29 Oct 2008 16:22:33 -0400
Message-ID: <4B3F51CA-E2E8-45B7-B1B7-AB94BC519EB0@oracle.com>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net> <20081024181009.23810.56793.stgit@ingres.1015granger.net> <20081029200018.GB1406@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:12164 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbYJ2UWp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2008 16:22:45 -0400
In-Reply-To: <20081029200018.GB1406@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2008, at 4:00 PM, J. Bruce Fields wrote:

> On Fri, Oct 24, 2008 at 02:10:09PM -0400, Chuck Lever wrote:
>> When the "nsm_use_hostnames" sysctl is set to zero, the kernel's NSM
>> provides a presentation format IP address in the mon_name argument of
>> SM_MON upcalls.  This is part of the private interface between  
>> Linux's
>> rpc.statd and the kernel's lockd implementation.  Linux's rpc.statd
>> can then resolve this address with DNS as a sanity check.
>
> Have you checked how rpc.statd actually uses this field?

The main piece is here:

   utils/statd/monitor.c:sm_mon_1_svc()

This function receives the incoming SM_MON RPC and attempts to sanity  
check the contents of the mon_name argument by performing a DNS lookup.

It appears to use a second DNS lookup to normalize all incoming names  
so that subsequent hostname matches (ie when handling an SM_NOTIFY  
request) have a better change of succeeding.

> --b.
>
>>
>> To support IPv6 addresses for the mon_name argument, just point the
>> XDR encoder to the nsm_handle's eye-catcher, which already contains a
>> presentation format address string.
>>
>> Finally, provide some debugging message clean up.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/lockd/mon.c |   43 +++++++++++++++----------------------------
>> 1 files changed, 15 insertions(+), 28 deletions(-)
>>
>> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
>> index a5c6ec4..1c058b1 100644
>> --- a/fs/lockd/mon.c
>> +++ b/fs/lockd/mon.c
>> @@ -18,8 +18,6 @@
>>
>> #define NLMDBG_FACILITY		NLMDBG_MONITOR
>>
>> -#define XDR_ADDRBUF_LEN		(20)
>> -
>> static struct rpc_clnt *	nsm_create(void);
>>
>> static struct rpc_program	nsm_program;
>> @@ -40,7 +38,14 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc,  
>> struct nsm_res *res)
>> {
>> 	struct rpc_clnt	*clnt;
>> 	int		status;
>> -	struct nsm_args	args;
>> +	struct nsm_args	args = {
>> +		.addr		= nsm_addr_in(nsm)->sin_addr.s_addr,
>> +		.prog		= NLM_PROGRAM,
>> +		.vers		= 3,
>> +		.proc		= NLMPROC_NSM_NOTIFY,
>> +		.mon_name	= nsm_use_hostnames ?
>> +					nsm->sm_name : nsm->sm_addrbuf,
>> +	};
>> 	struct rpc_message msg = {
>> 		.rpc_argp	= &args,
>> 		.rpc_resp	= res,
>> @@ -49,24 +54,21 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc,  
>> struct nsm_res *res)
>> 	clnt = nsm_create();
>> 	if (IS_ERR(clnt)) {
>> 		status = PTR_ERR(clnt);
>> +		dprintk("lockd: failed to create nsm transport, "
>> +				"status=%d\n", status);
>> 		goto out;
>> 	}
>>
>> -	memset(&args, 0, sizeof(args));
>> -	args.mon_name = nsm->sm_name;
>> -	args.addr = nsm_addr_in(nsm)->sin_addr.s_addr;
>> -	args.prog = NLM_PROGRAM;
>> -	args.vers = 3;
>> -	args.proc = NLMPROC_NSM_NOTIFY;
>> 	memset(res, 0, sizeof(*res));
>>
>> 	msg.rpc_proc = &clnt->cl_procinfo[proc];
>> 	status = rpc_call_sync(clnt, &msg, 0);
>> 	if (status < 0)
>> -		printk(KERN_DEBUG "nsm_mon_unmon: rpc failed, status=%d\n",
>> -			status);
>> -	else
>> +		dprintk("lockd: nsm rpc failed, status=%d\n", status);
>> +	else {
>> 		status = 0;
>> +		dprintk("lockd: monitoring '%s'\n", args.mon_name);
>> +	}
>> 	rpc_shutdown_client(clnt);
>>  out:
>> 	return status;
>> @@ -253,25 +255,10 @@ static __be32 *xdr_encode_nsm_string(__be32  
>> *p, char *string)
>>
>> /*
>>  * "mon_name" specifies the host to be monitored.
>> - *
>> - * Linux uses a text version of the IP address of the remote
>> - * host as the host identifier (the "mon_name" argument).
>> - *
>> - * Linux statd always looks up the canonical hostname first for
>> - * whatever remote hostname it receives, so this works alright.
>>  */
>> static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
>> {
>> -	char	buffer[XDR_ADDRBUF_LEN + 1];
>> -	char	*name = argp->mon_name;
>> -
>> -	if (!nsm_use_hostnames) {
>> -		snprintf(buffer, XDR_ADDRBUF_LEN,
>> -			 NIPQUAD_FMT, NIPQUAD(argp->addr));
>> -		name = buffer;
>> -	}
>> -
>> -	return xdr_encode_nsm_string(p, name);
>> +	return xdr_encode_nsm_string(p, argp->mon_name);
>> }
>>
>> /*
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



