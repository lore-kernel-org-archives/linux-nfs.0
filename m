Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:13598 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759194Ab3GRTtU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 15:49:20 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED: v4 proc -> opcodes mapping
Date: Thu, 18 Jul 2013 19:49:18 +0000
Message-ID: <9AC7EBEB-E407-4CCB-A6E6-05C24CD821DA@netapp.com>
References: <7EC48508-29F6-42DF-9BBA-F90A5CA1A47C@netapp.com>
 <1374159436.3788.3.camel@leira.trondhjem.org>
 <DFCAA8D0-B3BD-49C2-BAC4-9C26668AACB9@netapp.com>
 <1374160910.3788.14.camel@leira.trondhjem.org>
 <1D61D5F4-40DA-47D1-A15A-745EA05813BA@netapp.com>
 <1374167339.3788.52.camel@leira.trondhjem.org>
 <DD04268F-B364-48D0-ADEB-E4770D618B38@netapp.com>
In-Reply-To: <DD04268F-B364-48D0-ADEB-E4770D618B38@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only supporting operations that have the error code NFS4ERR_WRONG_CRED seems to be wrong.  Operations like BIND_CONN_TO_SESSION don't support don't support this error code, but are explicitly mentioned in SP4_MACH_CRED sections of the spec.

I'll continue my work described below modulo limiting to NFS4ERR_WRONG_CRED enabled OPs and see how that looks...

-dros

On Jul 18, 2013, at 2:13 PM, "Adamson, Dros" <Weston.Adamson@netapp.com> wrote:

