From: Dumas Patrice <dumas@centre-cired.fr>
Subject: Re: tunneling of nfs and nfs locks
Date: Tue, 26 Mar 2002 18:19:29 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020326181929.D30979@zeus.centre-cired.fr>
References: <20020319161229.B10434@zeus.centre-cired.fr> <shswuw8y3dl.fsf@charged.uio.no> <20020322155338.E14182@zeus.centre-cired.fr> <shshen8r585.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pueC-0007TF-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 09:22:12 -0800
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id SAA09094
          for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 18:21:38 GMT
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g2QHJTf31512
	for nfs@lists.sourceforge.net; Tue, 26 Mar 2002 18:19:29 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <shshen8r585.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Fri, Mar 22, 2002 at 04:29:14PM +0100
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

> Bug: statd will be monitoring the wrong machine. It will be told to
> monitor 'localhost' by the kernel.

There is a even worse bug: if the lock is a lock with F_SETLKW, then the server
will make the rpc callback saying the lock is released to himself...

However, I have thought about a (maybe complicated) workaround to enable a
working lock management with rpc redirection. (I haven't allready thought about
something similar with status).

Imagine that it is possible to change the rpc programm the client and the
server make callback to (let's say it is 200021). There is still a regular
lockd running which registered the 100021 program number.

1) the client lockd needs a lock. It calls 200021 on the client
2) a proxy rpc server forwards 200021 -> 100021 on the server. It remembers
this service may need a response callback from the server, and registers the
client name. It also registers that he accepts callbacks to 200021 on the
server.
3) Once it may grant a lock, the servers's lockd make a callback to 200021 on
the server.
4) The rpc forwarder gets the server callback. It finds which clients it has to
be forwarded to (thanks to the registering done in 2)). Now it forwards 
200021 -> 100021 on the client. The client lockd knows the lock is granted.

Do you think this could be implemented ? The part that doesn't seems obvious to
me is that one "It finds which clients it has to be forwarded to (thanks to the 
registering done in 2))". I begun to read the lockd code, to know whether there
was enough information to retrieve the client name. I suspect I will have to
dig into the callback arguments and use the lock or cookie field.

Does it seems to be feasible ?

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
