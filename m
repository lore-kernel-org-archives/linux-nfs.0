From: Peter Staubach <staubach@redhat.com>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Fri, 08 Feb 2008 13:16:17 -0500
Message-ID: <47AC9C71.4090306@redhat.com>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com> <1202483596.8914.13.camel@heimdal.trondhjem.org> <47AC77C6.80503@redhat.com> <4B54CC40-B164-4B8D-A5D7-74CE2B684955@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56347 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760271AbYBHSQy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 13:16:54 -0500
In-Reply-To: <4B54CC40-B164-4B8D-A5D7-74CE2B684955@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Feb 8, 2008, at 10:39 AM, Peter Staubach wrote:
>> Trond Myklebust wrote:
>>> On Fri, 2008-02-08 at 10:04 -0500, Jeff Layton wrote:
>>>
>>>> Recently, I ran across a server-side bug that caused the server to 
>>>> send
>>>> truncated READDIR replies. The server would send a valid RPC 
>>>> response to
>>>> a READDIR call, but the contents of it were basically missing
>>>> (everything after the status).
>>>>
>>>> The server problem had long been patched in mainline kernels, but the
>>>> interesting bit was that clients didn't return an error in this
>>>> situation. The XDR decoders for readdir calls are supposed to check 
>>>> the
>>>> validity of the response, but in this situation it just fudges the
>>>> contents of the pagecache to make it look like a completely empty
>>>> directory.
>>>>
>>>> Shouldn't the client return an error in this situation? The response
>>>> obviously isn't valid so it seems like it shouldn't pretend that it 
>>>> is.
>>>> If so, would something like the following patch make sense?
>>>>
>>>
>>> It is quite valid (though silly!) for a server to return a READDIR 
>>> reply
>>> with no entries. AFAICR there were servers that actually did this at 
>>> one
>>> point (though I shall refrain from naming and shaming).
>>>
>>> So whereas I agree that it might be correct to flag a READDIR reply 
>>> that
>>> contains no entries due to XDR encoding bugs, I'm not sure that we
>>> should be flagging errors in the case where the XDR is correct.
>>
>> In this case, I believe that the response was malformed.  Pretty
>> much everything after the status was missing, including the EOF
>> indicator.  I would agree that it would be silly to return a
>> response with no error indicated, no entries, and the eof
>> indication set to false.
>>
>> This really boils down to how do we handle malformed responses?
>> Is there a general policy to retransmit the request?  This would
>> seem to be the right thing because a malformed response would
>> result from many things including the TCP connection getting
>> dropped in the middle of receiving the response from a timeout
>> and other things.  However, in this situation, retransmitting
>> the request would just have resulted in the same, broken response
>> from the server.  This was due to a server bug, which has since
>> been fixed, but exists still out in nature.
>
>
> Replies that are malformed network or RPC level packets are dropped by 
> the RPC client, and the matching requests are retransmitted by the RPC 
> client after a timeout.  Network events (like your TCP connection 
> example) result in a malformed RPC level packet that the RPC client 
> never delivers to the XDR layer, and are thus retransmitted by the RPC 
> client.
>
> Replies that have malformed XDR are treated by the NFS client as 
> errors.  The problem is the decoders (on Linux) are not terribly 
> careful about checking the correctness of the server's XDR encoding, 
> especially in cases like READDIR (Not to mention compound RPCs!) where 
> the decoding can be complex.  Olaf has mentioned the Linux XDR layer 
> was hand-coded rather than constructed with rpcgen to keep the 
> decoders simple and efficient.
>
> Network-related corruption is likely to be caught by the lower 
> layers.  I tend to think that malformed XDR is nearly always a genuine 
> software defect on the server, and thus not worth retransmitting 
> (especially if it's an idempotent request!). 

What happens if a response is interrupted in the middle by the
TCP connection being broken?  Is this caught at the RPC layer
and then rejected?

    Thanx...

       ps
