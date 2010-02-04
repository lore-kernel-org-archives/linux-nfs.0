Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:45906 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757881Ab0BDAHw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Feb 2010 19:07:52 -0500
Message-ID: <4B6A0F7A.3090600@oracle.com>
Date: Wed, 03 Feb 2010 19:06:18 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/9] sunrpc: close connection when a request is irretrievably
 lost.
References: <20100203060657.12945.27293.stgit@notabene.brown>	 <20100203063131.12945.34978.stgit@notabene.brown>	 <4B699988.9000209@oracle.com>  <20100204082354.0bf3b7e5@notabene.brown>	 <1265235610.5217.21.camel@localhost>  <4B69FB62.2090908@oracle.com> <1265238838.2632.7.camel@localhost>
In-Reply-To: <1265238838.2632.7.camel@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/03/2010 06:13 PM, Trond Myklebust wrote:
> On Wed, 2010-02-03 at 17:40 -0500, Chuck Lever wrote:
>> On 02/03/2010 05:20 PM, Trond Myklebust wrote:
>>> On Thu, 2010-02-04 at 08:23 +1100, Neil Brown wrote:
>>>> On Wed, 03 Feb 2010 10:43:04 -0500
>>>> Chuck Lever<chuck.lever@oracle.com>   wrote:
>>>>>
>>>>> I don't think dropping the connection will cause the client to
>>>>> retransmit sooner.  Clients I have encountered will reconnect and
>>>>> retransmit only after their retransmit timeout fires, never sooner.
>>>>>
>>>>
>>>> I thought I had noticed the Linux client resending immediately, but it would
>>>> have been a while ago, and I could easily be remembering wrongly.
>>>
>>> It depends on who closes the connection.
>>>
>>> The client assumes that if the _server_ closes the connection, then it
>>> may be having resource congestion issues. In order to give the server
>>> time to recover, the client will delay reconnecting for 3 seconds (with
>>> an exponential back off).
>>   >
>>> If, on the other hand, the client was the one that initiated the
>>> connection closure, then it will try to reconnect immediately.
>>
>> That's only if there are RPC requests immediately ready to send, though,
>> right?  A request that is waiting for a reply when the connection is
>> dropped wouldn't be resent until its retransmit timer expired, I thought.
>
> No, that is incorrect.
>
> We call xprt_wake_pending_tasks() both when the connection is closed,
> and when it is re-established: see the details in
> xs_tcp_state_change().
>
> It doesn't make sense for the client to defer resending requests when it
> knows that the original connection was lost. Deferring would simply mean
> that the chances of the server evicting the reply from its DRC will
> increase.

True, thanks for clarifying.

My only concern would be that we perhaps should not assume that every 
2.6 NFS client does this.  There was an awful lot of churn at one point 
as you were getting all of these ducks in a row.  Before you changed the 
underlying RPC transports to return only ENOTCONN, for instance, was 
this behavior the same?  I wouldn't swear to it in the 2.6.7 - .9 
vintage kernels.

-- 
chuck[dot]lever[at]oracle[dot]com
