From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 15:58:31 -0600
Message-ID: <20090106215831.GE18147@us.ibm.com>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <1231274682.20316.65.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:54876 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbZAFV6k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 16:58:40 -0500
In-Reply-To: <1231274682.20316.65.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Trond Myklebust (trond.myklebust@fys.uio.no):
> On Tue, 2009-01-06 at 14:02 -0600, Serge E. Hallyn wrote:
> > Quoting Matt Helsley (matthltc@us.ibm.com):
> > > We can often specify the UTS namespace to use when starting an RPC client.
> > > However sometimes no UTS namespace is available (specifically during system
> > > shutdown as the last NFS mount in a container is unmounted) so fall
> > > back to the initial UTS namespace.
> > 
> > So what happens if we take this patch and do nothing else?
> > 
> > The only potential problem situation will be rpc requests
> > made on behalf of a container in which the last task has
> > exited, right?  So let's say a container did an nfs mount
> > and then exits, causing an nfs umount request.
> > 
> > That umount request will now be sent with the wrong nodename.
> > Does that actually cause problems, will the server use the
> > nodename to try and determine the client sending the request?
> 
> The NFSv2/v3 umount rpc call will be sent by the 'umount' program from
> userspace, not the kernel. The problem here is that because lazy mounts
> exist, the lifetime of the RPC client may be longer than that of the

Right that was what i was referring to.

> container. In addition, it may be shared among more than 1 container,
> because superblocks can be shared.

Good point.  And in that case what do we care about (even though
apparently we just might not care at all :) - who did the mount,
or who is using it?

In fact one thing I noticed in Matt's patch 3 was that he copied
in the nodename verbatim, so a future hostname() by the container
wouldn't be reflected, again not sure if that would matter.

> One thing you need to be aware of here is that inode dirty data
> writebacks may be initiated by completely different processes than the
> one that dirtied the inode.

Right, but I *was* thinking that we wanted to associate the nodename
on the rpc calls with the hostname of the mounter, not the actor.  Maybe
you'll tell me above that that is bogus.

> IOW: Aside from being extremely ugly, approaches like [PATCH 4/4] which
> rely on being able to determine the container-specific node name at RPC
> generation time are therefore going to return incorrect values.

So should we use patch 2/4, plus (as someone - was it you? - suggested)
using a DEFAULT instead of init_utsname()->nodename when
current->utsname() == NULL?

-serge
