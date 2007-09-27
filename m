From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH][RFC] use after free in NLM subsystem -- how best
 to fix it?
Date: Thu, 27 Sep 2007 13:59:38 -0400
Message-ID: <20070927135938.d5e733c6.jlayton@redhat.com>
References: <20070924161236.48779845.jlayton@poochiereds.net>
	<1190672003.6700.34.camel@heimdal.trondhjem.org>
	<20070925102501.c770c202.jlayton@redhat.com>
	<1190739948.7330.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaxeF-0003iW-Iz
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 10:59:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IaxeJ-00089j-PG
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 10:59:44 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l8RHxeWo003332
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 27 Sep 2007 13:59:40 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l8RHxeuG028097
	for <nfs@lists.sourceforge.net>; Thu, 27 Sep 2007 13:59:40 -0400
Received: from tleilax.poochiereds.net (vpn-14-92.rdu.redhat.com [10.11.14.92])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l8RHxd9C003365
	for <nfs@lists.sourceforge.net>; Thu, 27 Sep 2007 13:59:39 -0400
In-Reply-To: <1190739948.7330.18.camel@heimdal.trondhjem.org>
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

On Tue, 25 Sep 2007 13:05:48 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Tue, 2007-09-25 at 10:25 -0400, Jeff Layton wrote:
> 
> > That's certainly one approach. I avoided that since it seems like it
> > would add extra complexity -- it would mean reference counting of some
> > sort. I suppose we could keep a list of async calls that are in
> > progress and cancel those when lockd begins shutting down. Or is there
> > an easier way to make sure they are cancelled before lockd goes down?
> 
> You already have such a list: nlm_blocked.
> 
> 
> > As a side note, I think we need to consider some locking around
> > nlmsvc_pid/nlmsvc_serv. This part of lockd seems racy:
> > 
> >         if (!nlmsvc_pid || current->pid == nlmsvc_pid) {
> >                 if (nlmsvc_ops)
> >                         nlmsvc_invalidate_all();
> >                 nlm_shutdown_hosts();
> >                 nlmsvc_pid = 0;
> >                 nlmsvc_serv = NULL;
> > 
> > if either nlm_invalidate_all or nlm_shutdown_hosts takes a while, and
> > lockd is being restarted:
> > 
> > 1) lockd_down is called and starts shutting down lockd
> > 2) lockd takes a while to come down, lockd_down gives up, and sets
> >    nlmsvc_pid=0
> > 3) lockd_up is called and fires up a new lockd thread, it sets
> >    nlmsvc_pid to the new thread's pid
> > 4) first lockd finishes and sets nlmsvc_pid=0
> > 
> > Perhaps we need to have only lockd_down set those vars so that it's
> > done under the nlmsvc_mutex?
> > 
> > Thoughts?
> 
> For cleanliness, I suggest adding a new refcount to lockd: nlmsvc_ref.
> Replace the test for (nlmsvc_users || !signalled()) in lockd() with a
> test for nlmsvc_ref != 0, and then have lockd_up() take one reference to
> it whenever it bumps nlmsvc_users == 0  / lockd_down() release a
> reference whenever it decrements nlmsvc_users == 1.
> 
> Have nlmsvc_insert_block() take a reference whenever adding something to
> an empty nlm_blocked / nlmsvc_unlink_block release the reference
> whenever nlm_blocked is emptied.
> 
> Trond
> 

Now that I've started really digging into this, I'm thinking that I may
be wrong about the race that exists in current mainline. There was a
change done ~June 2007:

commit 34f52e3591f241b825353ba27def956d8487c400
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 14 16:40:31 2007 -0400

    SUNRPC: Convert rpc_clnt->cl_users to a kref
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

...this changed nlm_destroy_host from just setting cl_dead to instead
use rpc_shutdown_client. So this code now actually kills active RPC
tasks for the RPC client and waits for them to come down instead of
just marking the client dead. This should mitigate the race that
definitely exists in earlier kernels.

I have seen a crash on recent kernels that looks very similar to the
problem that I originally described. Somehow a nlmsvc_grant_callback
outlived its lockd. I've only seen it once though, so I think I have to
conclude that the race there is something different and much more
subtle.

Adding reference counting might still be the way to go, but it's
not clear to me that basing it on adding and removing from the
nlm_blocked list will eliminate whatever this race is.

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
