Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:20344 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437Ab1L2LtV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Dec 2011 06:49:21 -0500
Message-ID: <4EFC539E.4050008@parallels.com>
Date: Thu, 29 Dec 2011 15:48:46 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to
 named one
References: <4EFB330A.7070908@parallels.com> <20111228182213.GA10220@fieldses.org>
In-Reply-To: <20111228182213.GA10220@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

28.12.2011 22:22, bfields@fieldses.org пишет:
> On Wed, Dec 28, 2011 at 07:17:30PM +0400, Stanislav Kinsbursky wrote:
>> I've experienced a problem with registering Lockd service with
>> rpcbind in container. My container operates in it's own network
>> namespace context and has it's own root. But on service register,
>> kernel tries to connect to named unix socket by using
>> rpciod_workqueue. Thus any connect is done with the same fs->root,
>
> There's no way to pass the correct context down to the rpc task and from
> there to the registration code?
>

This context is current->fs->root. It's used to lookup unix socket inode by name 
on connect.
Obviously, current is always "rpciod_workqueue" kernel thread. And thus has the 
same root.
The only solution how to pass and use the context, which I can see, is to expand 
sock_xprt with a pointer to corrent root and then set this root before 
kernel_connect() and set the old one after.
But this looks ugly and too complicated for the issue, from my pow.
Or maybe you have some more elegant solution to this problem?

-- 
Best regards,
Stanislav Kinsbursky
