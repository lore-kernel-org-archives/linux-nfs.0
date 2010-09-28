From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Problems with the git://linux-nfs.org/ server
Date: Tue, 28 Sep 2010 16:50:26 +0200
Message-ID: <4CA200B2.7020208@panasas.com>
References: <4CA1B40D.2080204@panasas.com>	 <1285679386.9185.4.camel@heimdal.trondhjem.org>	 <4CA1EE83.1000700@panasas.com> <1285681777.9185.13.camel@heimdal.trondhjem.org> <4CA1FFF0.6090304@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:32686 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756508Ab0I1Ou3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 10:50:29 -0400
In-Reply-To: <4CA1FFF0.6090304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-09-28 16:47, Benny Halevy wrote:
> On 2010-09-28 15:49, Trond Myklebust wrote:
>> On Tue, 2010-09-28 at 15:32 +0200, Boaz Harrosh wrote:
>>> On 09/28/2010 03:09 PM, Trond Myklebust wrote:
>>>> On Tue, 2010-09-28 at 11:23 +0200, Boaz Harrosh wrote:
>>>>> It looks like the git daemon on git://linux-nfs.org/ is down
>>>>>
>>>>> Thanks
>>>>> Boaz
>>>>
>>>> It's working for me...
>>>>
>>>> [trondmy@heimdal linux-2.6]$ git remote update linux-nfs
>>>> Fetching linux-nfs
>>>>
>>>> Cheers
>>>>   Trond
>>>>
>>>
>>> Thanks. I still get problems so I guess it's related to
>>> this side of the ocean, I'm trying for example:
>>>
>>> $ git ls-remote git://git.linux-nfs.org/~trondmy/nfs-2.6.git
>>> And get: git.linux-nfs.org[0: 173.201.45.137]: errno=Connection timed out
>>>
>>
>> Yes. The above too works for me, and I can't see anything in the logs
>> that indicates anything wrong.
>>
>> Could it perhaps be that you are hitting one of those ancient BSD-based
>> routers that are broken w.r.t. TCP explicit congestion notification
>> (a.k.a. ECN) and/or TCP window scaling? You might try turning those off
>> on your client and see if that helps.
> 
> hmm, we also see ~16% packet loss over PING :-(

But I don't see this from Panasas' US hosts so
it's somewhere in between Israel and linux-nfs.org

Benny

> 
> Benny
> 
>>
>> Cheers
>>   Trond
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
