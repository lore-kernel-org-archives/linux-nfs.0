From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] NFS: SETCLIENTID truncates client ID and netid
Date: Thu, 25 Sep 2008 14:13:11 -0400
Message-ID: <25D4D20B-DC01-4864-A583-9A522CB774EC@oracle.com>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net> <20080925155712.8353.47707.stgit@manray.1015granger.net> <1222359026.13388.8.camel@localhost> <20080925165821.GA31775@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:41688 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbYIYSQM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2008 14:16:12 -0400
In-Reply-To: <20080925165821.GA31775@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 25, 2008, at 12:58 PM, J. Bruce Fields wrote:
> On Thu, Sep 25, 2008 at 12:10:26PM -0400, Trond Myklebust wrote:
>> ACK. I'll take this patch, but should Bruce take the other 2? I  
>> believe
>> he should already have other changes to rpcb_clnt.c in his tree...
>
> Yes I do; I'll take a look.  (My goal is to get through my backlog  
> from
> Trond this afternoon....)
>
>
> I recall one remaining uncertainty about the patches already in my
> for-2.6.28: they allow building either a kernel that supports nfs/ 
> ipv6,
> or a kernel that works with older nfs-utils, but not both.

That's not quite accurate.

The build option enables support for using rpcbindv4 upcalls.   
Otherwise, the kernel will support NFS on IPv6 if CONFIG_IPV6 or  
CONFIG_IPV6_MODULE are enabled, but NFSD and lockd won't start if the  
rpcbind upcall fails.

> I'd prefer a stricter level of backwards compatibility.  The current
> approach may be confusing to distributors, early adopters, and  
> testers.

The issues are spelled out in the help text of  
CONFIG_SUNRPC_REGISTER_V4, and it defaults to legacy behavior.

> But I'm willing to settle for it and let it be a lesson to us if it
> turns out to cause more problems than expected.

I will be here to fix it if there is a problem.  In this case, this  
whole NFS/IPv6 thing is so complicated that I'm implementing just what  
is needed as we go along.  We can fill in the niceties at a later point.

/me is taking his cue from "lazy evaluation."

> Talking to Trond the other day he asked why we couldn't use
> PROG_MISMATCH (unsupported program version) error to fall back.  Chuck
> says in the changelog comment:
>
> 	"I tried adding some automatic logic to fall back if registering
> 	with a v4 protocol request failed, but there are too many corner
> 	cases."
>
> Which I can believe, though I haven't looked at it myself.

Here's what I can remember right off the top of my head:

1.  The kernel has to detect whether the local rpcbind has an IPv6  
listener or not.

2.  The kernel has to detect whether user space has configured an IPv6  
loopback address.

3.  The kernel has to detect whether the local rpcbind speaks rpcbind  
v4.

Today, if CONFIG_SUNRPC_REGISTER_V4 is enabled and svc_register()  
can't contact rpcbind's IPv6 listener and issue a v4 SET request, it  
fails and the RPC service is shut down.

The only area that might be trouble is when a sysadmin shuts off ALL  
IPv6 in her network configuration, even if the kernel is build with  
IPv6 support.  The network layer should do the right thing and map the  
IPv6 loopback address to the IPv4 loopback address automatically, but  
I haven't tested this.

I'm also not convinced that people will try to install a 2.6 kernel on  
a distribution that was built for 2.4 or earlier kernels.  There are  
too many missing pieces in the old distributions (like kernel module  
utilities) to make it easy.  So I'm not trying to make this compatible  
with every distribution since the beginning.

> In any case I'd like Trond's ACK or NACK.
>
> --b.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
