From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Re: XPRTRDMA max payload?
Date: Thu, 4 Sep 2008 11:03:33 -0400
Message-ID: <FBD49F54-F63F-4385-8B7C-B1D48AA4C2E0@myri.com>
References: <B520CA74-F8C7-4D93-BC99-0B784F31C1D9@myri.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1854 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752854AbYIDPDe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 11:03:34 -0400
Received: from scott-wlan.sw.myri.com (scott-wlan.sw.myri.com [172.31.162.6])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id m84F3XBW021594
	for <linux-nfs@vger.kernel.org>; Thu, 4 Sep 2008 08:03:33 -0700 (PDT)
In-Reply-To: <B520CA74-F8C7-4D93-BC99-0B784F31C1D9-vV262kQ/Wyo@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 4, 2008, at 11:00 AM, Scott Atchley wrote:

> It seems to be set on the client to 23 KB (RPCRDMA_MAX_DATA_SEGS *  
> PAGE_SIZE).

s/23/32/

:-P
