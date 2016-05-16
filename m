Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785AbcEPLqx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 May 2016 07:46:53 -0400
Subject: Re: [PATCH] gssd: Convert 'rdma' to 'tcp' protocol
To: Chuck Lever <chuck.lever@oracle.com>
References: <20160504144342.15837.19874.stgit@manet.1015granger.net>
 <0d048d10-d03e-a038-bc53-d9c292c7ec66@RedHat.com>
 <26FBA169-5D47-4372-8514-6078624196D1@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <9b173415-cceb-d939-5424-68c7b9544e2b@RedHat.com>
Date: Mon, 16 May 2016 07:46:52 -0400
MIME-Version: 1.0
In-Reply-To: <26FBA169-5D47-4372-8514-6078624196D1@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/14/2016 03:51 PM, Chuck Lever wrote:
> 
>> On May 14, 2016, at 12:29 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>>
>> On 05/04/2016 10:43 AM, Chuck Lever wrote:
>>> The kernel NFS client specifies 'rdma' as the transport protocol for
>>> NFS/RDMA mounts. This is a generic display token, probably not
>>> something the kernel should lie about. The kernel uses it to form
>>> NFSv4 client IDs, for example.
>>>
>>> Until gssd can speak RPC-over-RDMA, convert 'rdma' to 'tcp' in
>>> kernel gss upcalls.
>>>
>>> This means that the Linux NFS client requires an NFS/TCP service on
>>> an NFS/RDMA server when establishing a GSS context for proto=rdma
>>> mount points. This is probably not an onerous requirement for the
>>> time being.
>>>
>>> Eventually user space support for RPC-over-RDMA might be introduced,
>>> and gssd can use that for context establishment.
>> Shouldn't we log something tell to the user this is happening??
> 
> I don't understand what "this" refers to.
> 
> There's no error here, and there's nothing a user or admin
> can or should do to change the situation.
> 
> What am I missing?
My bad... for some reason I thought this conversion was happening
in the mount code, instead its happening in the processing of
an upcall... I understand what's going on... sorry for the noise... 

Committed! 

steved.
 
> 
> 
>> steved.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> utils/gssd/gssd.c |   16 ++++++++++++++++
>>> 1 file changed, 16 insertions(+)
>>>
>>> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
>>> index 7ba27b1..51b2cd7 100644
>>> --- a/utils/gssd/gssd.c
>>> +++ b/utils/gssd/gssd.c
>>> @@ -301,6 +301,22 @@ gssd_read_service_info(int dirfd, struct clnt_info *clp)
>>> 		goto fail;
>>> 	}
>>>
>>> +	/*
>>> +	 * The user space RPC library has no support for
>>> +	 * RPC-over-RDMA at this time, so change 'rdma'
>>> +	 * to 'tcp', and '20049' to '2049'.
>>> +	 */
>>> +	if (strcmp(protoname, "rdma") == 0) {
>>> +		free(protoname);
>>> +		protoname = strdup("tcp");
>>> +		if (!protoname)
>>> +			goto fail;
>>> +		free(port);
>>> +		port = strdup("2049");
>>> +		if (!port)
>>> +			goto fail;
>>> +	}
>>> +
>>> 	if (!gssd_addrstr_to_sockaddr((struct sockaddr *)&clp->addr,
>>> 				 address, port ? port : ""))
>>> 		goto fail;
>>>
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
