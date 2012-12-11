Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:46097 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787Ab2LKO61 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2012 09:58:27 -0500
Message-ID: <50C749E0.4040107@parallels.com>
Date: Tue, 11 Dec 2012 18:57:36 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <devel@openvz.org>
Subject: Re: [PATCH 2/6] nfsd: swap fs root in NFSd kthreads
References: <20121206153204.30693.11408.stgit@localhost.localdomain> <20121206153447.30693.54128.stgit@localhost.localdomain> <20121210202842.GB17350@fieldses.org> <50C73C60.8060405@parallels.com> <20121211145443.GH4939@ZenIV.linux.org.uk>
In-Reply-To: <20121211145443.GH4939@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.12.2012 18:54, Al Viro пишет:
> On Tue, Dec 11, 2012 at 06:00:00PM +0400, Stanislav Kinsbursky wrote:
>> 11.12.2012 00:28, J. Bruce Fields ??????????:
>>> On Thu, Dec 06, 2012 at 06:34:47PM +0300, Stanislav Kinsbursky wrote:
>>>> NFSd does lookup. Lookup is done starting from current->fs->root.
>>>> NFSd is a kthread, cloned by kthreadd, and thus have global (but luckely
>>>> unshared) root.
>>>> So we have to swap root to those, which process, started NFSd, has. Because
>>>> that process can be in a container with it's own root.
>>>
>>> This doesn't sound right to me.
>>>
>>> Which lookups exactly do you see being done relative to
>>> current->fs->root ?
>>>
>>
>> Ok, you are right. I was mistaken here.
>> This is not a exactly lookup, but d_path() problem in svc_export_request().
>> I.e. without root swapping, d_path() will give not local export path (like "/export")
>> but something like this "/root/containers_root/export".
>
> Now, *that* is a different story (and makes some sense).  Take a look
> at __d_path(), please.  You don't need to set ->fs->root to get d_path()
> equivalent relative to given point.
>

Thanks, Al.
But __d_path() is not exported and this code is called from NFSd module.
Is it suitable for you to export __d_path()?

-- 
Best regards,
Stanislav Kinsbursky
