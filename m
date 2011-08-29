Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751527Ab1H2OAf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 10:00:35 -0400
Message-ID: <4E5B9B63.50105@RedHat.com>
Date: Mon, 29 Aug 2011 10:00:03 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Luk Claes <luk@debian.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mount.nfs: Preserve any explicit port=2049 option
References: <1312625496-2496-1-git-send-email-luk@debian.org> <4E56AFCB.2020803@RedHat.com> <F4AA6B6E-D029-47BC-A710-23A7AE2582A8@oracle.com> <4E56ED9D.7020906@RedHat.com> <4D7CDC73-5EF0-438E-98B5-32B06730B5B6@oracle.com> <4E58E97F.7040006@RedHat.com> <2491A23F-8C69-4A5D-8D60-9E0A84DBF63E@oracle.com>
In-Reply-To: <2491A23F-8C69-4A5D-8D60-9E0A84DBF63E@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/27/2011 07:45 PM, Chuck Lever wrote:
> 
> On Aug 27, 2011, at 8:56 AM, Steve Dickson wrote:
> 
>> Hey,
>>
>> On 08/26/2011 09:58 AM, Chuck Lever wrote:
>>>
>>> On Aug 25, 2011, at 8:49 PM, Steve Dickson wrote:
>>>
>>>> On 08/25/2011 04:46 PM, Chuck Lever wrote:
>>>>>
>>>>> On Aug 25, 2011, at 4:25 PM, Steve Dickson wrote:
>>>>>
>>>>>> First of all let me apologize for taking so long
>>>>>> to get to this... I did take some time off.... 
>>>>>>
>>>>>> On 08/06/2011 06:11 AM, Luk Claes wrote:
>>>>>>> If NFS port (2049) is supplied explicitly, don't ignore this setting by requesting it to portmapper again. Thanks to Ben Hutchings <ben@decadent.org.uk> for the patch.
>>>>>>>
>>>>>>> Signed-off-by: Luk Claes <luk@debian.org>
>>>>>>> ---
>>>>>>> utils/mount/stropts.c |    4 ++--
>>>>>>> 1 files changed, 2 insertions(+), 2 deletions(-)
>>>>>>>
>>>>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>>>>> index f1aa503..8b2799c 100644
>>>>>>> --- a/utils/mount/stropts.c
>>>>>>> +++ b/utils/mount/stropts.c
>>>>>>> @@ -437,8 +437,8 @@ static int nfs_construct_new_options(struct mount_options *options,
>>>>>>> 	if (po_append(options, new_option) == PO_FAILED)
>>>>>>> 		return 0;
>>>>>>>
>>>>>>> -	po_remove_all(options, "port");
>>>>>>> -	if (nfs_pmap->pm_port != NFS_PORT) {
>>>>>>> +	if(po_remove_all(options, "port") == PO_FOUND ||
>>>>>>> +	   nfs_pmap->pm_port != NFS_PORT) {
>>>>>>> 		snprintf(new_option, sizeof(new_option) - 1,
>>>>>>> 			 "port=%lu", nfs_pmap->pm_port);
>>>>>>> 		if (po_append(options, new_option) == PO_FAILED)
>>>>>> Now I like the idea of not sending the pmap inquire for the 
>>>>>> port when the port is specified on the command because its
>>>>>> a TCP connection. During automount storms, wasting TCP connections
>>>>>> is not a good thing... 
>>>>>>
>>>>>> But your patch does not seem to do that since all the port
>>>>>> negotiation is done well before this part of the code.
>>>>>
>>>>> I thought the idea was to eliminate the port query during REnegotiation
>>>>> if "port=" was specified.  That seems like exactly what the patch does.  
>>>> Ah, I did miss the renegotiation aspect... Its been a long day... ;-)
>>>>
>>>>> Does the initial port negotiation also have this problem?
>>>> Well I was thinking why even do the initial port negotiation when
>>>> the port= is set... 
>>>
>>> An rpcbind query is still needed if port= is specified but transport or 
>>> version options were not. Simply specifying port= does not shut off 
>>> negotiation. 
>> You are correct. Not only is the port specified but the version is also
>> specified as well due to the fact we are in this part of the code. 
>>
>>> All three NFS parameters have to be specified to shut off the rpcbind query.
>> Why is this such a hard and fast rule?
> 
> If we change mount.nfs to go straight to TCP, then it will break mounting servers that support only UDP, when default mount options are used.
First of all, this part of the code is not even used with
the default mount options.

Secondly, mounts don't work now with UDP only servers. Since ECONNREFUSED 
is deemed a temporary error, so the mount just spins in the v4 code. 
So a -o v3 has to be used with these types of servers.

And as far as my patch breaking mount to UDP only servers,
that not accurate either. The first TCP connection is refused
then the normal negotiation kicks in. 

> 
>> Maybe in the past, when we moved from v2 to v3 and from UDP to TCP, all 
>> three were needed but not in day in aged. TCP is now a mandated protocol,
>> which almost guarantees it will be support, in present day servers.
>>
>> So at this point if have we two of the three, the port and version, why
>> not just use the default protocol (TCP) and do the NFS ping?
> 
> If a user has already gone to the trouble of specifying vers=3 and port=2049, why can't she simply add proto=tcp,mountproto=udp as well?  
Remember v3 can be specified from the /etc/nfsmount.conf file as well.

> 
>> The chances of the ping working are very high plus what is going to break?
> 
> What's going to break is users who have servers that listen only on UDP.  Suppose a user requests an NFS mount but specifies no mount options.  Our client will try to connect to those servers via TCP, and such servers will reply with RST.  Our client will then keep trying to connect via TCP, because it will think "RST" means "I'm still booting."  The mount request will eventually fail.  See the recent thread from Shehjar.
Again this is not accurate... Please see above. 

> 
>>> Doing the MNT request also performs an rpcbind query, but by default both 
>>> of those are done via UDP.
>> No. The query for the port were going over TCP. That's what caught
>> my eye.
> 
> Sure, and I agree that bears some investigation.
> 
> NFSv2 and NFSv3 perform a MNT request first.  The associated rpcbind query and the MNT request should be done over UDP by default.  If these are not going over UDP by default, then we should change that (and that would be allowed because I believe that's the documented default behavior (he said, without checking)).  What exactly are the mount options used when an extra TCP connection appears?
> 
> From memory, with a text-based mount, by default the kernel should do an rpcbind over UDP, then a MNT request over UDP, then an rpcbind over TCP, and finally a TCP connection to the NFS server; the first operation on the kernel's NFS socket should be NULL (ie, an NFS ping).  We can get rid of that second rpcbind right now by telling afflicted users to specify the NFS version, the transport protocols, and the NFS server port on the mount command line.
> 
> Does mount.nfs then also need to do an NFS ping?  That would simply add another TCP connection, which we are trying to avoid.  Plus... I think the change you proposed is for code that is nowadays only invoked during REnegotiation (ie the kernel mount request failed, and kicked it back to user space).  Does that help the automounter storm case?
> 
>>> The issue of keeping TCP port usage at a minimum is real and related to 
>>> negotiation behavior, but is IMO separate.  My sense is that rpcbind 
>>> queries are probably not really a big problem (and of course we would 
>>> be wise to quantify this problem before making aggressive changes).
>> I don't see this as an aggressive change. I see it as adapting the
>> code to present day circumstances.
>>
>>> mount.nfs's rpcbind queries should always come from an ephemeral port, 
>>> which is a larger resource pool than privileged ports and thus more 
>>> difficult to exhaust.  Using NFSv4 more, just by itself, should improve 
>>> matters since it skips the rpcbind step by default and doesn't use MNT at all.
>> All the above is true. But look at it from the server point of view. 
>> During an automount storm, thousands of clients doing v3 mounts. This
>> type of short cut will eliminate thousands of TCP the server will have
>> to deal with.
> 
> The same effect is achieved if we have automounter users add "proto=tcp,mountproto=udp" to their mount command lines.  No code change is needed, and it's backwards compatible with our current negotiation strategy.
> 
> Negotiation is the common case, as mount.nfs should "just work" in as many cases as possible.  Automounter in large enterprises is a less frequent case, and one where it is entirely reasonable to tell folks to use more specific mount options to get the behavior they desire.  Changing mount.nfs's negotiation strategy at this point will just make some users (and possibly your test team) angry.
This is getting a bit blown out of portion... IMHO... This is just
a small tweak that will save the need for one TCP connection by
making an assumption that TCP is default protocol... Not a 
big deal... 

I have to move on...


steved.


