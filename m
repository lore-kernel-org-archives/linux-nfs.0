Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:19199 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754483Ab1HZN7Q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2011 09:59:16 -0400
Subject: Re: [PATCH] mount.nfs: Preserve any explicit port=2049 option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E56ED9D.7020906@RedHat.com>
Date: Fri, 26 Aug 2011 09:58:55 -0400
Cc: Luk Claes <luk@debian.org>, linux-nfs@vger.kernel.org
Message-Id: <4D7CDC73-5EF0-438E-98B5-32B06730B5B6@oracle.com>
References: <1312625496-2496-1-git-send-email-luk@debian.org> <4E56AFCB.2020803@RedHat.com> <F4AA6B6E-D029-47BC-A710-23A7AE2582A8@oracle.com> <4E56ED9D.7020906@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 25, 2011, at 8:49 PM, Steve Dickson wrote:

> On 08/25/2011 04:46 PM, Chuck Lever wrote:
>> 
>> On Aug 25, 2011, at 4:25 PM, Steve Dickson wrote:
>> 
>>> First of all let me apologize for taking so long
>>> to get to this... I did take some time off.... 
>>> 
>>> On 08/06/2011 06:11 AM, Luk Claes wrote:
>>>> If NFS port (2049) is supplied explicitly, don't ignore this setting by requesting it to portmapper again. Thanks to Ben Hutchings <ben@decadent.org.uk> for the patch.
>>>> 
>>>> Signed-off-by: Luk Claes <luk@debian.org>
>>>> ---
>>>> utils/mount/stropts.c |    4 ++--
>>>> 1 files changed, 2 insertions(+), 2 deletions(-)
>>>> 
>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>> index f1aa503..8b2799c 100644
>>>> --- a/utils/mount/stropts.c
>>>> +++ b/utils/mount/stropts.c
>>>> @@ -437,8 +437,8 @@ static int nfs_construct_new_options(struct mount_options *options,
>>>> 	if (po_append(options, new_option) == PO_FAILED)
>>>> 		return 0;
>>>> 
>>>> -	po_remove_all(options, "port");
>>>> -	if (nfs_pmap->pm_port != NFS_PORT) {
>>>> +	if(po_remove_all(options, "port") == PO_FOUND ||
>>>> +	   nfs_pmap->pm_port != NFS_PORT) {
>>>> 		snprintf(new_option, sizeof(new_option) - 1,
>>>> 			 "port=%lu", nfs_pmap->pm_port);
>>>> 		if (po_append(options, new_option) == PO_FAILED)
>>> Now I like the idea of not sending the pmap inquire for the 
>>> port when the port is specified on the command because its
>>> a TCP connection. During automount storms, wasting TCP connections
>>> is not a good thing... 
>>> 
>>> But your patch does not seem to do that since all the port
>>> negotiation is done well before this part of the code.
>> 
>> I thought the idea was to eliminate the port query during REnegotiation
>> if "port=" was specified.  That seems like exactly what the patch does.  
> Ah, I did miss the renegotiation aspect... Its been a long day... ;-)
> 
>> Does the initial port negotiation also have this problem?
> Well I was thinking why even do the initial port negotiation when
> the port= is set... 

An rpcbind query is still needed if port= is specified but transport or version options were not.  Simply specifying port= does not shut off negotiation.  All three NFS parameters have to be specified to shut off the rpcbind query.  Doing the MNT request also performs an rpcbind query, but by default both of those are done via UDP.

The issue of keeping TCP port usage at a minimum is real and related to negotiation behavior, but is IMO separate.  My sense is that rpcbind queries are probably not really a big problem (and of course we would be wise to quantify this problem before making aggressive changes).  mount.nfs's rpcbind queries should always come from an ephemeral port, which is a larger resource pool than privileged ports and thus more difficult to exhaust.  Using NFSv4 more, just by itself, should improve matters since it skips the rpcbind step by default and doesn't use MNT at all.

>> But we should be careful here: mount.nfs will do an rpcbind query if a port= 
>> was specified if there is also some doubt about whether to use TCP or UDP, 
>> or what NFS version is available.  The only time rpcbind queries should be 
>> completely squashed is when the mount parameters are specified completely 
>> (transport, version, and port).
> I agree with being careful here... But if some admin is specifying 
> a particular port I'm thinking one, they have a clue and two, 99% of 
> time the port is correct. So lets just verify the port by using it
> NFS ping. So I'm thinking %99 of the time there is no need to create 
> that second TCP connection when a port is specified.

I think the kernel already does an NFS ping during mount processing (someone should verify that, of course).  But as I said above, all three NFS parameters [transport, NFS version, and port] have to be specified to avoid the rpcbind query.

> But, here is were we have to be careful. That  1% of the
> time the ping fails, for whatever reason... That is when I think
> we to consult with the server's rpcbind and the second TCP
> connection is justified. 
> 
> I just thinking making that assuming the specified info
> is as good way to save a TCP connection... 

Hrm, I don't see what that buys us.  If the ping fails and the port specified on the mount command line is actually registered on the server, what is the client's recourse?

> 
>> 
>>> I'm thinking some code has to change in nfs_probe_port() 
>>> something like:
>>> 
>>>   mount.nfs: Do not send pmap inquire when port is specified
>>> 
>>>   When the port is specified on the command line do not
>>>   send a pmap inquire asking for the port. Instead use
>>>   the given port in the NFS ping. If the ping fails,
>>>   assume a bad port was given and now go ask the server
>>>   for the correct port.
>> 
>> If the server has more than one NFS port enabled, and the client is 
>> requesting a port that isn't registered with the server's rpcbind, it 
>> shouldn't fall back to the registered port IMO.
> True. With this patch there is no fall back. When the NFS ping fails, 
> the registered port is obtained; compared to the specified port.
> If they are different the mount will fail as it does to today.
> 
> steved.
> 
>> 
>>>   Signed-off-by: Steve Dickson <steved@redhat.com>
>>> 
>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>> index d1f91dc..405c320 100644
>>> --- a/utils/mount/network.c
>>> +++ b/utils/mount/network.c
>>> @@ -545,17 +545,18 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
>>> 	const unsigned int prot = (u_int)pmap->pm_prot, *p_prot;
>>> 	const u_short port = (u_short) pmap->pm_port;
>>> 	unsigned long vers = pmap->pm_vers;
>>> -	unsigned short p_port;
>>> +	unsigned short p_port = port;
>>> +	int once = 1;
>>> 
>>> 	memcpy(saddr, sap, salen);
>>> 	p_prot = prot ? &prot : protos;
>>> 	p_vers = vers ? &vers : versions;
>>> -
>>> 	for (;;) {
>>> 		if (verbose)
>>> 			printf(_("%s: prog %lu, trying vers=%lu, prot=%u\n"),
>>> 				progname, prog, *p_vers, *p_prot);
>>> -		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
>>> +		if (!p_port)
>>> +			p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
>>> 		if (p_port) {
>>> 			if (!port || port == p_port) {
>>> 				nfs_set_port(saddr, p_port);
>>> @@ -564,6 +565,15 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
>>> 				if (nfs_rpc_ping(saddr, salen, prog,
>>> 							*p_vers, *p_prot, NULL))
>>> 					goto out_ok;
>>> +				if (port == p_port && once) {
>>> +					/*
>>> +					 * Could be a bad port was specified. This
>>> +					 * time ask the server for the port but only
>>> +					 * do it once.
>>> +					 */
>>> +					p_port = once = 0;
>>> +					continue;
>>> +				}
>>> 			} else
>>> 				rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
>>> 		}
>>> @@ -589,6 +599,7 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
>>> 	}
>>> 
>>> 	nfs_pp_debug2("failed");
>>> 	return 0;
>>> 
>>> out_ok:
>>> 
>>> 
>>> I'm not sure this is best way either.... 
>>> 
>>> steved.
>>> 
>>> 
>>> 
>>> 
>>> 
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




