From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: Problems with the git://linux-nfs.org/ server
Date: Tue, 28 Sep 2010 15:32:51 +0200
Message-ID: <4CA1EE83.1000700@panasas.com>
References: <4CA1B40D.2080204@panasas.com> <1285679386.9185.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42747 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755057Ab0I1Ncy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 09:32:54 -0400
In-Reply-To: <1285679386.9185.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/28/2010 03:09 PM, Trond Myklebust wrote:
> On Tue, 2010-09-28 at 11:23 +0200, Boaz Harrosh wrote:
>> It looks like the git daemon on git://linux-nfs.org/ is down
>>
>> Thanks
>> Boaz
> 
> It's working for me...
> 
> [trondmy@heimdal linux-2.6]$ git remote update linux-nfs
> Fetching linux-nfs
> 
> Cheers
>   Trond
> 

Thanks. I still get problems so I guess it's related to
this side of the ocean, I'm trying for example:

$ git ls-remote git://git.linux-nfs.org/~trondmy/nfs-2.6.git
And get: git.linux-nfs.org[0: 173.201.45.137]: errno=Connection timed out

But ping git.linux-nfs.org works (8% packet loss)

I'll wait for things to calm down, I guess

Boaz


