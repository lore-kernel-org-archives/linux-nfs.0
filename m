Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:49937 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab1FJQ51 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 12:57:27 -0400
Message-ID: <4DF24CF0.3030507@panasas.com>
Date: Fri, 10 Jun 2011 09:57:20 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] NFSv4.1: Add an initialisation callback for pNFS
References: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com>	 <1307669462-15764-2-git-send-email-Trond.Myklebust@netapp.com>	 <1307669462-15764-3-git-send-email-Trond.Myklebust@netapp.com>	 <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com>	 <4DF1871C.1070001@panasas.com> <4DF19841.5030904@panasas.com>	 <4DF19D7B.2060308@panasas.com> <4DF1A106.3070205@panasas.com>	 <4DF242D7.4030607@panasas.com> <1307723298.19554.8.camel@lade.trondhjem.org>
In-Reply-To: <1307723298.19554.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/10/2011 09:28 AM, Trond Myklebust wrote:
>>
>> That makes it even more complicated for a do nothing function. We dont do
>> a different function for each different parameter. We can just do a 
>> "bool write" and unify the dam thing
> 
> Right now, the nfs_pageio_descriptor doesn't know about reads vs writes.
> It just knows about 'coalesce requests' and 'perform i/o'. I'd prefer to
> keep that abstraction, as it makes things cleaner, particularly when you
> get to patch 5 (NFSv4.1: Fall back to ordinary i/o through the mds if we
> have no layout segment). Why add more 'if' statements when you don't
> need to...
> 

OK It's fine. I'm convinced. Do you have this on a git tree? I want to test
it out. 

What was the disposition of desc->pg_bsize do I need to adjust it for the
pnfs_case in objlayout?

Thanks
Boaz
