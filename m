From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 14:43:47 -0800
Message-ID: <1231281827.14345.106.camel@localhost>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com>
	 <20090106202046.GF5901@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
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
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38899 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580AbZAFXaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 18:30:39 -0500
In-Reply-To: <20090106202046.GF5901@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 15:20 -0500, J. Bruce Fields wrote:
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
> 
> --b.

I was wondering about this because I kept coming back to the question of
how the server could trust the name the client supplies (seems it
can't). This is very useful information -- it certainly suggests that
this patch would be sufficient.

Thanks!

Cheers,
	-Matt Helsley

> > 
> > thanks,
> > -serge
> > 
> > > Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
> > > Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> > > Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
> > > Cc: linux-nfs@vger.kernel.org
> > > Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
> > > Cc: Chuck Lever <chuck.lever@oracle.com>
> > > Cc: Eric W. Biederman <ebiederm@xmission.com>
> > > Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
> > > 
> > > ---
> > >  net/sunrpc/clnt.c |    7 +++++--
> > >  1 file changed, 5 insertions(+), 2 deletions(-)
> > > 
> > > Index: linux-2.6.28/net/sunrpc/clnt.c
> > > ===================================================================
> > > --- linux-2.6.28.orig/net/sunrpc/clnt.c
> > > +++ linux-2.6.28/net/sunrpc/clnt.c
> > > @@ -128,6 +128,7 @@ static struct rpc_clnt * rpc_new_client(
> > >  	struct rpc_version	*version;
> > >  	struct rpc_clnt		*clnt = NULL;
> > >  	struct rpc_auth		*auth;
> > > +	struct new_utsname	*uts_ns = init_utsname();
> > >  	int err;
> > >  	size_t len;
> > > 
> > > @@ -213,10 +214,12 @@ static struct rpc_clnt * rpc_new_client(
> > >  	}
> > > 
> > >  	/* save the nodename */
> > > -	clnt->cl_nodelen = strlen(init_utsname()->nodename);
> > > +	if (current->nsproxy != NULL)
> > > +		uts_ns = utsname();
> > > +	clnt->cl_nodelen = strlen(uts_ns->nodename);
> > >  	if (clnt->cl_nodelen > UNX_MAXNODENAME)
> > >  		clnt->cl_nodelen = UNX_MAXNODENAME;
> > > -	memcpy(clnt->cl_nodename, init_utsname()->nodename, clnt->cl_nodelen);
> > > +	memcpy(clnt->cl_nodename, uts_ns->nodename, clnt->cl_nodelen);
> > >  	rpc_register_client(clnt);
> > >  	return clnt;
> > > 
> > > 
> > > -- 
> > > _______________________________________________
> > > Containers mailing list
> > > Containers@lists.linux-foundation.org
> > > https://lists.linux-foundation.org/mailman/listinfo/containers

