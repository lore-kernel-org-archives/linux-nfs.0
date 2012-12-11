Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:47863 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885Ab2LKPHd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2012 10:07:33 -0500
Message-ID: <50C74C14.8030807@parallels.com>
Date: Tue, 11 Dec 2012 19:07:00 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [Devel] [PATCH 2/6] nfsd: swap fs root in NFSd kthreads
References: <20121206153204.30693.11408.stgit@localhost.localdomain> <20121206153447.30693.54128.stgit@localhost.localdomain> <20121210202842.GB17350@fieldses.org> <50C73C60.8060405@parallels.com> <50C73F58.1080005@parallels.com> <20121211145621.GA3336@fieldses.org>
In-Reply-To: <20121211145621.GA3336@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.12.2012 18:56, J. Bruce Fields пишет:
> On Tue, Dec 11, 2012 at 06:12:40PM +0400, Stanislav Kinsbursky wrote:
>> UID: 9899
>>
>> 11.12.2012 18:00, Stanislav Kinsbursky пишет:
>>> 11.12.2012 00:28, J. Bruce Fields пишет:
>>>> On Thu, Dec 06, 2012 at 06:34:47PM +0300, Stanislav Kinsbursky wrote:
>>>>> NFSd does lookup. Lookup is done starting from current->fs->root.
>>>>> NFSd is a kthread, cloned by kthreadd, and thus have global (but luckely
>>>>> unshared) root.
>>>>> So we have to swap root to those, which process, started NFSd, has. Because
>>>>> that process can be in a container with it's own root.
>>>>
>>>> This doesn't sound right to me.
>>>>
>>>> Which lookups exactly do you see being done relative to
>>>> current->fs->root ?
>>>>
>>>
>>> Ok, you are right. I was mistaken here.
>>> This is not a exactly lookup, but d_path() problem in svc_export_request().
>>> I.e. without root swapping, d_path() will give not local export path (like "/export")
>>> but something like this "/root/containers_root/export".
>>>
>>
>> We, actually, can do it less in less aggressive way.
>> I.e. instead root swap and current svc_export_request() implementation:
>>
>> void svc_export_request(...)
>> {
>> 	<snip>
>>          pth = d_path(&exp->ex_path, *bpp, *blen);
>> 	<snip>
>> }
>>
>> we can do something like this:
>>
>> void svc_export_request(...)
>> {
>> 	struct nfsd_net *nn = ...
>> 	<snip>
>> 	spin_lock(&dcache_lock);
>>          pth = __d_path(&exp->ex_path, &nn->root, *bpp, *blen);
>> 	spin_unlock(&dcache_lock);
>> 	<snip>
>> }
>
> That looks simpler, but I still don't understand why we need it.
>
> I'm confused about how d_path works; I would have thought that
> filesystem namespaces would have their own vfsmount trees and hence that
> the (vfsmount, dentry) would be enough to specify the path.  Is the root
> argument for the case of chroot?  Do we care about that?
>

It works very simple: just traverse the tree from specified dentry up to current->fs->root.dentry.
Having container in some fully separated mount point is great, of course. But:
1) this is a limitation we really want to avoid. I.e. container can be chrooted into some path like "/root/containers_root/" as in example above.
2) NFSd kthread works in init root environment. But we anyway want to get proper path string in container root, but not in kthreads root.

> Also, svc_export_request is called from mountd's read of
> /proc/net/rpc/nfsd.export/channel.  If mountd's root is wrong, then
> nothing's going to work anyway.
>

I don't really understand, how  mountd's root can be wrong. I.e. its' always right as I see it. NFSd kthreads have to swap/use relative path/whatever to 
communicate with proper mountd.
Or I'm missing something?

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
