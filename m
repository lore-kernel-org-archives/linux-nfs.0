From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: tunneling of nfs and nfs locks
Date: 22 Mar 2002 16:29:14 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshen8r585.fsf@charged.uio.no>
References: <20020319161229.B10434@zeus.centre-cired.fr>
	<shswuw8y3dl.fsf@charged.uio.no>
	<20020322155338.E14182@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16oQzD-0002nL-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Mar 2002 07:29:48 -0800
To: Dumas Patrice <dumas@centre-cired.fr>
In-Reply-To: <20020322155338.E14182@zeus.centre-cired.fr>
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

     > Hi,
    >> Locking uses a different protocol. It relies on using the
    >> portmapper to look up RPC service number 100021. For that
    >> reason, it will just find the ordinary lockd manager on
    >> localhost...

     > I got it to work, by forwarding 100021 on the server. However
     > this is not a definite solution, because I cannot have lock
     > with different server.

Bug: statd will be monitoring the wrong machine. It will be told to
monitor 'localhost' by the kernel.

     > I think it is a bit strange that it is possible to precise
     > another service number for mountd and nfs, but not for
     > lockd. Is it a design choice, or could it be changed ?

Not really. Unlike NFS, itself the NLM (NFS locking manager) protocol
is a stateful protocol. In order to get things like F_SETLKW to work,
the client and server sometimes have to swap roles: meaning that the
server has to send an RPC call back to the client in order to tell it
that "the other process that was holding the lock has now released it,
and so I've granted the lock to you".

This means that the server and the client both have to know about each
other's NLM service number. There is nothing in the protocol that
allows them to exchange this information, so it needs to be hardcoded.


Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
