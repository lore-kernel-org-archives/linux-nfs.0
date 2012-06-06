Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:38077 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab2FFIi6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jun 2012 04:38:58 -0400
Message-ID: <4FCF171B.8000207@parallels.com>
Date: Wed, 6 Jun 2012 12:38:51 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: <linux-fsdevel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
CC: <cgroups@vger.kernel.org>, <containers@lists.linux-foundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        James Bottomley <jbottomley@parallels.com>,
        "devel@openvz.org" <devel@openvz.org>
Subject: [RFC] connectat() and bindat() system calls
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.
I'd really appreciate for any comments on subj - implementation of new system 
call: connectat and bindat.

Reasons for new system calls:
1) Path length for UNIX sockets is limited to 108 symbols.
Syscalls are useful as is since removes limitation.

2) Ability to perform connect/bind calls to UNIX sockets starting from specified 
path in kernel.
This is required for proper support of kernel connect operations in SUNRPC 
layer. Which, in turn, required for proper support of NFS in containers.

These system calls could be used only for non-abstract UNIX sockets, obviously.

Possible implementation could be adding of struct path pointer to sockaddr_un.
But this pointer have to valid only for connect and bind calls, and caller have 
to hold and release path by himself.

-- 
Best regards,
Stanislav Kinsbursky