> Ok, I'll have the client only ask for state protection on operations that support NFS4ERR_WRONG_CRED - and I'll do the SP4_MACH_CRED checks only on these operations and only if they aren't already using the machine cred already. This simplifies my original problem - now I can just use the "main" opcode.
> 
> I'll also add error handlers for NFS4ERR_WRONG_CRED.
> 
> Thanks!
> 
> -dros
> 
> On Jul 18, 2013, at 1:08 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
>> On Thu, 2013-07-18 at 15:50 +0000, Adamson, Dros wrote:
>>> On Jul 18, 2013, at 11:21 AM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
>>> wrote:
>>> 
>>>> On Thu, 2013-07-18 at 15:10 +0000, Adamson, Dros wrote:
>>>>> On Jul 18, 2013, at 10:57 AM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>>>> 
>>>>>> On Thu, 2013-07-18 at 14:46 +0000, Adamson, Dros wrote:
>>>>>>> Hey,
>>>>>>> 
>>>>>>> I have a mostly functional client-side implementation of SP4_MACH_CRED! It still needs a lot of cleanup and testing.
>>>>>>> 
>>>>>>> I have one style issue that I want to run by the list before I post a patchset:
>>>>>>> 
>>>>>>> So, SP4_MACH_CRED negotiates two bitmaps in the EXCHANGE_ID (one "enforce", one "allow") for state protection. These bitmaps are indexed by the NFSv4 operation number.  The state protect check must happen in the nfs4proc.c layer (or before), right before we call rpc_call_sync or equivalent, so that it can select the right cred and rpc_client.
>>>>>>> 
>>>>>>> Here's the problem: we don't know what operations (opcodes) are actually in a compound until the XDR encode callback is called.  The rpc_procinfo array doesn't have this mapping - in fact, it only lives in the xdr encode layer.
>>>>>>> 
>>>>>>> One approach is to immediately translate the opcode bitmaps to "nfs4 procedure index" bitmaps, indexing into the rpc_procinfo array.  This would mean there is a second mapping of NFSv4 procedure -> opcodes that must be updated when an XDR encode callback is changed.
>>>>>>> 
>>>>>>> Another approach would be to add a callback to the XDR api so we could "ask" it if an NFSv4 procedure contains any of the opcodes in a bitmap. The nice thing about this approach is that the mapping of procedure to opcodes within will live right next to the XDR encode callback and make it obvious that both need to be changed together.
>>>>>>> 
>>>>>>> I suppose I'm leaning toward a combination of both of these approaches - keep the mapping in XDR-land and translate the bitmaps immediately on negation for fast lookups during normal operation.
>>>>>>> 
>>>>>>> Comments? Am I missing something?
>>>>>> 
>>>>>> I'm not sure that I understand. We don't do dynamic creation of
>>>>>> compounds: we pretty much know in the nfs4_proc_* routine what the main
>>>>>> operation is (the one exception being CLOSE/OPEN_DOWNGRADE). So why
>>>>>> can't we work out the protection status at that time? Is the worry that
>>>>>> the server might reboot and come back with different MACH_CRED
>>>>>> protections?
>>>>> 
>>>>> Sure, we know what the main operation is and we know what operations will end up in a compound - we can just look at the xdr encoder.  My question is simply one of style. Do we want to have each nfs4proc procedure to have a list of operations that must be updated if an xdr encoder is updated? I'm fine with doing it this way, it just seemed wrong to have the same mapping in two different places. This is why I'm asking ;)
>>>>> 
>>>>> Also, we can't just use the "main" operation, we must check every operation within the compound and if any are required to use SP4, then the whole compound does. I don't necessarily know why a server would do this, but if we follow the spec and a server informs the client that SETATTR must use state protection, then a WRITE with post-op SETATTR must use the state protection even though WRITE doesn't need it.
>>>> 
>>>> We only need to check every _stateful_ operation, right? I can't think
>>>> of any compounds with more than 1 stateful operation. We've deliberately
>>>> avoided those due to the problems that arise when you get a
>>>> NFS4ERR_DELAY or something equivalent at the wrong moment.
>>> 
>>> That may be the intention, but I see no such limitation in the spec. It's my understanding that the server could specify any operation as MUST or MAY use state protection.
>> 
>> Right, but what would state protection mean for a stateless operation
>> such as GETATTR? That operation isn't even allowed to return
>> NFS4ERR_WRONG_CRED, so I don't see how it would apply.
>> 
>>>>> I'm not following the reboot question - that case should be handled just fine. Once the EXCHANGE_ID happens, the clp has two bitmaps (enforce and allow) that reflect the current mode of SP4_MACH_CRED.
>>>> 
>>>> I'm thinking something along the following scenario:
>>>> 
>>>> A process queues up an OPEN. The server replies NFS4ERR_BAD_SESSION and
>>>> later replies with NFS4ERR_STALE_CLIENTID. So we start reboot recovery,
>>>> and the OPEN gets queued waiting for a slot.
>>>> We then send a new EXCHANGE_ID, and the server replies with a
>>>> _different_ MACH_CRED protection for OPEN.
>>>> 
>>>> The problem above is that the OPEN has already been started, and we've
>>>> already assigned it a credential. How do we handle that?
>>>> Ditto question for READ, WRITE, LOCK, LAYOUTGET,...
>>>> 
>>>> Do we have a problem for LOCKU, CLOSE and OPEN_DOWNGRADE? I think we end
>>>> up just skipping recovery in those cases…
>>> 
>>> These are good points. I'm not sure *why* the sp4_mach_cred config would change, but I suppose it could, and yes, in my current implementation there is no way to back out once a rpc task is invoked.  Any thoughts on this?  I can see two ways of handling this:
>>> - restarting all tasks (with rpc_clnt and rpc_cred appropriately changed) when a change in sp4_mach_cred config is detected.
>>> - somehow having the RPC layer call out to check SP4 status before sending each RPC.
>> 
>> For now, I think we should make sure that we handle NFS4ERR_WRONG_CRED
>> correctly in these cases. I don't think we ever want to handle that in
>> nfs4_async_handle_error, but we should definitely handle it in
>> nfs4_handle_exception(), since that can drive a full retry of the RPC
>> call.
>> 
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>> 
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

