From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Fri, 25 Apr 2008 18:13:03 -0400
Message-ID: <4D5FA350-EED5-4204-8D70-E3BE5E400595@oracle.com>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com> <20080425080128.GA4848@uio.no> <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com> <20080425142712.GA6119@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:32023 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763435AbYDYWT7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 18:19:59 -0400
In-Reply-To: <20080425142712.GA6119-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2008, at 10:27 AM, Steinar H. Gunderson wrote:
> On Fri, Apr 25, 2008 at 10:19:54AM -0400, Chuck Lever wrote:
>>> The other submitters have iptables blocking on the server, though,  
>>> and it
>>> doesn't work for them either (one is using NFSv3, the other  
>>> NFSv4). Is
>>> this really working for you?
>> I can't say until you post a complete description of a specific test
>> case.
>
> On the client:
>
>  iptables -A OUTPUT -d 10.0.0.10 -p udp -j DROP
>  mount -t nfs 10.0.0.10:/foo /bar
>
> Substitute 10.0.0.10 with the server, of course.

I just tried this specific use case.

Because of the local packet filtering on the client, the kernel's RPC  
client is getting -EPERM when trying to send the initial rpcbind  
request.

As far as I can see, nothing in the RPC client knows how to deal  
specifically with that error code, so it punts the request, and the  
mount fails.

When I originally tested mount protocol/version negotiation, I used  
only server-side filtering.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
