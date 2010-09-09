From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] libexport.a: Refactor init_netmask()
Date: Thu, 09 Sep 2010 13:52:17 -0400
Message-ID: <4C891ED1.1080204@RedHat.com>
References: <20100902192350.1755.66184.stgit@matisse.1015granger.net> <4C88F16B.10802@RedHat.com> <AC20E599-9576-4F97-97BD-8E9B2E3E3F87@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087Ab0IIRwU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 13:52:20 -0400
In-Reply-To: <AC20E599-9576-4F97-97BD-8E9B2E3E3F87@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/09/2010 01:03 PM, Chuck Lever wrote:
> Hi Steve-
> 
> On Sep 9, 2010, at 10:38 AM, Steve Dickson wrote:
> 
>>
>> On 09/02/2010 03:23 PM, Chuck Lever wrote:
>>> Instead of a single function that can handle both AF_INET and AF_INET6
>>> addresses, two separate functions might be cleaner.
>>>
>>> The original plan was to keep code redundancy at a minimum, but the
>>> resulting code was cumbersome at best.  I think I've traded a little
>>> extra code for something that will be much easier to read, understand,
>>> and maintain.
>>>
>>> I've also eliminated the "#if / #endif" instances inside the functions.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>> Committed...
> 
> This (and the RDMA patches) appears in nfs-utils-exp.git, but not in nfs-utils.git.
> 
> For my development tree, I pull from the latter.  
> Should I pull from nfs-utils-exp instead?
Sorry about that, the patches now on the correct tree..

steved.

> 
