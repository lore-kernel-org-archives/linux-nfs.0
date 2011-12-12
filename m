Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46476 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334Ab1LLQ2A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 11:28:00 -0500
Message-ID: <4EE62B78.9030000@parallels.com>
Date: Mon, 12 Dec 2011 20:27:36 +0400
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
Subject: Re: [PATCH 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6> <20111208204648.GB32505@fieldses.org> <4EE62824.9090807@parallels.com> <20111212161542.GH18185@fieldses.org>
In-Reply-To: <20111212161542.GH18185@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

12.12.2011 20:15, J. Bruce Fields пишет:
> On Mon, Dec 12, 2011 at 08:13:24PM +0400, Stanislav Kinsbursky wrote:
>> 09.12.2011 00:46, J. Bruce Fields пишет:
>>> On Wed, Dec 07, 2011 at 03:20:07PM +0300, Stanislav Kinsbursky wrote:
>>>> This is another precursor patch set aimed to remove hard-coded "init_net"
>>>> reference from SUNRPC sockaddr convertion and construction routines.
>>>
>>> ACK--all look straightforward.  (Only complaint would be that this isn't
>>> terribly interesting till we see how these are used.)
>>>
>>
>> Actually, all is simple. These init_net pointers will be replaced
>> later by "transports, clients and others" network namespace
>> contexts.
>> I have some more patches for NFS layer. But I don't see any sense to
>> sent them now since no "virtualization" patches were commited yet.
>> So, currently, I'm trying to finalize "SUNRPC per network namespace"
>> task, and soon I'll send a patch set making SUNRPC sysctl's
>> network-namespace-aware. It is a little bit tricky and ugly from my
>> pow, so any ideas are welcome.
>
> No ideas.... What's the ugly part?
>
> --b.

I have some "idée fixe", that all this file system parts of SUNRPC (and NFS) 
layers have to made per network namespace context in the same manner as sysfs 
done. I.e. it's content should depends on mount point creator network namespace 
context instead of "current" one.
But proc (and sysctl's as well) doesn't allow to make it so simple like sysfs does.
So, currently sysctl's code is about 30 lines. With my patches in will be 
approximately 3-4 times longer.
But this "dependence on mount point creator network namespace" goal is achieved.
Anyway, I'll cleanup this code and send path set soon.


-- 
Best regards,
Stanislav Kinsbursky
