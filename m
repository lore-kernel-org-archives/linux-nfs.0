From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 15:44:42 -0500
Message-ID: <1231274682.20316.65.camel@heimdal.trondhjem.org>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com>  <20090106200229.GA17031@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:52567 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbZAFUow (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 15:44:52 -0500
In-Reply-To: <20090106200229.GA17031@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 14:02 -0600, Serge E. Hallyn wrote:
> Quoting Matt Helsley (matthltc@us.ibm.com):
> > We can often specify the UTS namespace to use when starting an RPC client.
> > However sometimes no UTS namespace is available (specifically during system
> > shutdown as the last NFS mount in a container is unmounted) so fall
> > back to the initial UTS namespace.
> 
> So what happens if we take this patch and do nothing else?
> 
> The only potential problem situation will be rpc requests
> made on behalf of a container in which the last task has
> exited, right?  So let's say a container did an nfs mount
> and then exits, causing an nfs umount request.
> 
> That umount request will now be sent with the wrong nodename.
> Does that actually cause problems, will the server use the
> nodename to try and determine the client sending the request?

The NFSv2/v3 umount rpc call will be sent by the 'umount' program from
userspace, not the kernel. The problem here is that because lazy mounts
exist, the lifetime of the RPC client may be longer than that of the
container. In addition, it may be shared among more than 1 container,
because superblocks can be shared.

One thing you need to be aware of here is that inode dirty data
writebacks may be initiated by completely different processes than the
one that dirtied the inode.
IOW: Aside from being extremely ugly, approaches like [PATCH 4/4] which
rely on being able to determine the container-specific node name at RPC
generation time are therefore going to return incorrect values.

  Trond

