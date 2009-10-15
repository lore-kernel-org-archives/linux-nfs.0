From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 01/26] statd: Replace note() with xlog() in rpc.statd
Date: Thu, 15 Oct 2009 10:58:18 -0400
Message-ID: <EF48548F-BE45-4B1E-A5AA-44E65A0411D0@oracle.com>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net> <20091013145416.2424.12787.stgit@matisse.1015granger.net> <20091014165755.GA20968@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, chris.mason@oracle.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43788 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756389AbZJOO7V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2009 10:59:21 -0400
In-Reply-To: <20091014165755.GA20968@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 14, 2009, at 12:57 PM, J. Bruce Fields wrote:

> On Tue, Oct 13, 2009 at 10:54:16AM -0400, Chuck Lever wrote:
>> diff --git a/utils/statd/misc.c b/utils/statd/misc.c
>> index 7256291..44af30e 100644
>> --- a/utils/statd/misc.c
>> +++ b/utils/statd/misc.c
>> @@ -29,8 +29,7 @@ xmalloc (size_t size)
>>     return ((void *)NULL);
>>
>>   if (!(ptr = malloc (size)))
>> -    /* SHIT!  SHIT!  SHIT! */
>> -    die ("malloc failed");
>> +    xlog_err ("malloc failed");
>
> Minor comment, no need to fix now, but: with the name "die" it was a  
> lot
> more obvious that this function never returned.

This is going away, eventually.  See below.

> Also future work (not a problem with this patch): it's irritating that
> we have long-running daemons dying on memory allocation failures.
> Wouldn't it be better if they failed just the current operation and
> tried to keep going?

Yes.  One of the goals of this rework was to replace xmalloc and  
xstrdup in statd, but I've left that behind in the interest of  
minimizing scope creep.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



