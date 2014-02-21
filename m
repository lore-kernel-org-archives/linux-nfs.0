Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:48682 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbaBUJSd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Feb 2014 04:18:33 -0500
Message-ID: <530719E4.5060409@parallels.com>
Date: Fri, 21 Feb 2014 13:18:28 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Weng Meiling <wengmeiling.weng@huawei.com>, <greg@kroah.com>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH] nfsd: check passed socket's net matches NFSd superblock's
 one
References: <20131230142339.16166.28243.stgit@localhost.localdomain> <20140103222226.GD5164@fieldses.org> <52FEC818.7030604@huawei.com> <20140217221900.GA8401@fieldses.org> <53037A03.4020603@parallels.com> <20140218154406.GD4319@fieldses.org> <530486D9.7010502@parallels.com> <20140219145043.GC8401@fieldses.org> <5304C66A.4030603@parallels.com> <20140220213124.GC13433@fieldses.org>
In-Reply-To: <20140220213124.GC13433@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

21.02.2014 01:31, J. Bruce Fields пишет:
> On Wed, Feb 19, 2014 at 06:57:46PM +0400, Stanislav Kinsbursky wrote:
>> 19.02.2014 18:50, J. Bruce Fields пишет:
>>> On Wed, Feb 19, 2014 at 02:26:33PM +0400, Stanislav Kinsbursky wrote:
>>>> 18.02.2014 19:44, J. Bruce Fields пишет:
>>>>> On Tue, Feb 18, 2014 at 07:19:31PM +0400, Stanislav Kinsbursky wrote:
>>>>>> 18.02.2014 02:19, J. Bruce Fields пишет:
>>>>>>> On Sat, Feb 15, 2014 at 09:51:20AM +0800, Weng Meiling wrote:
>>>>>>>> Hi Bruce,
>>>>>>>>
>>>>>>>> The upstream has merged your git tree for-3.14, but there is no this patch?
>>>>>>>> Do you forget this patch?
>>>>>>>
>>>>>>> Apologies, I'm not sure what happened.
>>>>>>>
>>>>>>> Looking back at it....  The patch causes all my pynfs reboot recovery
>>>>>>> tests to fail.  They're just doing a "systemctl restart
>>>>>>> nfs-server.service", and "systemctl status nfs-server.service" shows in
>>>>>>> part
>>>>>>>
>>>>>>> 	ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS $RPCNFSDCOUNT (code=exited, status=1/FAILURE)
>>>>>>>
>>>>>>> So the patch is causing rpc.nfsd to fail?  No network namespaces should
>>>>>>> be involved.
>>>>>>>
>>>>>>> I haven't investigated any further.
>>>>>>>
>>>>>>
>>>>>> Hi Bruce,
>>>>>> Are you sure, that exactly this patch broke your pynfs tests?
>>>>>> BTW, systemd manipulates namespaces. Maybe the patch revealed some pynfs internal bugs?
>>>>>> What do you think?
>>>>>
>>>>> It's really just "systemctl restart nfs-server.service" that the patch
>>>>> breaks, pynfs isn't involved much.
>>>>>
>>>>> The patch I'm actually using follows, but I believe the only difference
>>>>> is in the printk message?
>>>>>
>>>>
>>>> Yep, looks true.
>>>> That's strange: "systemctl restart nfs-server.service" works for me on Fedora 18 with kernel, based on your repo.
>>>
>>> OK, I'll take a closer look and let you know what I find.
>>>
>>
>> Thank you, Bruce!
>
> rpc.nfsd's attempt to bind port 2049 the second time is failing with
> EADDRINUSE.
>
> svc_alien_sock isn't failing, so the only different here is that we're
> running sockfd_lookup....
>
> Does that take a reference on the fd or the sock that needs to be put?
>

Yes, you right. I missed it, sorry.
Thank you. Will resend.

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
