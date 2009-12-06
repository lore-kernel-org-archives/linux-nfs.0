From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Sat, 05 Dec 2009 19:28:33 -0800
Message-ID: <C74064E1.1099E%ricardo.labiaga@netapp.com>
References: <C7406418.1099B%ricardo.labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: William Adamson <William.Adamson@netapp.com>,
	<linux-nfs@vger.kernel.org>
To: Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50755 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756123AbZLFD22 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 22:28:28 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB63SYVe027169
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 19:28:34 -0800 (PST)
In-Reply-To: <C7406418.1099B%ricardo.labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/5/09 7:25 PM, "Ricardo Labiaga" <ricardo.labiaga@netapp.com> wrote:

> These patches due improve the situation.  I still see a number of sequence
                ^^^
                 do

(apologies for the spam, but better be clear...)

- ricardo

> calls with sessionID=0 and the same sequenceID that triggered the initial
> BADSESSION.  It does recover after the session is fully established though.
> 
> The sequenceID's with sessionID=0 are generated because nfs4_reset_session()
> clears the DRAINING flag and wakes the pending RPCs even on error.  This is
> broken, since we don't have a valid sessionID.  Since we're already in the
> state manager, why not just let the state manager retry if the error is
> recoverable (such as STALE_CLIENTID)?
> 
> I'll give that a try after dinner :-)
> 
> - ricardo
> 
> 
> 
> On 12/5/09 4:34 PM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> 
>> On Sat, 2009-12-05 at 13:42 -0800, Labiaga, Ricardo wrote:
>>> 
>>> 
>>> On 12/5/09 1:39 PM, "Ricardo Labiaga" <ricardo.labiaga@netapp.com> wrote:
>>> 
>>>> On 12/5/09 1:12 PM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
>>>> 
>>>>> On Sat, 2009-12-05 at 12:55 -0800, Labiaga, Ricardo wrote:
>>>>>> Tried with this patch but it didn't make a difference.
>>>>> 
>>>>> You are still seeing RPC calls with 0 session ids?
>>>>> 
>>>> 
>>>> Yes, right after the session is destroyed, and before it's recreated.  The
>>>> original RPC that got the BAD_SESSION error keeps on trying.
>>>> 
>>> 
>>> I should clarify.  It's not a retransmission, the client issues the same
>>> compound with a new XID.
>>> 
>>> - ricardo
>>> 
>>>> After the session is recreated, the same RPC is issued (with the same
>>>> sequenceID) but with the new sessionID.  This time it fails with
>>>> SEQ_MISORDERED.  This repeats indefinitely until the process is manually
>>>> interrupted.
>>>> 
>>>>>>   I haven't tried applying the second cleanup patch yet since it
>>>>>> didn't apply cleanly on top of nfs-for-next.  Is this the branch you
>>>>>> used?
>>>>> 
>>>>> I've pushed out all patches (including the cleanup patch) onto
>>>>> nfs-for-next now...
>>>>> 
>>>> 
>>>> Got it, I was able to apply both patches.  The results above are with both
>>>> patches.
>> 
>> I've found some other interesting session reset cases. I've coded up
>> some fixes, and pushed them to the nfs-for-next tree.
>> 
>> In particular, please see
>>   
>> 
http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git&a=commitdiff&h=f26468fb9384e7>>
3
>> fb357d2e84d3e9c88c7d1129d
>> which should ensure that we always reinitialise the slot sequence number
>> after a server reboot.
>> 
>> Could you please see if that in any way changes the above behaviour?
>> 
>> Cheers
>>   Trond
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

