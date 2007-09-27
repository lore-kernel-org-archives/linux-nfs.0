From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH][RFC] use after free in NLM subsystem -- how best
 to fix it?
Date: Thu, 27 Sep 2007 15:09:27 -0400
Message-ID: <20070927150927.12d07946.jlayton@redhat.com>
References: <20070924161236.48779845.jlayton@poochiereds.net>
	<1190672003.6700.34.camel@heimdal.trondhjem.org>
	<20070925102501.c770c202.jlayton@redhat.com>
	<1190739948.7330.18.camel@heimdal.trondhjem.org>
	<20070927135938.d5e733c6.jlayton@redhat.com>
	<20070927183803.GF10113@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iayjn-00030k-V2
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 12:09:27 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iayjs-0001yd-H5
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 12:09:33 -0700
In-Reply-To: <20070927183803.GF10113@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 27 Sep 2007 14:38:03 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Sep 27, 2007 at 01:59:38PM -0400, Jeff Layton wrote:
> > Now that I've started really digging into this, I'm thinking that I may
> > be wrong about the race that exists in current mainline. There was a
> > change done ~June 2007:
> > 
> > commit 34f52e3591f241b825353ba27def956d8487c400
> > Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Date:   Thu Jun 14 16:40:31 2007 -0400
> > 
> >     SUNRPC: Convert rpc_clnt->cl_users to a kref
> >     
> >     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > ...this changed nlm_destroy_host from just setting cl_dead to instead
> > use rpc_shutdown_client. So this code now actually kills active RPC
> > tasks for the RPC client and waits for them to come down instead of
> > just marking the client dead. This should mitigate the race that
> > definitely exists in earlier kernels.
> 
> Is there still a window where lockd could be killed just as someone is
> starting a new rpc (but the task isn't yet visible to
> rpc_shutdown_client)?
> 

Perhaps, but I don't think that's the case here. Here is the oops
message:

https://bugzilla.redhat.com/show_bug.cgi?id=253754#c7

It crashed in rpciod while doing svc_wake_up from an async call. Unless
I'm missing something, the only way that could happen is from
nlmsvc_grant_callback. That's the rpc callback from
nlmsvc_grant_blocked, and that function is only ever called from lockd
itself.

So that question becomes:

  Is there still a window where lockd could be killed just as lockd is
  starting a new rpc (but the task isn't yet visible to
  rpc_shutdown_client)?

I'm thinking the answer here is no, since the call would happen near the
top of the event loop, and nlm_shutdown_hosts occurs well after that.

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
