From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: patchs for lockd: granted_res_proc, client address check, blocking check
Date: 26 Apr 2002 11:52:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsznzqzt0q.fsf@charged.uio.no>
References: <20020423103152.A3624@zeus.centre-cired.fr>
	<20020425155951.E13292@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1712Se-0000hn-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Apr 2002 02:56:16 -0700
To: Dumas Patrice <dumas@centre-cired.fr>
In-Reply-To: <20020425155951.E13292@zeus.centre-cired.fr>
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

     > suppose the server send a grant_msg with a lock. The client now
     > has the lock granted, it sends a granted_res with a good
     > status. Now suppose the server never receive this callback. The
     > server will resend a grant_msg with the lock.  The client isn't
     > waiting for a granted_res anymore and thus responds with a
     > granted_res with a bad status. If the server gets this
     > granted_res it will deallocate the lock. At that point there is
     > no lockfrom the server point of view and a lock from the client
     > point of view.

Just add a call to posix_test_lock() in nlmclnt_grant().

     > The client ask for a blocking lock and the server responds that
     > the lock is allready taken. After some time the client becomes
     > unreachable (but doesn't crash and reboot, that case is handled
     > by statd) for whatever reason. Then the lock becomes available,
     > the server locks the file, and send a granted_msg. However, as
     > the client is unreachable the server will keep on resending
     > granted_msg (see nlmsvc_grant_blocked). This means that the
     > file will never be lockable anymore.

     > I have a simple idea for a solution to this problem, however it
     > raises other issues. A possibility would be to have a timer (5
     > minutes, or so...) such that when it is exceeded, the server
     > stops sending granted_msg and unlocks the lock (calls
     > delete_block(...,1)). However, if the client is waiting for
     > that lock and is blocking, it will block forever. It is not a
     > problem in the linux implementation, as the client does busy
     > waiting. (if the server could send a status in the granted_msg
     > call, it would have been easier, but I cannot see such a
     > thing).

The client occasionally wakes up and resends the NLM_LOCK call, so it
will not wait for ever. However what say the server misses the
client's GRANTED_RES reply?

The above problems are exactly why we should aim to use NLM_GRANTED
instead of NLM_GRANTED_MSG at some point in the future.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
