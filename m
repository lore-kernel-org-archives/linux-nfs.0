From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Thu, 30 Oct 2008 08:39:06 +0530
Message-ID: <49092552.9050802@linux.vnet.ibm.com>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Le Rouzic <aime.le-rouzic@bull.net>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:53820 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbYJ3DJI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2008 23:09:08 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m9U394hI014853
	for <linux-nfs@vger.kernel.org>; Thu, 30 Oct 2008 08:39:04 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9U394k41708200
	for <linux-nfs@vger.kernel.org>; Thu, 30 Oct 2008 08:39:04 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m9U3937S027763
	for <linux-nfs@vger.kernel.org>; Thu, 30 Oct 2008 08:39:04 +0530
In-Reply-To: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Hi Aime, Varun-
>
> Bruce asked me to collect server-side IPv6 patches for upstream.  I've 
> collected the patches that have been posted on the list, and added 
> some fixes of my own.
>
> Can you have a look at
>
>   http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=summary
>
>   tag cel-ipv6-10292008
>
> These have been build tested, but I haven't done any run-time testing 
> yet.
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
Hi Chuck,
                   It looks ok to me. Aime will be able to confirm 
better. I will do the run-time test and let you know.

Regards,
Varun
