Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:45688 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab1L1RDu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Dec 2011 12:03:50 -0500
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to named one
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4EFB330A.7070908@parallels.com>
Date: Wed, 28 Dec 2011 12:03:37 -0500
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <2221B6F7-574A-4CEF-B19F-600932024DEE@oracle.com>
References: <4EFB330A.7070908@parallels.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 28, 2011, at 10:17 AM, Stanislav Kinsbursky wrote:

> Hello.
> I've experienced a problem with registering Lockd service with rpcbind in container. My container operates in it's own network namespace context and has it's own root. But on service register, kernel tries to connect to named unix socket by using rpciod_workqueue. Thus any connect is done with the same fs->root, and this leads to that kernel socket, used for registering service with local portmapper, will always connect to the same user-space socket regardless to fs->root of process, requested register operation.
> Possible solution for this problem, which I would like to discuss, is to add one more listening socket to rpcbind process. But this one should be anonymous. Anonymous unix sockets accept connections only within it's network namespace context, so kernel socket connect will be done always to the user-space socket in the same network namespace.

A UNIX socket is used so that rpcbind can record the identity of the process on the other end of the socket.  That way only that user may unregister this service.  That user is known as the registration's "owner."  Whatever solution is chosen, I believe we need to preserve the registration owner functionality.

> Does anyone have any objections to this? Or, probably, better solution for the problem?


Isn't this also an issue for TCP connections to other hosts?  How does the kernel RPC client choose a TCP connection's source address?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




