From: "Frank A. Kingswood" <frank-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 28 Apr 2008 19:24:49 +0100
Message-ID: <48161671.2070508@kingswood-consulting.co.uk>
References: <20080423214929.GA24387@uio.no> <48134C77.9090700@kingswood-consulting.co.uk> <2AA81EE8-74A9-42A5-8ACF-E01BBB6F2280@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org,
	public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-8ByrlEUxsivZ+VzJOa5vwg@public.gmane.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 88-97-16-53.dsl.zen.co.uk ([88.97.16.53]:41291 "EHLO
	moonrock.kingswood-consulting.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966016AbYD1SaK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2008 14:30:10 -0400
In-Reply-To: <2AA81EE8-74A9-42A5-8ACF-E01BBB6F2280@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>>
>> The NFS client code (nfs-utils-1.1.2) tests for
>>  if (kernel_version > MAKE_VERSION(2, 6, 22))
>>
>> yet the kernel patch for NFS did not go un until 2.6.25-rc2
>> So the test should at least be > MAKE_VERSION(2, 6, 24).
> The original NFS text-based mount support was added in 2.6.23.
OK.
> New features will be added only to the text-based mount interface, 
> however, so eventually everyone will need to use the text-based mount 
> interface on new kernels.
That sounds like a good idea.
> Because we have little documented history and only a handful of use 
> cases and unit tests for the mount command, it's important for 
> everyone to test the new API and report problems here so we can 
> address them.  NFS mount is complex and has many subtle and hidden 
> historical behaviors.
My system fails with 2.6.23 and 2.6.25 kernels. As I described in my 
original mail, I only have TCP access to the server, and only through an 
ssh tunnel.

Would you like me to try and produce some debug traces, or do you think 
you can find the problem with the information you have already? I've 
seen quite a few reports of this now.

Frank

-- 
------------------------------------------------------------------------
Frank A. Kingswood                      frank-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org
Cambridge, United Kingdom                               +44-7943-217 571

