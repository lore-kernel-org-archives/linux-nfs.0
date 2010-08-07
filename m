Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from puma-mxisp.mxtelecom.com ([83.166.71.4]:42282 "EHLO
	puma.mxtelecom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762204Ab0HGAZu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 20:25:50 -0400
Message-ID: <4C5CA80A.7010501@mxtelecom.com>
Date: Sat, 07 Aug 2010 01:25:46 +0100
From: Matthew Hodgson <matthew@mxtelecom.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: Tuning NFS client write pagecache
References: <4C5BFE47.8020905@mxtelecom.com> <20100806132620.GA2921@merit.edu> <4C5C3869.1040900@mxtelecom.com>
In-Reply-To: <4C5C3869.1040900@mxtelecom.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/08/2010 17:29, Matthew Hodgson wrote:
>> Matthew Hodgson wrote:
>>
>> Is there any way to tune the linux NFSv3 client to prefer to write
>> data straight to an async-mounted server, rather than having large
>> writes to a file stack up in the local pagecache before being synced
>> on close()?
>
> In other news, whilst saturating the ~10Mb/s pipe during the big write
> to the server, I'm seeing huge delays of >10 seconds on trying to do
> trivial operations such as ls'ing small directories. Is this normal, or
> is there some kind of tunable scheduling on the client to avoid a single
> big transfer wedging the machine?

Hm, on reading the archives, it seems that this is a fairly common 
complaint when dealing with large sequential workloads - a sideeffect of 
the write pagecache not writing out smoothly.

What is the status of the '[PATCH] improve the performance of large 
sequential write NFS workloads' patchset at 
http://www.spinics.net/lists/linux-nfs/msg11131.html?  It seems that it, 
and its predecessors, are intended to fix precisely this issue.  It 
doesn't seem to have landed in mainline, though, and I can't find any 
mention of it since http://lwn.net/Articles/373868/.

thanks,

Matthew

-- 
Matthew Hodgson
Development Program Manager
OpenMarket | www.openmarket.com/europe
matthew.hodgson@openmarket.com
