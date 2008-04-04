From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: RPC service registration timeout
Date: Fri, 04 Apr 2008 12:49:37 -0400
Message-ID: <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51686 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228AbYDDQue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2008 12:50:34 -0400
In-Reply-To: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think a second or two is way too short, but I do wonder if it can't
issue the unregisters asynchronously, and in parallel. Then it can
wait for them all, with a timeout maybe on the order of 10 to 15
seconds. A couple of retries while waiting sounds reasonable.

Making the wait interruptible seems dicey. Once the deregistration
is started, it seems like it should always make a best attempt to
complete it. Also, nfsd is usually started as a service, so there's
not likely to be a user.

Tom.

At 12:38 PM 4/4/2008, Chuck Lever wrote:
>Registering a local RPC service has a long timeout.
>
>When starting the NFSD service, for example, the RPC server wants to  
>unregister at least 6 different RPC services (three versions of NFS  
>and three versions of lockd) before it even tries to register the  
>services it's bringing up.
>
>Usually this isnt' a problem.  However, if a portmapper or rpcbind  
>daemon isn't running, each one of these registrations causes a long  
>wait (up to a minute each, I think) while the RPC server attempts to  
>contact the rpcbind daemon at localhost.
>
>I don't think this wait is interruptible, either.
>
>I'm wondering if this long timeout is really necessary.  Can we get  
>by with a second or so, and a couple of retries?

