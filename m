Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5496 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754625Ab3GRPKB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 11:10:01 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED: v4 proc -> opcodes mapping
Date: Thu, 18 Jul 2013 15:10:00 +0000
Message-ID: <DFCAA8D0-B3BD-49C2-BAC4-9C26668AACB9@netapp.com>
References: <7EC48508-29F6-42DF-9BBA-F90A5CA1A47C@netapp.com>
 <1374159436.3788.3.camel@leira.trondhjem.org>
In-Reply-To: <1374159436.3788.3.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 18, 2013, at 10:57 AM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-07-18 at 14:46 +0000, Adamson, Dros wrote:
>> Hey,
>> 
>> I have a mostly functional client-side implementation of SP4_MACH_CRED! It still needs a lot of cleanup and testing.
>> 
>> I have one style issue that I want to run by the list before I post a patchset:
>> 
>> So, SP4_MACH_CRED negotiates two bitmaps in the EXCHANGE_ID (one "enforce", one "allow") for state protection. These bitmaps are indexed by the NFSv4 operation number.  The state protect check must happen in the nfs4proc.c layer (or before), right before we call rpc_call_sync or equivalent, so that it can select the right cred and rpc_client.
>> 
>> Here's the problem: we don't know what operations (opcodes) are actually in a compound until the XDR encode callback is called.  The rpc_procinfo array doesn't have this mapping - in fact, it only lives in the xdr encode layer.
>> 
>> One approach is to immediately translate the opcode bitmaps to "nfs4 procedure index" bitmaps, indexing into the rpc_procinfo array.  This would mean there is a second mapping of NFSv4 procedure -> opcodes that must be updated when an XDR encode callback is changed.
>> 
>> Another approach would be to add a callback to the XDR api so we could "ask" it if an NFSv4 procedure contains any of the opcodes in a bitmap. The nice thing about this approach is that the mapping of procedure to opcodes within will live right next to the XDR encode callback and make it obvious that both need to be changed together.
>> 
>> I suppose I'm leaning toward a combination of both of these approaches - keep the mapping in XDR-land and translate the bitmaps immediately on negation for fast lookups during normal operation.
>> 
>> Comments? Am I missing something?
> 
> I'm not sure that I understand. We don't do dynamic creation of
> compounds: we pretty much know in the nfs4_proc_* routine what the main
> operation is (the one exception being CLOSE/OPEN_DOWNGRADE). So why
> can't we work out the protection status at that time? Is the worry that
> the server might reboot and come back with different MACH_CRED
> protections?

Sure, we know what the main operation is and we know what operations will end up in a compound - we can just look at the xdr encoder.  My question is simply one of style. Do we want to have each nfs4proc procedure to have a list of operations that must be updated if an xdr encoder is updated? I'm fine with doing it this way, it just seemed wrong to have the same mapping in two different places. This is why I'm asking ;)

Also, we can't just use the "main" operation, we must check every operation within the compound and if any are required to use SP4, then the whole compound does. I don't necessarily know why a server would do this, but if we follow the spec and a server informs the client that SETATTR must use state protection, then a WRITE with post-op SETATTR must use the state protection even though WRITE doesn't need it.

I'm not following the reboot question - that case should be handled just fine. Once the EXCHANGE_ID happens, the clp has two bitmaps (enforce and allow) that reflect the current mode of SP4_MACH_CRED.

-dros