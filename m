Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46508 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113Ab2B0Mvm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 07:51:42 -0500
Message-ID: <4F4B7C4B.5000901@parallels.com>
Date: Mon, 27 Feb 2012 16:51:23 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix use-after-free of rpc pipes
References: <1330019288-13031-1-git-send-email-iisaman@netapp.com>	 <4F47D37D.2080409@parallels.com> <1330300376.18817.0.camel@lade.trondhjem.org>
In-Reply-To: <1330300376.18817.0.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

27.02.2012 03:52, Myklebust, Trond пишет:
> On Fri, 2012-02-24 at 22:14 +0400, Stanislav Kinsbursky wrote:
>> 23.02.2012 21:48, Fred Isaman пишет:
>>> This needs to be looked at closely by someone more familiar with the
>>> pipe code.
>>>
>>> It fixes an issue with the current nfs_for_next branch which causes a
>>> chain of oopses on umount every time if sufficient CONFIG_* debug
>>> options are set.
>>>
>>> A git-bisect shows that the problem was introduced by
>>> commit c239d83b  SUNRPC: split SUNPRC PipeFS dentry and private pipe data creation
>>>
>>
>>
>>
>> Fred, thanks for the config.
>> The problem is caused by destroying pipe data on NFS client umount after
>> unlinking pipe dentry. This is valid approach, but it looks like idmap daemon
>> holds dentry by eventfd.
>> This is a race between idmap daemon release of this dentry and releasing of pipe
>> data...
>> I need some time to find out how to fix this properly.
>>
>
> How about something like the following (still untested) patch?
>
> Cheers
>    Trond


Hi, Trond. Thanks for participating.
Frankly, I don't like the idea of put'ing pipe data on dentry unlink. IOW, I 
don't like that this data will be controlled somehow in PipeFS.
I'll send my version soon.

-- 
Best regards,
Stanislav Kinsbursky
