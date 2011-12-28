Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38861 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045Ab1L1SWQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Dec 2011 13:22:16 -0500
Date: Wed, 28 Dec 2011 13:22:13 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to
 named one
Message-ID: <20111228182213.GA10220@fieldses.org>
References: <4EFB330A.7070908@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EFB330A.7070908@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 28, 2011 at 07:17:30PM +0400, Stanislav Kinsbursky wrote:
> I've experienced a problem with registering Lockd service with
> rpcbind in container. My container operates in it's own network
> namespace context and has it's own root. But on service register,
> kernel tries to connect to named unix socket by using
> rpciod_workqueue. Thus any connect is done with the same fs->root,

There's no way to pass the correct context down to the rpc task and from
there to the registration code?

--b.

> and this leads to that kernel socket, used for registering service
> with local portmapper, will always connect to the same user-space
> socket regardless to fs->root of process, requested register
> operation.
> Possible solution for this problem, which I would like to discuss,
> is to add one more listening socket to rpcbind process. But this one
> should be anonymous. Anonymous unix sockets accept connections only
> within it's network namespace context, so kernel socket connect will
> be done always to the user-space socket in the same network
> namespace.
> Does anyone have any objections to this? Or, probably, better
> solution for the problem?
> 
> -- 
> Best regards,
> Stanislav Kinsbursky
