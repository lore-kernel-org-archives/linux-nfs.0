From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text based mount options ignoring the preferred rwsize?
Date: Wed, 9 Sep 2009 18:34:07 -0400
Message-ID: <F384AB25-470C-4F9A-B6B2-C549EA94B055@oracle.com>
References: <4AA68AA4.7090606@moving-picture.com> <188B198A-A113-4CA7-940D-EFBD026CBDD2@oracle.com> <4AA8225A.9060107@moving-picture.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:38943 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbZIIWen (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2009 18:34:43 -0400
In-Reply-To: <4AA8225A.9060107-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 9, 2009, at 5:47 PM, James Pearson wrote:
> Chuck Lever wrote:
>>>
>>> Should the kernel be setting rsize (and wsize) to 0 by default?
>> nfs(5) says:
>> "If an [rw]size value is not specified, or if the specified  
>> [rw]size  value is larger than the maximum that either client or  
>> server can  support, the client and server negotiate the largest  
>> [rw]size value  that they can both support."
>> So the text-based behavior is what is documented now.
>> Does anyone know of a reason to use the server's "preferred"  
>> transfer  size rather than the largest size supported by both  
>> client and  server?  Usually those are the same.
>
> In this case, the manufacturer of the NFS server recommends using  
> 128Kb for rsize and 512Kb for wsize - although the maximum rsize it  
> supports is 512Kb. I assume in their testing, these values have  
> given optimal performance figures.

In this case maybe you should set these explicitly.

> The default behaviour with binary mount options when no [rw]size is  
> to select these preferred values - which to me, makes sense - as by  
> not giving a [rw]size, you are leaving it up the server to pick the  
> 'best' values for you - which I guess in most (all other?) cases  
> happen to be the maximum size.

It might make sense to think of the server's preference as the value  
you should use.  But for the client, the larger the better in nearly  
every case.  So which one should you choose by default?

Someone could still make the case that the old behavior was better in  
some way (and provide benchmark evidence for this, of course, for  
multiple combinations of implementations across different networks).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



