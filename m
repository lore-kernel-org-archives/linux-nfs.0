From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind registrations.
Date: Thu, 11 Jun 2009 11:02:27 -0400
Message-ID: <780B2BBF-9C0A-4E99-AC60-739FB509F61B@oracle.com>
References: <20090528062730.15937.70579.stgit@notabene.brown> <20090528063303.15937.62423.stgit@notabene.brown> <4a1e8c9e.48c3f10a.6d51.4c33@mx.google.com> <18992.36038.267957.467326@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>, Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:44165 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbZFKPCg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2009 11:02:36 -0400
In-Reply-To: <18992.36038.267957.467326-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 11, 2009, at 12:49 AM, Neil Brown wrote:
> On Thursday May 28, tmtalpey@gmail.com wrote:
>> At 02:33 AM 5/28/2009, NeilBrown wrote:
>>> Unregistering an RPC service is not essential - but it is tidy.
>>> So it is unpleasant to wait a long time for it to complete.
>>>
>>> As unregistering is always directed to localhost, the most likely
>>> reason for any delay is the portmap (or rpcbind) is not running.
>>> In that case, waiting it totally pointless.  In any case, we should
>>> expect a quick response, and zero packet loss.
>>>
>>> So reduce the timeouts to a total of half a second.
>>
>> Why wait for the response at all in this case? With zero retries
>> and nothing to do with the result, it seems pointless to even wait
>> for half a second.
>
> That's a fair point, thanks.  I'll keep that in mind if I revisit
> these patches.

While not waiting is probably OK in the "shutdown" case, it could be a  
problem during normal operation.  The kernel unregisters RPC services  
before it attempts to register them (to clear any old registrations).   
Not waiting for the unregister reply might be racy.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
