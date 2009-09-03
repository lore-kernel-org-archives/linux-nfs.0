Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:44519 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755078AbZICOI4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 10:08:56 -0400
Message-ID: <4A9FCDF7.1090700@corp.free.fr>
Date: Thu, 03 Sep 2009 16:08:55 +0200
From: Yohan <ytordjman@corp.free.fr>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>, mikevs@xs4all.net
Subject: Re: VM issue causing high CPU loads
References: <4A92A25A.4050608@yohan.staff.proxad.net>	 <20090824162155.ce323f08.akpm@linux-foundation.org>	 <4A96463E.5080002@corp.free.fr> <4A9C34F8.2010307@corp.free.fr>	 <20090902170642.f4381c1d.akpm@linux-foundation.org>	 <1251982884.18338.9.camel@heimdal.trondhjem.org>	 <4A9FC719.9020104@corp.free.fr> <1251986526.18338.29.camel@heimdal.trondhjem.org>
In-Reply-To: <1251986526.18338.29.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> On Thu, 2009-09-03 at 15:39 +0200, Yohan wrote:
>   
>>> As far as I can see, there is no RPCSEC_GSS involved, so credentials
>>> should never expire. They will be reused as long as processes aren't
>>> switching between thousands and thousands of different combinations of
>>> uid, gid and groups.
>>>       
>> My servers are imap servers.
>> Foreach user (~15 million) it have a specific uid over ~10 nfs netapp 
>> storage.
>>     
> OK, so 16 hash buckets are likely to be filled with ~10^6 entries each.
> I can see that might be a performance issue...
>
> So afaics, you did try adjusting the hashtable size. How much larger
> does it have to be before you start to get acceptable performance? If it
> solves your problem we could make hash table sizes adjustable via a
> module parameter, for instance.
>   
I run now with a value of 12, and it's great for me...

