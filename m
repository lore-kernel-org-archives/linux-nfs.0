Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:48625 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948Ab1H0Xpu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Aug 2011 19:45:50 -0400
Subject: Re: [PATCH] mount.nfs: Preserve any explicit port=2049 option
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E58E97F.7040006@RedHat.com>
Date: Sat, 27 Aug 2011 19:45:27 -0400
Cc: Luk Claes <luk@debian.org>, linux-nfs@vger.kernel.org
Message-Id: <2491A23F-8C69-4A5D-8D60-9E0A84DBF63E@oracle.com>
References: <1312625496-2496-1-git-send-email-luk@debian.org> <4E56AFCB.2020803@RedHat.com> <F4AA6B6E-D029-47BC-A710-23A7AE2582A8@oracle.com> <4E56ED9D.7020906@RedHat.com> <4D7CDC73-5EF0-438E-98B5-32B06730B5B6@oracle.com> <4E58E97F.7040006@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 27, 2011, at 8:56 AM, Steve Dickson wrote:

> Hey,
> 
> On 08/26/2011 09:58 AM, Chuck Lever wrote:
>> 
>> On Aug 25, 2011, at 8:49 PM, Steve Dickson wrote:
>> 
>>> On 08/25/2011 04:46 PM, Chuck Lever wrote:
>>>> 
>>>> On Aug 25, 2011, at 4:25 PM, Steve Dickson wrote:
>>>> 
>>>>> First of all let me apologize for taking so long
>>>>> to get to this... I did take some time off.... 
>>>>> 
>>>>> On 08/06/2011 06:11 AM, Luk Claes wrote:
>>>>>> If NFS port (2049) is supplied explicitly, don't ignore this setting by requesting it to portmapper again. Thanks to Ben Hutchings <ben@decadent.org.uk> for the patch.
>>>>>> 
>>>>>> Signed-off-by: Luk Claes <luk@debian.org>
>>>>>> ---
>>>>>> utils/mount/stropts.c |    4 ++--
>>>>>> 1 files changed, 2 insertions(+), 2 deletions(-)
>>>>>> 
>>>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>>>> index f1aa503..8b2799c 100644
>>>>>> --- a/utils/mount/stropts.c
>>>>>> +++ b/utils/mount/stropts.c
>>>>>> @@ -437,8 +437,8 @@ static int nfs_construct_new_options(struct mount_options *options,
>>>>>> 	if (po_append(options, new_option) == PO_FAILED)
>>>>>> 		return 0;
>>>>>> 
>>>>>> -	po_remove_all(options, "port");
>>>>>> -	if (nfs_pmap->pm_port != NFS_PORT) {
>>>>>> +	if(po_remove_all(options, "port") == PO_FOUND ||
>>>>>> +	   nfs_pmap->pm_port != NFS_PORT) {
>>>>>> 		snprintf(new_option, sizeof(new_option) - 1,
>>>>>> 			 "port=%lu", nfs_pmap->pm_port);
>>>>>> 		if (po_append(options, new_option) == PO_FAILED)
>>>>> Now I like the idea of not sending the pmap inquire for the 
>>>>> port when the port is specified on the command because its
>>>>> a TCP connection. During automount storms, wasting TCP connections
>>>>> is not a good thing... 
>>>>> 
>>>>> But your patch does not seem to do that since all the port
>>>>> negotiation is done well before this part of the code.
>>>> 
>>>> I thought the idea was to eliminate the port query during REnegotiation
>>>> if "port=" was specified.  That seems like exactly what the patch does.  
>>> Ah, I did miss the renegotiation aspect... Its been a long day... ;-)
>>> 
>>>> Does the initial port negotiation also have this problem?
>>> Well I was thinking why even do the initial port negotiation when
>>> the port= is set... 
>> 
>> An rpcbind query is still needed if port= is specified but transport or 
>> version options were not. Simply specifying port= does not shut off 
>> negotiation. 
> You are correct. Not only is the port specified but the version is also
> specified as well due to the fact we are in this part of the code. 
> 
>> All three NFS parameters have to be specified to shut off the rpcbind query.
> Why is this such a hard and fast rule?

If we change mount.nfs to go straight to TCP, then it will break mounting servers that support only UDP, when default mount options are used.  We've tried this before (I think quite by accident IIRC), and folks complained about the regression.

> Maybe in the past, when we moved from v2 to v3 and from UDP to TCP, all 
> three were needed but not in day in aged. TCP is now a mandated protocol,
> which almost guarantees it will be support, in present day servers.
> 
> So at this point if have we two of the three, the port and version, why
> not just use the default protocol (TCP) and do the NFS ping?

If a user has already gone to the trouble of specifying vers=3 and port=2049, why can't she simply add proto=tcp,mountproto=udp as well?  It seems to me we have an existing solution to this problem.

> The chances of the ping working are very high plus what is going to break?

What's going to break is users who have servers that listen only on UDP.  Suppose a user requests an NFS mount but specifies no mount options.  Our client will try to connect to those servers via TCP, and such servers will reply with RST.  Our client will then keep trying to connect via TCP, because it will think "RST" means "I'm still booting."  The mount request will eventually fail.  See the recent thread from Shehjar.

>> Doing the MNT request also performs an rpcbind query, but by default both 
>> of those are done via UDP.
> No. The query for the port were going over TCP. That's what caught
> my eye.

Sure, and I agree that bears some investigation.

NFSv2 and NFSv3 perform a MNT request first.  The associated rpcbind query and the MNT request should be done over UDP by default.  If these are not going over UDP by default, then we should change that (and that would be allowed because I believe that's the documented default behavior (he said, without checking)).  What exactly are the mount options used when an extra TCP connection appears?

>From memory, with a text-based mount, by default the kernel should do an rpcbind over UDP, then a MNT request over UDP, then an rpcbind over TCP, and finally a TCP connection to the NFS server; the first operation on the kernel's NFS socket should be NULL (ie, an NFS ping).  We can get rid of that second rpcbind right now by telling afflicted users to specify the NFS version, the transport protocols, and the NFS server port on the mount command line.

Does mount.nfs then also need to do an NFS ping?  That would simply add another TCP connection, which we are trying to avoid.  Plus... I think the change you proposed is for code that is nowadays only invoked during REnegotiation (ie the kernel mount request failed, and kicked it back to user space).  Does that help the automounter storm case?

>> The issue of keeping TCP port usage at a minimum is real and related to 
>> negotiation behavior, but is IMO separate.  My sense is that rpcbind 
>> queries are probably not really a big problem (and of course we would 
>> be wise to quantify this problem before making aggressive changes).
> I don't see this as an aggressive change. I see it as adapting the
> code to present day circumstances.
> 
>> mount.nfs's rpcbind queries should always come from an ephemeral port, 
>> which is a larger resource pool than privileged ports and thus more 
>> difficult to exhaust.  Using NFSv4 more, just by itself, should improve 
>> matters since it skips the rpcbind step by default and doesn't use MNT at all.
> All the above is true. But look at it from the server point of view. 
> During an automount storm, thousands of clients doing v3 mounts. This
> type of short cut will eliminate thousands of TCP the server will have
> to deal with.

The same effect is achieved if we have automounter users add "proto=tcp,mountproto=udp" to their mount command lines.  No code change is needed, and it's backwards compatible with our current negotiation strategy.

Negotiation is the common case, as mount.nfs should "just work" in as many cases as possible.  Automounter in large enterprises is a less frequent case, and one where it is entirely reasonable to tell folks to use more specific mount options to get the behavior they desire.  Changing mount.nfs's negotiation strategy at this point will just make some users (and possibly your test team) angry.

> steved.
> 
>> 
>>>> But we should be careful here: mount.nfs will do an rpcbind query if a port= 
>>>> was specified if there is also some doubt about whether to use TCP or UDP, 
>>>> or what NFS version is available.  The only time rpcbind queries should be 
>>>> completely squashed is when the mount parameters are specified completely 
>>>> (transport, version, and port).
>>> I agree with being careful here... But if some admin is specifying 
>>> a particular port I'm thinking one, they have a clue and two, 99% of 
>>> time the port is correct. So lets just verify the port by using it
>>> NFS ping. So I'm thinking %99 of the time there is no need to create 
>>> that second TCP connection when a port is specified.
>> 
>> I think the kernel already does an NFS ping during mount processing (someone should verify that, of course).  But as I said above, all three NFS parameters [transport, NFS version, and port] have to be specified to avoid the rpcbind query.
>> 
>>> But, here is were we have to be careful. That  1% of the
>>> time the ping fails, for whatever reason... That is when I think
>>> we to consult with the server's rpcbind and the second TCP
>>> connection is justified. 
>>> 
>>> I just thinking making that assuming the specified info
>>> is as good way to save a TCP connection... 
>> 
>> Hrm, I don't see what that buys us.  If the ping fails and the port specified on the mount command line is actually registered on the server, what is the client's recourse?
>> 
>>> 
>>>> 
>>>>> I'm thinking some code has to change in nfs_probe_port() 
>>>>> something like:
>>>>> 
>>>>>  mount.nfs: Do not send pmap inquire when port is specified
>>>>> 
>>>>>  When the port is specified on the command line do not
>>>>>  send a pmap inquire asking for the port. Instead use
>>>>>  the given port in the NFS ping. If the ping fails,
>>>>>  assume a bad port was given and now go ask the server
>>>>>  for the correct port.
>>>> 
>>>> If the server has more than one NFS port enabled, and the client is 
>>>> requesting a port that isn't registered with the server's rpcbind, it 
>>>> shouldn't fall back to the registered port IMO.
>>> True. With this patch there is no fall back. When the NFS ping fails, 
>>> the registered port is obtained; compared to the specified port.
>>> If they are different the mount will fail as it does to today.
>>> 
>>> steved.
>>> 
>>>> 
>>>>>  Signed-off-by: Steve Dickson <steved@redhat.com>
>>>>> 
>>>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>>>> index d1f91dc..405c320 100644
>>>>> --- a/utils/mount/network.c
>>>>> +++ b/utils/mount/network.c
>>>>> @@ -545,17 +545,18 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
>>>>> 	const unsigned int prot = (u_int)pmap->pm_prot, *p_prot;
>>>>> 	const u_short port = (u_short) pmap->pm_port;
>>>>> 	unsigned long vers = pmap->pm_vers;
>>>>> -	unsigned short p_port;
>>>>> +	unsigned short p_port = port;
>>>>> +	int once = 1;
>>>>> 
>>>>> 	memcpy(saddr, sap, salen);
>>>>> 	p_prot = prot ? &prot : protos;
>>>>> 	p_vers = vers ? &vers : versions;
>>>>> -
>>>>> 	for (;;) {
>>>>> 		if (verbose)
>>>>> 			printf(_("%s: prog %lu, trying vers=%lu, prot=%u\n"),
>>>>> 				progname, prog, *p_vers, *p_prot);
>>>>> -		p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
>>>>> +		if (!p_port)
>>>>> +			p_port = nfs_getport(saddr, salen, prog, *p_vers, *p_prot);
>>>>> 		if (p_port) {
>>>>> 			if (!port || port == p_port) {
>>>>> 				nfs_set_port(saddr, p_port);
>>>>> @@ -564,6 +565,15 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
>>>>> 				if (nfs_rpc_ping(saddr, salen, prog,
>>>>> 							*p_vers, *p_prot, NULL))
>>>>> 					goto out_ok;
>>>>> +				if (port == p_port && once) {
>>>>> +					/*
>>>>> +					 * Could be a bad port was specified. This
>>>>> +					 * time ask the server for the port but only
>>>>> +					 * do it once.
>>>>> +					 */
>>>>> +					p_port = once = 0;
>>>>> +					continue;
>>>>> +				}
>>>>> 			} else
>>>>> 				rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
>>>>> 		}
>>>>> @@ -589,6 +599,7 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
>>>>> 	}
>>>>> 
>>>>> 	nfs_pp_debug2("failed");
>>>>> 	return 0;
>>>>> 
>>>>> out_ok:
>>>>> 
>>>>> 
>>>>> I'm not sure this is best way either.... 
>>>>> 
>>>>> steved.
>>>>> 
>>>>> 
>>>>> 
>>>>> 
>>>>> 
>>>>> 
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> 
>> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




