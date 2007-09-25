From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH][RFC] use after free in NLM subsystem -- how best
 to fix it?
Date: Tue, 25 Sep 2007 10:25:01 -0400
Message-ID: <20070925102501.c770c202.jlayton@redhat.com>
References: <20070924161236.48779845.jlayton@poochiereds.net>
	<1190672003.6700.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaBLx-0002sT-B4
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 07:25:35 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IaBM2-0001Ql-0v
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 07:25:38 -0700
In-Reply-To: <1190672003.6700.34.camel@heimdal.trondhjem.org>
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

On Mon, 24 Sep 2007 18:13:23 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Mon, 2007-09-24 at 16:12 -0400, Jeff Layton wrote:
> 
> > When a lock that a client is blocking on comes free, lockd does this in
> > nlmsvc_grant_blocked():
> > 
> >     nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG, &nlmsvc_grant_ops);
> > 
> > the callback from this call is nlmsvc_grant_callback(). That function
> > does this at the end to wake up lockd:
> > 
> >     svc_wake_up(block->b_daemon);
> > 
> > ...the problem is, that there is no guarantee that lockd will be up
> > when this happens. If someone shuts down or restarts lockd before the
> > async call completes, then the b_daemon pointer will point to freed
> > memory.
> 
> Why shouldn't we be guaranteeing that lockd is up here?
> 
> Cheers
>   Trond
> 

That's certainly one approach. I avoided that since it seems like it
would add extra complexity -- it would mean reference counting of some
sort. I suppose we could keep a list of async calls that are in
progress and cancel those when lockd begins shutting down. Or is there
an easier way to make sure they are cancelled before lockd goes down?

As a side note, I think we need to consider some locking around
nlmsvc_pid/nlmsvc_serv. This part of lockd seems racy:

        if (!nlmsvc_pid || current->pid == nlmsvc_pid) {
                if (nlmsvc_ops)
                        nlmsvc_invalidate_all();
                nlm_shutdown_hosts();
                nlmsvc_pid = 0;
                nlmsvc_serv = NULL;

if either nlm_invalidate_all or nlm_shutdown_hosts takes a while, and
lockd is being restarted:

1) lockd_down is called and starts shutting down lockd
2) lockd takes a while to come down, lockd_down gives up, and sets
   nlmsvc_pid=0
3) lockd_up is called and fires up a new lockd thread, it sets
   nlmsvc_pid to the new thread's pid
4) first lockd finishes and sets nlmsvc_pid=0

Perhaps we need to have only lockd_down set those vars so that it's
done under the nlmsvc_mutex?

Thoughts?
-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
