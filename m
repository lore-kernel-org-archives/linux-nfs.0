From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 3 strange things in the lockd code ?
Date: 08 Apr 2002 14:06:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8z7yo0ml.fsf@charged.uio.no>
References: <20020404194238.E25342@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uXvo-0004uH-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 05:07:32 -0700
To: Dumas Patrice <dumas@centre-cired.fr>
In-Reply-To: <20020404194238.E25342@zeus.centre-cired.fr>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Dumas Patrice <dumas@centre-cired.fr> writes:

     > My understanding is that in nlmsvc_grant_blocked there is a
     > callback to the client with NLMPROC_GRANTED_MSG, the client get
     > the callback using nlmsvc_proc_granted_msg which in turn sends
     > NLMPROC_GRANTED_RES (and also which triggers
     > nlmsvc_grant_callback which only rescuedule block). The server
     > receive and responds to the callback, but it is
     > nlmsvc_proc_null.

     > I may be totally wrong, but it seems to me that
     > nlmsvc_proc_granted_res should instead call nlmsvc_grant_reply
     > to delete the block. Did I missed something ?

NLM_GRANTED_RES is part of the 'asynchronous RPC' NLM model which was
designed to support locking on systems without monitoring
(i.e. without rpc.statd').
Linux does not currently support such a model, nor do we really plan
to do so. Non-monitored locks are pretty hairy things to deal with
(see http://www.opengroup.org/onlinepubs/9629799/chap9.htm#tagcjh_10_01_01_02).

     > 2) If there are 2 clients on different hosts with the same
     >    cookie, the
     > nlmsvc_grant_callback may find an invalid block.

I agree. We should be checking the host address as well.

     > 3) This one may be a design choice. In nlmclnt_lock,
     >    nlmclnt_block is called if
     > the server responds NLM_LCK_BLOCKED to NLMPROC_LOCK even though
     > the client doesn't want a blocking lock. If the server is
     > broken and responds NLM_LCK_BLOCKED even if it should have
     > responded something else, the client will call
     > nlmclnt_block. To avoid that, maybe it could be possible to
     > exchange if ((status = nlmclnt_call(req, NLMPROC_LOCK)) >= 0)
     > with if (((status = nlmclnt_call(req, NLMPROC_LOCK)) >= 0) &&
     > req->a_args.block) But it may also be a design choice, not to
     > try to turn around broken servers.

Right.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
