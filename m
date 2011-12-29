Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:27475 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754227Ab1L2QXw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Dec 2011 11:23:52 -0500
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to named one
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4EFC9189.5040605@parallels.com>
Date: Thu, 29 Dec 2011 11:23:40 -0500
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <56767BFA-62B8-4E10-B9B3-4FD9EF278969@oracle.com>
References: <4EFB330A.7070908@parallels.com> <2221B6F7-574A-4CEF-B19F-600932024DEE@oracle.com> <4EFB521B.7060004@parallels.com> <406C7E87-0CCB-4034-8FD8-1602F7DCDBD6@oracle.com> <4EFC5391.7000601@parallels.com> <5E291DB3-7FB3-4108-B254-B59780C64346@oracle.com> <4EFC9189.5040605@parallels.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 29, 2011, at 11:12 AM, Stanislav Kinsbursky wrote:

> 29.12.2011 20:03, Chuck Lever пишет:
>>> Because unix named (!) sockets are not network namespace aware.
>> 
>> OK, this is the part I was unaware of.  Bruce and I had talked about this a few months ago, and my take-away was that these sockets were network namespace-aware, such that this was supposed to work as we want, already.
>> 
>>> They are "current->fs->root" aware.
>> 
>> In other words, these are relative to the local file namespace, not the local network namespace.  I was afraid of that.
>> 
>>> I.e. if this connect operation would be performed on "sync mode" (i.e. from the context of mount of NFS server start operation), then all will works fine (in case of each container works in it's own root, of course).
>>> But currently all connect operations are done by rpciod_workqueue. I.e. regardless to root of process, started service registration, unix socket will be always looked up by path "/var/run/rpcbind.sock" starting from rpciod_workqueue root. I can set desired root before kernel connect during handling RPC task by rpciod_workqueue and revert back to the old one after connection and this will solve the problem to.
>>> But this approach looks like ugly hack to me. And also requires additional pointer in sock_xprt structure to bypass desired context to rpciod_workqueue handler.
>> 
>> Can several network namespaces share the same file namespace?  That might cause them to share the same rpcbind, which is undesirable.  Might this also be a problem for user space?
>> 
> 
> Yes, they can. But only in general. And it will be a problem for user space programs, using unix named sockets for network related stuff (like rpcbind, for instance).
> But, actually, I don't see any sense in having several network namespaces with the same root. Probably someone can suggest a specific "real life" solution, which can use such scheme.

I can't think of one either.

> But it's not a container and thus no guarantees should be provided in this case from my pow.

That's probably reasonable, and should be documented publicly if we take the approach of keeping a unique /var/run/rpcbind.sock for each network namespace.

> Or we need to throw away this unix sockets approach and use only network namespace aware routines. But again, does this really required?

/var/run/rpcbind.sock is a formal libtirpc/rpcbind API that is common to libtirpc on other OSes.  Now, it's not likely that any application except the kernel uses it directly.  Still, I'm leery of removing it entirely. 

My sense is that handing an fs->root value to the rpciod workqueue gives us behavior that is closest to what we have now in a single network namespace configuration.  In other words, it's a change that introduces the least amount of "surprise" to the current RPC architecture.

Do you have a patch so we can see just how ugly this might get?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




