Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:8865 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752875Ab1L1PSA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Dec 2011 10:18:00 -0500
Message-ID: <4EFB330A.7070908@parallels.com>
Date: Wed, 28 Dec 2011 19:17:30 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [RFC] RPCBIND: add anonymous listening socket in addition to named
 one
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.
I've experienced a problem with registering Lockd service with rpcbind in 
container. My container operates in it's own network namespace context and has 
it's own root. But on service register, kernel tries to connect to named unix 
socket by using rpciod_workqueue. Thus any connect is done with the same 
fs->root, and this leads to that kernel socket, used for registering service 
with local portmapper, will always connect to the same user-space socket 
regardless to fs->root of process, requested register operation.
Possible solution for this problem, which I would like to discuss, is to add one 
more listening socket to rpcbind process. But this one should be anonymous. 
Anonymous unix sockets accept connections only within it's network namespace 
context, so kernel socket connect will be done always to the user-space socket 
in the same network namespace.
Does anyone have any objections to this? Or, probably, better solution for the 
problem?

-- 
Best regards,
Stanislav Kinsbursky
