Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:52815 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759187Ab2HJSQQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 14:16:16 -0400
Message-ID: <50254FA6.3060806@zytor.com>
Date: Fri, 10 Aug 2012 11:15:02 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: Trond.Myklebust@netapp.com, davem@davemloft.net, linux-nfs@vger.kernel.org,
        eric.dumazet@gmail.com, xemul@parallels.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bfields@fieldses.org,
        viro@zeniv.linux.org.uk, tim.c.chen@linux.intel.com, devel@openvz.org
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
References: <20120810125701.7115.71612.stgit@localhost.localdomain>
In-Reply-To: <20120810125701.7115.71612.stgit@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2012 05:57 AM, Stanislav Kinsbursky wrote:
> Today, there is a problem in connecting of local SUNRPC thansports. These
> transports uses UNIX sockets and connection itself is done by rpciod
> workqueue.
> But UNIX sockets lookup is done in context of process file system root. I.e.
> all local thunsports are connecting in rpciod context.
> This works nice until we will try to mount NFS from process with other root -
> for example in container. This container can have it's own (nested) root and
> rcpbind process, listening on it's own unix sockets. But NFS mount attempt in
> this container will register new service (Lockd for example) in global rpcbind
> - not containers's one.
> 
> This patch set introduces kernel connect helper for UNIX stream sockets and
> modifies unix_find_other() to be able to search from specified root.
> It also replaces generic socket connect call for local transports by new
> helper in SUNRPC layer.
> 
> The following series implements...

On that whole subject...

Do we need a Unix domain socket equivalent to openat()?

	-hpa

