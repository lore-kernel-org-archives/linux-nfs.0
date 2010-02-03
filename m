Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:16907 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015Ab0BCWmC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Feb 2010 17:42:02 -0500
Message-ID: <4B69FB62.2090908@oracle.com>
Date: Wed, 03 Feb 2010 17:40:34 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/9] sunrpc: close connection when a request is irretrievably
 lost.
References: <20100203060657.12945.27293.stgit@notabene.brown>	 <20100203063131.12945.34978.stgit@notabene.brown>	 <4B699988.9000209@oracle.com>  <20100204082354.0bf3b7e5@notabene.brown> <1265235610.5217.21.camel@localhost>
In-Reply-To: <1265235610.5217.21.camel@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/03/2010 05:20 PM, Trond Myklebust wrote:
> On Thu, 2010-02-04 at 08:23 +1100, Neil Brown wrote:
>> On Wed, 03 Feb 2010 10:43:04 -0500
>> Chuck Lever<chuck.lever@oracle.com>  wrote:
>>>
>>> I don't think dropping the connection will cause the client to
>>> retransmit sooner.  Clients I have encountered will reconnect and
>>> retransmit only after their retransmit timeout fires, never sooner.
>>>
>>
>> I thought I had noticed the Linux client resending immediately, but it would
>> have been a while ago, and I could easily be remembering wrongly.
>
> It depends on who closes the connection.
>
> The client assumes that if the _server_ closes the connection, then it
> may be having resource congestion issues. In order to give the server
> time to recover, the client will delay reconnecting for 3 seconds (with
> an exponential back off).
 >
> If, on the other hand, the client was the one that initiated the
> connection closure, then it will try to reconnect immediately.

That's only if there are RPC requests immediately ready to send, though, 
right?  A request that is waiting for a reply when the connection is 
dropped wouldn't be resent until its retransmit timer expired, I thought.

And, this behavior is true only for late-model clients... some of the 
eariler 2.6 clients have some trouble with this scenario, I seem to recall.

-- 
chuck[dot]lever[at]oracle[dot]com
