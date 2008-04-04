From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RPC service registration timeout
Date: Fri, 04 Apr 2008 13:28:23 -0400
Message-ID: <1207330103.11655.3.camel@heimdal.trondhjem.org>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
	 <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15123 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024AbYDDR3x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2008 13:29:53 -0400
In-Reply-To: <EXNANE01XvpFVjCRGry00000233-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-04-04 at 12:49 -0400, Talpey, Thomas wrote:
> I think a second or two is way too short, but I do wonder if it can't
> issue the unregisters asynchronously, and in parallel. Then it can
> wait for them all, with a timeout maybe on the order of 10 to 15
> seconds. A couple of retries while waiting sounds reasonable.
> 
> Making the wait interruptible seems dicey. Once the deregistration
> is started, it seems like it should always make a best attempt to
> complete it. Also, nfsd is usually started as a service, so there's
> not likely to be a user.

I'd say that making the RPC call asynchronous, but doing an
interruptible wait on completion is probably the best solution.

Making the process entirely asynchronous can be problematic if you
decide to restart the service due to the potential for reordering
between the unregister/register RPC calls.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
