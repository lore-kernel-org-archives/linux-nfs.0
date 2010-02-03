Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:34891 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539Ab0BCWfr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Feb 2010 17:35:47 -0500
Message-ID: <4B69F9DE.10604@oracle.com>
Date: Wed, 03 Feb 2010 17:34:06 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: Neil Brown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/9] sunrpc: close connection when a request is irretrievably
 lost.
References: <20100203060657.12945.27293.stgit@notabene.brown>	<20100203063131.12945.34978.stgit@notabene.brown>	<4B699988.9000209@oracle.com> <20100204082354.0bf3b7e5@notabene.brown>
In-Reply-To: <20100204082354.0bf3b7e5@notabene.brown>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/03/2010 04:23 PM, Neil Brown wrote:
> On Wed, 03 Feb 2010 10:43:04 -0500
> Chuck Lever<chuck.lever@oracle.com>  wrote:
>
>> On 02/03/2010 01:31 AM, NeilBrown wrote:
>>> If we drop a request in the sunrpc layer, either due kmalloc failure,
>>> or due to a cache miss when we could not queue the request for later
>>> replay, then close the connection to encourage the client to retry sooner.
>>
>> I studied connection dropping behavior a few years back, and decided
>> that dropping the connection on a retransmit is nearly always
>> counterproductive.  Any other pending requests on a connection that is
>> dropped must also be retransmitted, which means one retransmit suddenly
>> turns into many.  And then you get into issues of idempotency and all
>> the extra traffic and the long delays and the risk of reconnecting on a
>> different port so that XID replay is undetectable...
>
> You make some good points there, thanks.
>
>>
>> I don't think dropping the connection will cause the client to
>> retransmit sooner.  Clients I have encountered will reconnect and
>> retransmit only after their retransmit timeout fires, never sooner.
>>
>
> I thought I had noticed the Linux client resending immediately, but it would
> have been a while ago, and I could easily be remembering wrongly.
>
> My reasoning was that if the connection is closed then the client can *know*
> that they won't get a response to any outstanding requests, rather than
> having to use the timeout heuristic.  How the client uses that information I
> don't know, but at least they would have it.

So, I seem to remember expecting that behavior, and then being 
disappointed when it didn't work that way :-)

It's also the case that there is some pathological behavior around 
reconnect in some of the older 2.6 NFS clients.  Trond would probably 
remember the details there.

In any event, I think you would do well to make some direct observations 
with several different vintages of Linux NFS clients, just to be sure 
this works as you expect it to with reasonable clients.

I noticed that connection drops are especially onerous when a server is 
under load, and that's exactly when drops seem to occur most often. It's 
one of those corner cases that's nearly impossible to test well.

>> Unfortunately NFSv4 requires a connection drop before a retransmit, but
>> NFSv3 does not.  NFSv4 servers are rather supposed to try very hard not
>> to drop requests.
>>
>> How often do you expect this kind of recovery to be necessary?  Would it
>> be possible to drop only for NFSv4 connections?
>>
>
> With the improved handling of large requests I would expect this kind of
> recovery would be very rarely needed.
>
> Yes, it would be quite easy to only drop connections on which we have seen an
> NFSv4 request... and maybe also connections on which we have not successfully
> handled any request yet(?).
> What if, instead of closing the connection, we set a flag so that it would be
> closed as soon as it had been idle for 1 second,  thus flushing any other
> pending requests???   That probably doesn't help - there would easily be real
> cases where other threads of activity keep the connection busy, while the
> thread waiting for the lost request still needs a full time-out.
>
> I would be happy with the v4-only version.

v4 would almost be required to work this way, I think.  I wouldn't 
object to a v4-only implementation for now.

I'm sure there are cases where v3 will have to drop the connection... 
i'd just like to ensure that's it's absolutely a last resort.

-- 
chuck[dot]lever[at]oracle[dot]com
