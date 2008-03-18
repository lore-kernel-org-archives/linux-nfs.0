From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: NFSERR_NOSPC nfs-client bug
Date: Tue, 18 Mar 2008 13:08:21 +1100
Message-ID: <47DF2415.6070802@melbourne.sgi.com>
References: <200803172021.08327.nfs@share-foo.com> <47DF1E5C.9090607@melbourne.sgi.com> <200803172050.22223.nfs@share-foo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:53825 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751882AbYCRCEg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2008 22:04:36 -0400
In-Reply-To: <200803172050.22223.nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ray Ferguson wrote:
> On Monday 17 March 2008 20:43, Greg Banks wrote:
>   
>> It doesn't ignore ENOSPC, it reports it on close().  Of course this is
>> often several gigabytes of lost data too late.
>>     
>
> In our case, the thrashing it gave our Linux NFS cluster was severe enough to  
> take it out of commission.  The lost data from the file transfer that 
> triggered the event was the least of our worries.
>
>   
Agreed, it sucks.

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

