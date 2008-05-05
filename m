From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 05 May 2008 08:34:46 -0400
Message-ID: <481EFEE6.4040800@RedHat.com>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com> <20080425080128.GA4848@uio.no> <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com> <20080425142712.GA6119@uio.no> <4D5FA350-EED5-4204-8D70-E3BE5E400595@oracle.com> <20080425235546.GA9053@uio.no> <EBC0B2E8-66BB-4692-8BF2-553804F6FA36@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199AbYEEMjx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 08:39:53 -0400
In-Reply-To: <EBC0B2E8-66BB-4692-8BF2-553804F6FA36@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Apr 25, 2008, at 7:55 PM, Steinar H. Gunderson wrote:
>> On Fri, Apr 25, 2008 at 06:13:03PM -0400, Chuck Lever wrote:
>>> I just tried this specific use case.
>>>
>>> Because of the local packet filtering on the client, the kernel's RPC
>>> client is getting -EPERM when trying to send the initial rpcbind
>>> request.
>>>
>>> As far as I can see, nothing in the RPC client knows how to deal
>>> specifically with that error code, so it punts the request, and the
>>> mount fails.
>>>
>>> When I originally tested mount protocol/version negotiation, I used only
>>> server-side filtering.
>>
>> I checked the original bug report, and indeed it seems that the
>> blocking was
>> on the client there as well. I'll ask the user to check what happens
>> when the filtering is done server-side instead.
>>
>> There's also http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=476128,
>> but I believe that's a different bug.
> 
> 
> FYI: Steve Dickson (nfs-utils maintainer) is already looking at removing
> EACCES from the list of temporary errors, so yes, we're aware of that
> issue.
Actually it has been removed already...

steved.
