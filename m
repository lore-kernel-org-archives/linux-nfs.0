From: Dumas Patrice <dumas@centre-cired.fr>
Subject: 3 strange things in the lockd code ?
Date: Thu, 4 Apr 2002 19:42:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020404194238.E25342@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16tBJ6-0004FM-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Apr 2002 09:45:56 -0800
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id TAA16513
          for <nfs@lists.sourceforge.net>; Thu, 4 Apr 2002 19:45:12 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g34Hgch00725
	for nfs@lists.sourceforge.net; Thu, 4 Apr 2002 19:42:38 +0200
To: nfs@lists.sourceforge.net
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

Hi,
I have read some lockd code, especially what is related with blocked locks, and
I have found 2 things I can't explain and a third which isn't really strange.

1) nlmsvc_grant_reply (in svclock.c) seems to be used nowhere, and there is
that in svcproc.c:
#define nlmsvc_proc_granted_res nlmsvc_proc_null

My understanding is that in nlmsvc_grant_blocked there is a callback to the client
with NLMPROC_GRANTED_MSG, the client get the callback using nlmsvc_proc_granted_msg
which in turn sends NLMPROC_GRANTED_RES (and also which triggers 
nlmsvc_grant_callback which only rescuedule block). The server receive and responds 
to the callback, but it is nlmsvc_proc_null.

I may be totally wrong, but it seems to me that nlmsvc_proc_granted_res should
instead call nlmsvc_grant_reply to delete the block. Did I missed something ?

2) If there are 2 clients on different hosts with the same cookie, the
nlmsvc_grant_callback may find an invalid block.

3) This one may be a design choice. In nlmclnt_lock, nlmclnt_block is called if
the server responds NLM_LCK_BLOCKED to NLMPROC_LOCK even though the client
doesn't want a blocking lock. If the server is broken and responds
NLM_LCK_BLOCKED even if it should have responded something else, the client
will call nlmclnt_block. To avoid that, maybe it could be possible to exchange
if ((status = nlmclnt_call(req, NLMPROC_LOCK)) >= 0)
with
if (((status = nlmclnt_call(req, NLMPROC_LOCK)) >= 0) && req->a_args.block)
But it may also be a design choice, not to try to turn around broken servers.


I would like to see whether what I think happens (in 1)) really happens, but
I don't know how to trigger lockd to print debug information (nor where to read
it, but I think syslog or dmesg will be enough). How could I do that ?

Pat



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
