From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RPC service registration timeout
Date: Fri, 4 Apr 2008 13:24:45 -0400
Message-ID: <5FB57651-D32A-403C-B9CA-48FA9DCFE4EF@oracle.com>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com> <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:35926 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860AbYDDTi3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Apr 2008 15:38:29 -0400
In-Reply-To: <EXNANE01XvpFVjCRGry00000233-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tom-

On Apr 4, 2008, at 12:49 PM, Talpey, Thomas wrote:
> I think a second or two is way too short, but I do wonder if it can't
> issue the unregisters asynchronously, and in parallel.

You would have to parallelize the setup of the lockd and nfsd  
services.  Ie this would be a ULP change.  Doable, but complicated.

Can you say why you think two seconds is too short for a local host  
operation?

> Then it can
> wait for them all, with a timeout maybe on the order of 10 to 15
> seconds. A couple of retries while waiting sounds reasonable.

The current situation is a 5 second timeout, followed by 10, then  
20.  Even shortening the initial timeout would be helpful, or making  
it not do exponential backoff.

NFSD is usually started during system boot.  If there are problems  
like this, it looks like a boot hang.

> Making the wait interruptible seems dicey. Once the deregistration
> is started, it seems like it should always make a best attempt to
> complete it.

If you interrupt a script like /etc/init.d/nfs, you will just have to  
re-run it, and it will try the unregistration again.  I'm not sure  
what you protect by making unregistration uninterruptible.

This may be an undesired artifact of neutering "intr" in 2.6.25.

> Also, nfsd is usually started as a service, so there's
> not likely to be a user.

The system actually does throw an "ICMP port unreachable" if the  
daemon isn't listening.  The problem is this never gets back to the  
RPC client.  Even if it did, what's the correct thing to do?

> At 12:38 PM 4/4/2008, Chuck Lever wrote:
>> Registering a local RPC service has a long timeout.
>>
>> When starting the NFSD service, for example, the RPC server wants to
>> unregister at least 6 different RPC services (three versions of NFS
>> and three versions of lockd) before it even tries to register the
>> services it's bringing up.
>>
>> Usually this isnt' a problem.  However, if a portmapper or rpcbind
>> daemon isn't running, each one of these registrations causes a long
>> wait (up to a minute each, I think) while the RPC server attempts to
>> contact the rpcbind daemon at localhost.
>>
>> I don't think this wait is interruptible, either.
>>
>> I'm wondering if this long timeout is really necessary.  Can we get
>> by with a second or so, and a couple of retries?
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



