Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:46806 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752795AbZICNji (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 09:39:38 -0400
Message-ID: <4A9FC719.9020104@corp.free.fr>
Date: Thu, 03 Sep 2009 15:39:37 +0200
From: Yohan <ytordjman@corp.free.fr>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>, mikevs@xs4all.net
Subject: Re: VM issue causing high CPU loads
References: <4A92A25A.4050608@yohan.staff.proxad.net>	 <20090824162155.ce323f08.akpm@linux-foundation.org>	 <4A96463E.5080002@corp.free.fr> <4A9C34F8.2010307@corp.free.fr>	 <20090902170642.f4381c1d.akpm@linux-foundation.org> <1251982884.18338.9.camel@heimdal.trondhjem.org>
In-Reply-To: <1251982884.18338.9.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


>>> I did only:
>>>
>>> --- linux-2.6.27.21/include/linux/sunrpc/auth.h	2009-03-23 23:04:09.000000000 +0100
>>> +++ linux-2.6.27.21/include/linux/sunrpc/auth.h	2009-05-19 16:02:35.000000000 +0200
>>> @@ -62,8 +62,12 @@ 
>>>   */
>>> - #define RPC_CREDCACHE_HASHBITS	4
>>> + #define RPC_CREDCACHE_HASHBITS	12
>>>
>>>
>>> And i test it in prod since sunday: i only have 36% of one core used by 
>>> system
>>> versus more than 3 cores used by system in another server that did a 
>>> drop_caches at morning...
>>>       
>> OK, but it's still pretty bad.  Let's tell the NFS guys.
>>
>> In http://bugzilla.kernel.org/show_bug.cgi?id=14024 we appear to have a
>> major meltdown caused by the linear search in
>> rpcauth_lookup_credcache() with Yohan's workload.
>>     
> OK. Could we please have some more details about the actual workload involved here?
>   
I add a new server CPU graph and 60s readprofile on the bugzilla

> As far as I can see, there is no RPCSEC_GSS involved, so credentials
> should never expire. They will be reused as long as processes aren't
> switching between thousands and thousands of different combinations of
> uid, gid and groups.
My servers are imap servers.
Foreach user (~15 million) it have a specific uid over ~10 nfs netapp 
storage.

