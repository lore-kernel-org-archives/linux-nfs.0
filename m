From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] NFS: SETCLIENTID truncates client ID and netid
Date: Wed, 1 Oct 2008 11:45:34 -0400
Message-ID: <85F8F1FB-E86F-4FE3-B816-FC1D8B5ADAF0@oracle.com>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net> <20080925155712.8353.47707.stgit@manray.1015granger.net> <1222359026.13388.8.camel@localhost> <20080925165821.GA31775@fieldses.org> <25D4D20B-DC01-4864-A583-9A522CB774EC@oracle.com> <20080927000327.GD9889@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41882 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbYJAPpr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Oct 2008 11:45:47 -0400
In-Reply-To: <20080927000327.GD9889@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at Sep 26, 2008, 8:03 PM, J. Bruce Fields wrote:
> On Thu, Sep 25, 2008 at 02:13:11PM -0400, Chuck Lever wrote:
>> On Sep 25, 2008, at 12:58 PM, J. Bruce Fields wrote:
>>> But I'm willing to settle for it and let it be a lesson to us if it
>>> turns out to cause more problems than expected.
>>
>> I will be here to fix it if there is a problem.  In this case, this
>> whole NFS/IPv6 thing is so complicated that I'm implementing just  
>> what
>> is needed as we go along.  We can fill in the niceties at a later  
>> point.
>>
>> /me is taking his cue from "lazy evaluation."
>
> OK, fair enough, barring any other objections.
>
>> Today, if CONFIG_SUNRPC_REGISTER_V4 is enabled and svc_register()  
>> can't
>> contact rpcbind's IPv6 listener and issue a v4 SET request, it  
>> fails and
>> the RPC service is shut down.
>>
>> The only area that might be trouble is when a sysadmin shuts off ALL
>> IPv6 in her network configuration, even if the kernel is build with  
>> IPv6
>> support.  The network layer should do the right thing and map the  
>> IPv6
>> loopback address to the IPv4 loopback address automatically, but I
>> haven't tested this.
>>
>> I'm also not convinced that people will try to install a 2.6 kernel  
>> on a
>> distribution that was built for 2.4 or earlier kernels.  There are  
>> too
>> many missing pieces in the old distributions (like kernel module
>> utilities) to make it easy.  So I'm not trying to make this  
>> compatible
>> with every distribution since the beginning.
>
> Is it 2.4-era distributions that's really the issue?

I'm merely trying to bound the amount of backwards-compatibility that  
we realistically have to worry about.  It could be more recent than  
that, even.

> I thought the userspace rpcbind stuff was still a bit experimental--so
> that when the switchover is made to a kernel that supports rpcbind v4,
> the userspace that's required will be more recent than that.

You can drop libtirpc, rpcbind, and the latest nfs-utils on older  
distributions without much difficulty.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
