From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bug] NFSv4 fails to work without ipv6 kernel module
Date: Fri, 1 May 2009 10:15:45 -0400
Message-ID: <D1EFB3ED-6951-4871-8FAE-C69C5B3E519E@oracle.com>
References: <200905010304.45884.bircoph@gmail.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:62223 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390AbZEAOPv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2009 10:15:51 -0400
In-Reply-To: <200905010304.45884.bircoph@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 30, 2009, at 7:04 PM, Andrew Savchenko wrote:
> Hello, Chuck!
>
> [10l, forget to CC to list]
>
> On Thursday 30 April 2009, Chuck Lever wrote:
> [...]
>>> With ipv6 module loaded all works fine.
>>>
>>>> You can also try building 2.6.28 with
>>>> CONFIG_SUNRPC_REGISTER_V4 disabled.
>>>
>>> With this option disabled errno 5 (see above) disappeared from
>>> logs, but mount fails with the same errors. Yet again, with
>>> ipv6 module loaded it works ok.
>>
>> Reproduced here.  A patch is attached.  (I usually send patches
>> inline, but to test 2.6.29-stable I'm working outside of git,
>> using old-fashioned tools like "diff").
>
> Patch works ok, thank you.

Thanks for testing.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
