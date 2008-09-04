From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Re: Unusual FSINFO
Date: Thu, 4 Sep 2008 07:47:03 -0400
Message-ID: <38398028-B8D2-499A-B00E-400D1C35BBA1@myri.com>
References: <64AE2A02-CC2D-4017-9A1F-3C1C6008D3A1@myri.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1870 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753531AbYIDLrH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 07:47:07 -0400
Received: from scott-wlan.sw.myri.com (scott-wlan.sw.myri.com [172.31.162.6])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id m84Bl4P2024535
	for <linux-nfs@vger.kernel.org>; Thu, 4 Sep 2008 04:47:04 -0700 (PDT)
In-Reply-To: <64AE2A02-CC2D-4017-9A1F-3C1C6008D3A1-vV262kQ/Wyo@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Argh, I had deleted svc_xprt_set_remote() assuming it was useful for  
xprtsock only. I did not realize that svcauth_unix.c would want the  
peer's IP address. :-P

Scott

On Aug 26, 2008, at 5:12 PM, Scott Atchley wrote:

> Hi all,
>
> I am working on a new RPC XPRT for Myrinet Express (MX). I am unable  
> to complete a mount request. It fails for one of two causes.
>
> 1. Client's request fails with ESTALE
>
> This happens when the server tries to authenticate the client's UNIX  
> credentials. The first svc_athenticate(1) succeeds, and the second  
> reports:
>
> found domain -test-client-
> found fsidtype 0
> found fsid length 8
> Path seems to be <>
> revisit queued

