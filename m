From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Wed, 12 Nov 2008 00:57:10 -0500
Message-ID: <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com> <4917C380.9040703@linux.vnet.ibm.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Le Rouzic <aime.le-rouzic@bull.net>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:51906 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbYKLF5u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 00:57:50 -0500
In-Reply-To: <4917C380.9040703@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 10, 2008, at 12:15 AM, Varun Chandramohan wrote:

> Chuck Lever wrote:
>> Hi Aime, Varun-
>>
>> Bruce asked me to collect server-side IPv6 patches for upstream.   
>> I've collected the patches that have been posted on the list, and  
>> added some fixes of my own.
>>
>> Can you have a look at
>>
>>  http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=summary
>>
>>  tag cel-ipv6-10292008
>>
>> These have been build tested, but I haven't done any run-time  
>> testing yet.
>>
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
> Hi Chuck,
>
>                I just realized that i forgot to update you about the  
> test result of your tree. I found NFSv4 over ipv6 working well. So  
> it can be pulled into the mainline soon.

Thanks for testing!

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
