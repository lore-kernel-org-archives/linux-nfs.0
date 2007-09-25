From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH][RFC] use after free in NLM subsystem -- how
	best	to fix it?
Date: Tue, 25 Sep 2007 13:05:48 -0400
Message-ID: <1190739948.7330.18.camel@heimdal.trondhjem.org>
References: <20070924161236.48779845.jlayton@poochiereds.net>
	<1190672003.6700.34.camel@heimdal.trondhjem.org>
	<20070925102501.c770c202.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaDrD-0006rO-Ny
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:06:00 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IaDrF-0006Ih-RK
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:06:04 -0700
In-Reply-To: <20070925102501.c770c202.jlayton@redhat.com>
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

On Tue, 2007-09-25 at 10:25 -0400, Jeff Layton wrote:

> That's certainly one approach. I avoided that since it seems like it
> would add extra complexity -- it would mean reference counting of some
> sort. I suppose we could keep a list of async calls that are in
> progress and cancel those when lockd begins shutting down. Or is there
> an easier way to make sure they are cancelled before lockd goes down?

You already have such a list: nlm_blocked.


> As a side note, I think we need to consider some locking around
> nlmsvc_pid/nlmsvc_serv. This part of lockd seems racy:
> 
>         if (!nlmsvc_pid || current->pid == nlmsvc_pid) {
>                 if (nlmsvc_ops)
>                         nlmsvc_invalidate_all();
>                 nlm_shutdown_hosts();
>                 nlmsvc_pid = 0;
>                 nlmsvc_serv = NULL;
> 
> if either nlm_invalidate_all or nlm_shutdown_hosts takes a while, and
> lockd is being restarted:
> 
> 1) lockd_down is called and starts shutting down lockd
> 2) lockd takes a while to come down, lockd_down gives up, and sets
>    nlmsvc_pid=0
> 3) lockd_up is called and fires up a new lockd thread, it sets
>    nlmsvc_pid to the new thread's pid
> 4) first lockd finishes and sets nlmsvc_pid=0
> 
> Perhaps we need to have only lockd_down set those vars so that it's
> done under the nlmsvc_mutex?
> 
> Thoughts?

For cleanliness, I suggest adding a new refcount to lockd: nlmsvc_ref.
Replace the test for (nlmsvc_users || !signalled()) in lockd() with a
test for nlmsvc_ref != 0, and then have lockd_up() take one reference to
it whenever it bumps nlmsvc_users == 0  / lockd_down() release a
reference whenever it decrements nlmsvc_users == 1.

Have nlmsvc_insert_block() take a reference whenever adding something to
an empty nlm_blocked / nlmsvc_unlink_block release the reference
whenever nlm_blocked is emptied.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
