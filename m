From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] NFS: SETCLIENTID truncates client ID and netid
Date: Fri, 26 Sep 2008 20:03:27 -0400
Message-ID: <20080927000327.GD9889@fieldses.org>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net> <20080925155712.8353.47707.stgit@manray.1015granger.net> <1222359026.13388.8.camel@localhost> <20080925165821.GA31775@fieldses.org> <25D4D20B-DC01-4864-A583-9A522CB774EC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35156 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471AbYI0ADa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 20:03:30 -0400
In-Reply-To: <25D4D20B-DC01-4864-A583-9A522CB774EC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2008 at 02:13:11PM -0400, Chuck Lever wrote:
> On Sep 25, 2008, at 12:58 PM, J. Bruce Fields wrote:
>> But I'm willing to settle for it and let it be a lesson to us if it
>> turns out to cause more problems than expected.
>
> I will be here to fix it if there is a problem.  In this case, this  
> whole NFS/IPv6 thing is so complicated that I'm implementing just what  
> is needed as we go along.  We can fill in the niceties at a later point.
>
> /me is taking his cue from "lazy evaluation."

OK, fair enough, barring any other objections.

> Today, if CONFIG_SUNRPC_REGISTER_V4 is enabled and svc_register() can't 
> contact rpcbind's IPv6 listener and issue a v4 SET request, it fails and 
> the RPC service is shut down.
>
> The only area that might be trouble is when a sysadmin shuts off ALL  
> IPv6 in her network configuration, even if the kernel is build with IPv6 
> support.  The network layer should do the right thing and map the IPv6 
> loopback address to the IPv4 loopback address automatically, but I 
> haven't tested this.
>
> I'm also not convinced that people will try to install a 2.6 kernel on a 
> distribution that was built for 2.4 or earlier kernels.  There are too 
> many missing pieces in the old distributions (like kernel module  
> utilities) to make it easy.  So I'm not trying to make this compatible  
> with every distribution since the beginning.

Is it 2.4-era distributions that's really the issue?

I thought the userspace rpcbind stuff was still a bit experimental--so
that when the switchover is made to a kernel that supports rpcbind v4,
the userspace that's required will be more recent than that.

Just curious.

--b.
