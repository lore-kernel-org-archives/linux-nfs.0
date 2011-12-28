Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43138 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864Ab1L1Ral (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Dec 2011 12:30:41 -0500
Message-ID: <4EFB521B.7060004@parallels.com>
Date: Wed, 28 Dec 2011 21:30:03 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to
 named one
References: <4EFB330A.7070908@parallels.com> <2221B6F7-574A-4CEF-B19F-600932024DEE@oracle.com>
In-Reply-To: <2221B6F7-574A-4CEF-B19F-600932024DEE@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

28.12.2011 21:03, Chuck Lever пишет:
>
> On Dec 28, 2011, at 10:17 AM, Stanislav Kinsbursky wrote:
>
> > Hello.
> > I've experienced a problem with registering Lockd service with rpcbind in 
> container. My container operates in it's own network namespace context and has 
> it's own root. But on service register, kernel tries to connect to named unix 
> socket by using rpciod_workqueue. Thus any connect is done with the same 
> fs->root, and this leads to that kernel socket, used for registering service 
> with local portmapper, will always connect to the same user-space socket 
> regardless to fs->root of process, requested register operation.
> > Possible solution for this problem, which I would like to discuss, is to add 
> one more listening socket to rpcbind process. But this one should be 
> anonymous. Anonymous unix sockets accept connections only within it's network 
> namespace context, so kernel socket connect will be done always to the 
> user-space socket in the same network namespace.
>
> A UNIX socket is used so that rpcbind can record the identity of the process 
> on the other end of the socket.  That way only that user may unregister this 
> service.  That user is known as the registration's "owner."  Whatever solution 
> is chosen, I believe we need to preserve the registration owner functionality.
>

Sorry, but I don't get get it.
What do you mean by "user" and "identity"?

> > Does anyone have any objections to this? Or, probably, better solution for 
> the problem?
>
>
> Isn't this also an issue for TCP connections to other hosts?  How does the 
> kernel RPC client choose a TCP connection's source address?
>

I'm confused here too. What TPC connections are you talking about? And what 
source address?

I little bit more info about the whole "NFS in container" structure (as I see it):
1) Each container operates in it's own network namespace and has it's own root.
2) Each contatiner has it's own network device(s) and IP address(es).
3) Each container has it's own rpcbind process instance.
4) Each service (like LockD and NFSd  in future) will register itself with all 
per-net rpcbind instances it have to.

-- 
Best regards,
Stanislav Kinsbursky
