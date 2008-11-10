From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Mon, 10 Nov 2008 10:45:44 +0530
Message-ID: <4917C380.9040703@linux.vnet.ibm.com>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Le Rouzic <aime.le-rouzic@bull.net>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from E23SMTP05.au.ibm.com ([202.81.18.174]:52660 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbYKJFRB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 00:17:01 -0500
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAA5Fnku021857
	for <linux-nfs@vger.kernel.org>; Mon, 10 Nov 2008 16:15:49 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAA5FmKu368804
	for <linux-nfs@vger.kernel.org>; Mon, 10 Nov 2008 16:15:50 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAA5FetW014138
	for <linux-nfs@vger.kernel.org>; Mon, 10 Nov 2008 16:15:41 +1100
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

                 I just realized that i forgot to update you about the 
test result of your tree. I found NFSv4 over ipv6 working well. So it 
can be pulled into the mainline soon.

Thanks

Varun
