From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 15:53:24 -0600
Message-ID: <20090106215324.GD18147@us.ibm.com>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <20090106202046.GF5901@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:38734 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbZAFVxd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 16:53:33 -0500
In-Reply-To: <20090106202046.GF5901@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting J. Bruce Fields (bfields@fieldses.org):
> On Tue, Jan 06, 2009 at 02:02:29PM -0600, Serge E. Hallyn wrote:
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
> This is just the machine name in the auth_unix credential?  The linux
> server ignores that completely (for the purpose of auth_unix
> authenication, it identifies clients only by source ip address).  I
> suspect other servers also ignore it, but I don't know.

Thanks, that's what i was hoping...

Matt, have you audited the other rpc-based services?  Do any
of them care?

-serge
