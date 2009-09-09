From: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Subject: Re: Text based mount options ignoring the preferred rwsize?
Date: Wed, 09 Sep 2009 22:47:06 +0100
Message-ID: <4AA8225A.9060107@moving-picture.com>
References: <4AA68AA4.7090606@moving-picture.com> <188B198A-A113-4CA7-940D-EFBD026CBDD2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:52209 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752484AbZIIVrF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2009 17:47:05 -0400
In-Reply-To: <188B198A-A113-4CA7-940D-EFBD026CBDD2@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>>
>> Should the kernel be setting rsize (and wsize) to 0 by default?
> 
> 
> nfs(5) says:
> 
> "If an [rw]size value is not specified, or if the specified [rw]size  
> value is larger than the maximum that either client or server can  
> support, the client and server negotiate the largest [rw]size value  
> that they can both support."
> 
> So the text-based behavior is what is documented now.
> 
> Does anyone know of a reason to use the server's "preferred" transfer  
> size rather than the largest size supported by both client and  server?  
> Usually those are the same.

In this case, the manufacturer of the NFS server recommends using 128Kb 
for rsize and 512Kb for wsize - although the maximum rsize it supports 
is 512Kb. I assume in their testing, these values have given optimal 
performance figures.

The default behaviour with binary mount options when no [rw]size is to 
select these preferred values - which to me, makes sense - as by not 
giving a [rw]size, you are leaving it up the server to pick the 'best' 
values for you - which I guess in most (all other?) cases happen to be 
the maximum size.

James Pearson
