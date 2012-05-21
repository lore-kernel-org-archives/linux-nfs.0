Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:56796 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114Ab2EUPnm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 11:43:42 -0400
Message-ID: <4FBA62A1.4070207@panasas.com>
Date: Mon, 21 May 2012 18:43:29 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: Andy Adamson <andros@netapp.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SQUASHME: pnfsd-lexp: Fix compiler warning when CONFIG_SUNRPC_DEBUG
 is not set
References: <4FBA1BD4.7090303@panasas.com> <4FBA5AE5.8080707@tonian.com>
In-Reply-To: <4FBA5AE5.8080707@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/21/2012 06:10 PM, Benny Halevy wrote:

> On 2012-05-21 13:41, Boaz Harrosh wrote:
>>
>> Fix "Unused variable" warning if CONFIG_SUNRPC_DEBUG is not set
>>
> 
> Merged, thanks!
> 


Not that I'm at the stage where I don't configure CONFIG_SUNRPC_DEBUG=y
It was recently changed and my oldconfig base removed it.

Actually I got lucky, because I would have run without dprints
and would have pulled my hair what's going on with my setup.

I wish it would stay to protect me for a while ;-)

Thanks
Boaz

