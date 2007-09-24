From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH][RFC] use after free in NLM subsystem -- how
	best	to fix it?
Date: Mon, 24 Sep 2007 18:13:23 -0400
Message-ID: <1190672003.6700.34.camel@heimdal.trondhjem.org>
References: <20070924161236.48779845.jlayton@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@poochiereds.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZwBF-0000wg-Jq
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 15:13:29 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZwBJ-0003mZ-86
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 15:13:34 -0700
In-Reply-To: <20070924161236.48779845.jlayton@poochiereds.net>
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

On Mon, 2007-09-24 at 16:12 -0400, Jeff Layton wrote:

> When a lock that a client is blocking on comes free, lockd does this in
> nlmsvc_grant_blocked():
> 
>     nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG, &nlmsvc_grant_ops);
> 
> the callback from this call is nlmsvc_grant_callback(). That function
> does this at the end to wake up lockd:
> 
>     svc_wake_up(block->b_daemon);
> 
> ...the problem is, that there is no guarantee that lockd will be up
> when this happens. If someone shuts down or restarts lockd before the
> async call completes, then the b_daemon pointer will point to freed
> memory.

Why shouldn't we be guaranteeing that lockd is up here?

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
