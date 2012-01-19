Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:8590 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934Ab2ASRAz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 12:00:55 -0500
Message-ID: <4F184C27.8080101@parallels.com>
Date: Thu, 19 Jan 2012 21:00:23 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 2/5] SUNRPC: create unix gid cache per network namespace
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6> <20120119144914.9957.73951.stgit@localhost6.localdomain6> <20120119162431.GC527@fieldses.org>
In-Reply-To: <20120119162431.GC527@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

19.01.2012 20:24, J. Bruce Fields пишет:
> On Thu, Jan 19, 2012 at 06:49:14PM +0400, Stanislav Kinsbursky wrote:
>> This patch makes unix_gid_cache cache detail allocated and registered per
>> network namespace context.
>> Thus with this patch unix_gid_cache contents for network namespace "X" are
>> controlled from proc file system mount for the same network namespace "X".
>
> I'm confused--this seems half-done.  I see that you're creating the gid
> caches dynamically, but there's still this static definition:
>

This static definition is used as a template now.
Have a look at the first path of the series: cache creation routine duplicates 
incomming cache_detail and initializes net and hash_table fields in freshly 
created copy.
This copy is the new per-net cache_detail instance.

>>   struct cache_detail unix_gid_cache = {
>>   	.owner		= THIS_MODULE,
>>   	.hash_size	= GID_HASHMAX,
>> -	.hash_table	= gid_table,
>>   	.name		= "auth.unix.gid",
>>   	.cache_put	= unix_gid_put,
>>   	.cache_upcall	= unix_gid_upcall,
>
> And it looks like unix_gid_lookup is still using this static
> unix_gid_cache.  Maybe I'm missing something....
>

Yep, thanks for the catch.
My fault, I've missed this usage.


-- 
Best regards,
Stanislav Kinsbursky
