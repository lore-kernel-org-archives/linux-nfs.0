Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17369 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750807AbeBETqd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Feb 2018 14:46:33 -0500
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
To: Tom Talpey <tom@talpey.com>, Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180205163647.15822-1-steved@redhat.com>
 <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
 <cc08d8f9-795d-d49c-6354-f5fdbeb85a44@talpey.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <048e4908-d045-24fd-00b8-ebed7007974f@RedHat.com>
Date: Mon, 5 Feb 2018 14:46:31 -0500
MIME-Version: 1.0
In-Reply-To: <cc08d8f9-795d-d49c-6354-f5fdbeb85a44@talpey.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/2018 12:09 PM, Tom Talpey wrote:
> On 2/5/2018 12:02 PM, Chuck Lever wrote:
>> Heya Steve-
>>
>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> wrote:
>>>
>>> Over the weekend I did some experimenting with
>>> the remote call code in rpcbind. The code does
>>> functionally work but is very antiquated when
>>> it comes to the latest NFS versions.
>>>
>>> Since only UDP sockets are used to do remote calls
>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>> calls to NFS will fail (actual times out) since UDP is no
>>> longer supported.
>>>
>>> The undocumented interface rpc_call() can be used to
>>> call into NFS since the protocol can specified, which
>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>
>>> It turns out privilege port are not needed to make
>>> remote calls, at least with my testing.
>>
>> It's not quite clear what you are claiming here, but
>> I'm guessing that what you demonstrated is that the
>> CALLIT _listener_ does not have to be privileged?
>>
>> I claim that is true for all RPC listeners.
> 
> 
> Why in the world is the remote-call interface even still supported?
> It is and was a mammoth security hole allowing machine impersonation,
> and to my knowledge no actual services or applications depends on
> it. Why not bury it under some compatibility option, default=off??
I did not realize it was a security hole since the info returned
can be gotten in other ways... But I do see Netapp has disabled
the procedure.

steved.

