Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:44236 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755146AbeBGVYE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Feb 2018 16:24:04 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87y3k4mrf8.fsf@notabene.neil.brown.name>
Date: Wed, 7 Feb 2018 16:23:53 -0500
Cc: Tom Talpey <tom@talpey.com>, Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <AFF64139-7DD6-4606-9142-B974FDA9C287@oracle.com>
References: <20180205163647.15822-1-steved@redhat.com>
 <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
 <cc08d8f9-795d-d49c-6354-f5fdbeb85a44@talpey.com>
 <87eflxo1qp.fsf@notabene.neil.brown.name>
 <4F3A3FBC-FFA9-4CDA-A38A-73AD07A62A27@oracle.com>
 <87y3k4mrf8.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 7, 2018, at 4:16 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Wed, Feb 07 2018, Chuck Lever wrote:
> 
>>> On Feb 6, 2018, at 11:35 PM, NeilBrown <neilb@suse.com> wrote:
>>> 
>>> On Mon, Feb 05 2018, Tom Talpey wrote:
>>> 
>>>> On 2/5/2018 12:02 PM, Chuck Lever wrote:
>>>>> Heya Steve-
>>>>> 
>>>>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>>> 
>>>>>> Over the weekend I did some experimenting with
>>>>>> the remote call code in rpcbind. The code does
>>>>>> functionally work but is very antiquated when
>>>>>> it comes to the latest NFS versions.
>>>>>> 
>>>>>> Since only UDP sockets are used to do remote calls
>>>>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>>>>> calls to NFS will fail (actual times out) since UDP is no
>>>>>> longer supported.
>>>>>> 
>>>>>> The undocumented interface rpc_call() can be used to
>>>>>> call into NFS since the protocol can specified, which
>>>>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>>>> 
>>>>>> It turns out privilege port are not needed to make
>>>>>> remote calls, at least with my testing.
>>>>> 
>>>>> It's not quite clear what you are claiming here, but
>>>>> I'm guessing that what you demonstrated is that the
>>>>> CALLIT _listener_ does not have to be privileged?
>>> 
>>> rpcbind listens for CALLIT on port 111.
>> 
>> Right, my bad. CALLIT is an RPC procedure, not an RPC
>> program.
>> 
>> 
>>> Listening on some other port wouldn't ever get the messges...
>> 
>> Then we still do not understand why rpcbind is opening
>> and registering a second listener port. I can't think of
>> any reason it should do this other than that there is a
>> bug.
> 
> This is a port on which it forwards CALLIT messages and listens for
> replies, which it then sends back to the originator.  In order to be
> able to handle CALLIT asynchronously with other requests, it needs to
> register the port with the internal listening framework.

Sorry, this is still not making sense to me. Can you create a
ladder diagram that shows the exchange of Call and Reply messages?


> For comparison, portmap handles CALLIT asynchronously by forking.
> 
> Thanks,
> NeilBrown

--
Chuck Lever



