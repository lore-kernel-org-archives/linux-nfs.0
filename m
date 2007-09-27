From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH][RFC] use after free in NLM subsystem -- how
	best	to fix it?
Date: Thu, 27 Sep 2007 14:38:03 -0400
Message-ID: <20070927183803.GF10113@fieldses.org>
References: <20070924161236.48779845.jlayton@poochiereds.net>
	<1190672003.6700.34.camel@heimdal.trondhjem.org>
	<20070925102501.c770c202.jlayton@redhat.com>
	<1190739948.7330.18.camel@heimdal.trondhjem.org>
	<20070927135938.d5e733c6.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IayFO-00087n-G6
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 11:38:02 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IayFS-0001A6-1t
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 11:38:07 -0700
In-Reply-To: <20070927135938.d5e733c6.jlayton@redhat.com>
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

On Thu, Sep 27, 2007 at 01:59:38PM -0400, Jeff Layton wrote:
> Now that I've started really digging into this, I'm thinking that I may
> be wrong about the race that exists in current mainline. There was a
> change done ~June 2007:
> 
> commit 34f52e3591f241b825353ba27def956d8487c400
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu Jun 14 16:40:31 2007 -0400
> 
>     SUNRPC: Convert rpc_clnt->cl_users to a kref
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> ...this changed nlm_destroy_host from just setting cl_dead to instead
> use rpc_shutdown_client. So this code now actually kills active RPC
> tasks for the RPC client and waits for them to come down instead of
> just marking the client dead. This should mitigate the race that
> definitely exists in earlier kernels.

Is there still a window where lockd could be killed just as someone is
starting a new rpc (but the task isn't yet visible to
rpc_shutdown_client)?

--b.

> I have seen a crash on recent kernels that looks very similar to the
> problem that I originally described. Somehow a nlmsvc_grant_callback
> outlived its lockd. I've only seen it once though, so I think I have to
> conclude that the race there is something different and much more
> subtle.
> 
> Adding reference counting might still be the way to go, but it's
> not clear to me that basing it on adding and removing from the
> nlm_blocked list will eliminate whatever this race is.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
