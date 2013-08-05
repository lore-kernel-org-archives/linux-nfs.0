Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:48788 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753927Ab3HEOoh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Aug 2013 10:44:37 -0400
Message-ID: <51FFBA52.8070008@netapp.com>
Date: Mon, 5 Aug 2013 10:44:34 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Ric Wheeler <rwheeler@redhat.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 4/5] NFSD: Defer copying
References: <1374267830-30154-1-git-send-email-bjschuma@netapp.com> <1374267830-30154-5-git-send-email-bjschuma@netapp.com> <20130722185002.GB10109@fieldses.org> <51ED8549.3040308@netapp.com> <20130722193000.GD10109@fieldses.org> <51ED89DC.7050406@netapp.com> <20130722194331.GF10109@fieldses.org> <51ED8DD8.1060703@netapp.com> <20130722195556.GG10109@fieldses.org> <51FF647C.3020704@redhat.com> <20130805144127.GA31169@fieldses.org>
In-Reply-To: <20130805144127.GA31169@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/05/2013 10:41 AM, J. Bruce Fields wrote:
> On Mon, Aug 05, 2013 at 09:38:20AM +0100, Ric Wheeler wrote:
>> On 07/22/2013 08:55 PM, J. Bruce Fields wrote:
>>> On Mon, Jul 22, 2013 at 03:54:00PM -0400, Bryan Schumaker wrote:
>>>> On 07/22/2013 03:43 PM, J. Bruce Fields wrote:
>>>>> On Mon, Jul 22, 2013 at 03:37:00PM -0400, Bryan Schumaker wrote:
>>>>>> On 07/22/2013 03:30 PM, J. Bruce Fields wrote:
>>>>>>> On Mon, Jul 22, 2013 at 03:17:29PM -0400, Bryan Schumaker wrote:
>>>>>>>> On 07/22/2013 02:50 PM, J. Bruce Fields wrote:
>>>>>>>>> On Fri, Jul 19, 2013 at 05:03:49PM -0400, bjschuma@netapp.com wrote:
>>>>>>>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>>>>>>>>
>>>>>>>>>> Rather than performing the copy right away, schedule it to run later and
>>>>>>>>>> reply to the client.  Later, send a callback to notify the client that
>>>>>>>>>> the copy has finished.
>>>>>>>>> I believe you need to implement the referring triple support described
>>>>>>>>> in http://tools.ietf.org/html/rfc5661#section-2.10.6.3 to fix the race
>>>>>>>>> described in
>>>>>>>>> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-19#section-15.1.3
>>>>>>>>> .
>>>>>>>> I'll re-read and re-write.
>>>>>>>>
>>>>>>>>> I see cb_delay initialized below, but not otherwise used.  Am I missing
>>>>>>>>> anything?
>>>>>>>> Whoops!  I was using that earlier to try to fake up a callback, but I eventually decided it's easier to just do the copy asynchronously.  I must have forgotten to take it out :(
>>>>>>>>
>>>>>>>>> What about OFFLOAD_STATUS and OFFLOAD_ABORT?
>>>>>>>> I haven't thought out those too much... I haven't thought about a use for them on the client yet.
>>>>>>> If it might be a long-running copy, I assume the client needs the
>>>>>>> ability to abort if the caller is killed.
>>>>>>>
>>>>>>> (Dumb question: what happens on the network partition?  Does the server
>>>>>>> abort the copy when it expires the client state?)
>>>>>>>
>>>>>>> In any case,
>>>>>>> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-19#section-15.1.3
>>>>>>> says "If a server's COPY operation returns a stateid, then the server
>>>>>>> MUST also support these operations: CB_OFFLOAD, OFFLOAD_ABORT, and
>>>>>>> OFFLOAD_STATUS."
>>>>>>>
>>>>>>> So even if we've no use for them on the client then we still need to
>>>>>>> implement them (and probably just write a basic pynfs test).  Either
>>>>>>> that or update the spec.
>>>>>> Fair enough.  I'll think it out and do something!  Easy solution: save this patch for later and only support the sync version of copy for the final version of this patch series.
>>>>> I can't remember--does the spec give the server a clear way to bail out
>>>>> and tell the client to fall back on a normal copy in cases where the
>>>>> server knows the copy could take an unreasonable amount of time?
>>>>>
>>>>> --b.
>>>> I don't think so.  Is there ever a case where copying over the network would be slower than copying on the server?
>>> Mybe not, but if the copy will take a minute, then we don't want to tie
>>> up an rpc slot for a minute.
>>>
>>> --b.
>>
>> I think that we need to be able to handle copies that would take a
>> lot longer than just a minute - this offload could take a very long
>> time I assume depending on the size of the data getting copied and
>> the back end storage device....
> 
> Bryan suggested in offline discussion that one possibility might be to
> copy, say, at most a gigabyte at a time before returning and making the
> client continue the copy.
> 
> Where for "a gigabyte" read, "some amount that doesn't take too long to
> copy but is still enough to allow close to full bandwidth".  Hopefully
> that's an easy number to find.
> 
> But based on
> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-19#section-14.1.2
> the COPY operation isn't designed for that--it doesn't give the option
> of returning bytes_copied in the successful case.

Wouldn't the wr_count field in a write_response4 struct be the bytes copied?  I'm working on a patch for puting a limit on the amount copied - is there a "1 gigabyte in bytes" constant somewhere?

- Bryan

> 
> Maybe we should fix that in the spec, or maybe we just need to implement
> the asynchronous case.  I guess it depends on which is easier,
> 
> 	a) implementing the asynchronous case (and the referring-triple
> 	   support to fix the COPY/callback races), or
> 	b) implementing this sort of "short copy" loop in a way that gives
> 	   good performance.
> 
> On the client side it's clearly a) since you're forced to handle that
> case anyway.  (Unless we argue that *all* copies should work that way,
> and that the spec should ditch the asynchronous case.) On the server
> side, b) looks easier.
> 
> --b.
> 

