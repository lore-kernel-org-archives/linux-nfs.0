From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 28 Apr 2008 11:16:16 -0400
Message-ID: <EBC0B2E8-66BB-4692-8BF2-553804F6FA36@oracle.com>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com> <20080425080128.GA4848@uio.no> <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com> <20080425142712.GA6119@uio.no> <4D5FA350-EED5-4204-8D70-E3BE5E400595@oracle.com> <20080425235546.GA9053@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:28426 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934278AbYD1PQz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2008 11:16:55 -0400
In-Reply-To: <20080425235546.GA9053-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2008, at 7:55 PM, Steinar H. Gunderson wrote:
> On Fri, Apr 25, 2008 at 06:13:03PM -0400, Chuck Lever wrote:
>> I just tried this specific use case.
>>
>> Because of the local packet filtering on the client, the kernel's RPC
>> client is getting -EPERM when trying to send the initial rpcbind
>> request.
>>
>> As far as I can see, nothing in the RPC client knows how to deal
>> specifically with that error code, so it punts the request, and the
>> mount fails.
>>
>> When I originally tested mount protocol/version negotiation, I used  
>> only
>> server-side filtering.
>
> I checked the original bug report, and indeed it seems that the  
> blocking was
> on the client there as well. I'll ask the user to check what happens  
> when the filtering is done server-side instead.
>
> There's also http://bugs.debian.org/cgi-bin/bugreport.cgi? 
> bug=476128, but I believe that's a different bug.


FYI: Steve Dickson (nfs-utils maintainer) is already looking at  
removing EACCES from the list of temporary errors, so yes, we're aware  
of that issue.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
