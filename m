From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Use AF_INET6 NFSv4 callback listener only if IPv6 is built in
Date: Wed, 4 Feb 2009 15:09:07 -0500
Message-ID: <A0EFF4F5-F492-43AA-A1C2-AEC1CACDC036@oracle.com>
References: <20090204164857.26771.31809.stgit@ingres.1015granger.net> <96EEB7FB-3E36-4F1C-8570-D2A6BB758A79@oracle.com> <1233772405.7161.45.camel@heimdal.trondhjem.org> <8D75C60F-AA91-46B6-B9AA-C679417C4948@oracle.com> <1233776361.7161.67.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:41404 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756951AbZBDUJS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 15:09:18 -0500
In-Reply-To: <1233776361.7161.67.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 4, 2009, at Feb 4, 2009, 2:39 PM, Trond Myklebust wrote:
> On Wed, 2009-02-04 at 14:04 -0500, Chuck Lever wrote:
>> On Feb 4, 2009, at Feb 4, 2009, 1:33 PM, Trond Myklebust wrote:
>>> On Wed, 2009-02-04 at 11:56 -0500, Chuck Lever wrote:
>>>> Sorry, "fixing" is a bit too strong.  I mean working around the  
>>>> issue
>>>> until we have a long-term solution.
>>>
>>> This isn't an acceptable workaround, since it causes a regression  
>>> for
>>> those people who do have IPv6 enabled as a module. i.e. me...
>>
>> Don't you just get normal AF_INET callbacks in that case?
>>
>> Is the problem that you are using an IPv6 mount address, and want to
>> ensure your callback service and lockd are listening on AF_INET6?
>> That dependency web is a problem, and for a workaround we can also
>> disable IPv6 mounts if IPv6 support is built as a module.
>>
>>> The real problem here is the existence of serv->sv_family, which
>>> basically means that we need to decide whether or not we want IPv6
>>> functionality when we set up the server, instead of when we set up  
>>> the
>>> transport. Why do we need this in the first place?
>>
>> 1.  we don't want to create an AF_INET6 listener for kernel RPC
>> services that can't yet support it (ie just NFSD at this point).
>
> I'm not advocating changing all sockets to AF_INET6. I'm advocating
> adding a socket family parameter to svc_create_xprt() so that
> IPv6-capable services like nfs_callback_up() can first try to set up
> service using AF_INET6 socket, then fall back to calling
> svc_create_xprt() again with AF_INET in case of ipv6 service failure.

I think we're on the same wavelength there, and we can get rid of the  
nfs_callback_family thingie.

Steve took a similar approach with lockd, but again, we have a web of  
dependencies that needs to be addressed.  It may be enough that the  
client will balk at an IPv6 server in a mount request before we even  
get to the point of a lockd_up/nfs_callback_up.

>> 2.  svc_create() handles rpcbind registration, so it needs to know
>> whether to register both inet and inet6 netids or just inet.  Maybe  
>> we
>> should move the svc_register call to svc_create_xprt() ?
>
> Where does svc_create() do rpcbind? AFAICS, svc_register is called by
> svc_setup_socket(), which again is called by svc_create_xprt(). You've
> got to set up the listening socket before you can register the service
> with rpcbind, so I can't see how it could be done any other way.

Sorry, I misspoke.

svc_register is invoked with an sv_serv.  Most of these socket setup  
functions have an sv_serv argument, so it seemed easier to add a field  
in sv_serv rather than another argument to a bunch of functions.   
There may be some other reason I did it this way, but I'm not  
remembering it right at the moment.

In any event, I can look at removing sv_family and using some other  
mechanism for identifying the address family of the listener.

>> 3.  sock_create(AF_INET6) would pin ipv6.ko, but NFSD allows listener
>> sockets to come and go.  I would rather just pin ipv6.ko for the
>> duration, and unpin it in svc_destroy.  Again, svc_create_xprt might
>> be a place to do that.
>
> It's the obvious place, since that's what creates and destroys the
> socket.

I want to look at the lifetime of these transports to make sure we  
don't have gaps where ipv6.ko could be unloaded, with confusing  
consequences.  Otherwise, this sounds fine.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
