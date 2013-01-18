Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54442 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799Ab3ARP4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2013 10:56:33 -0500
Date: Fri, 18 Jan 2013 10:56:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <kernel@teksavvy.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
Message-ID: <20130118155631.GA5227@fieldses.org>
References: <50F4D800.5040703@teksavvy.com>
 <20130115205625.GH4940@fieldses.org>
 <50F63882.8000607@parallels.com>
 <50F72F03.5070806@teksavvy.com>
 <50F786AF.4070107@parallels.com>
 <20130117130335.GD6598@fieldses.org>
 <50F7FB7E.2020503@parallels.com>
 <50F88C14.7030903@teksavvy.com>
 <50F8DF7E.8080107@parallels.com>
 <50F96EB2.3090605@teksavvy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50F96EB2.3090605@teksavvy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 18, 2013 at 10:48:02AM -0500, Mark Lord wrote:
> On 13-01-18 12:37 AM, Stanislav Kinsbursky wrote:
> >
> > You have more than one NFS mount in different network namespaces, haven't you?
> >
> 
> No, I don't (knowingly) use (multiple) namespaces at all.

Right, I don't think that's necessary.  Stanislav, look at
nfs_callback_down:

	nfs_callback_down_net(minorversion, cb_info->serv, net);
        cb_info->users--;
	if (cb_info->users == 0 && cb_info->task != NULL) {
		kthread_stop(cb_info->task);
		...

It's first destroying the service, then destroying the thread.  That's
the wrong order.  So we could still have the thread running svc_recv()
after the rpc service is destroyed.

--b.

> Usually I disable them in the kernel .config,
> though it appears the currently running kernel has this:
> 
> CONFIG_NAMESPACES=y
> # CONFIG_UTS_NS is not set
> # CONFIG_IPC_NS is not set
> # CONFIG_PID_NS is not set
> # CONFIG_NET_NS is not set
> 
> The full .config was attached to the first post in this thread.
> 
> Cheers
> 
