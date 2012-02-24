Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:15406 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753465Ab2BXOBm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Feb 2012 09:01:42 -0500
Message-ID: <4F47983A.3020104@parallels.com>
Date: Fri, 24 Feb 2012 18:01:30 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Fred Isaman <iisaman@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix use-after-free of rpc pipes
References: <1330019288-13031-1-git-send-email-iisaman@netapp.com> <4F4778C6.8050705@parallels.com> <802ED333-DCE5-4EA5-ACDC-0269E8817EA7@netapp.com>
In-Reply-To: <802ED333-DCE5-4EA5-ACDC-0269E8817EA7@netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

24.02.2012 17:17, Fred Isaman пишет:
>
> On Feb 24, 2012, at 3:47 AM, Stanislav Kinsbursky wrote:
>
>> BTW, it looks very strange...
>> Now many networks namespaces do you use?
>>
>
> Not sure, I definitely was not intentionally adding any, so I assume one.  This was reproduced on Fedora 12, Fedora 16 and recent RHEL distros with custom kernels installed.
>
> The Fedora 16 install was a fresh install onto a VMWare Fusion guest with two NICs (one NAT and one bridged), though the bridged one was turned off.
>
>

Ok, thanks, Fred.
Will try to reproduce.

-- 
Best regards,
Stanislav Kinsbursky
