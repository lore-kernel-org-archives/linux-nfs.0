From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: standard and lockd
Date: 10 Apr 2002 19:14:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslmbvlbm6.fsf@charged.uio.no>
References: <20020410165023.D23279@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vLgw-00089E-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Apr 2002 10:15:30 -0700
To: Dumas Patrice <dumas@centre-cired.fr>
In-Reply-To: <20020410165023.D23279@zeus.centre-cired.fr>
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

     > Hi, If the standard for lockd is described in
     > http://www.opengroup.org/onlinepubs/009629799/chap9.htm#tagcjh_10,
     > then the linux lockd breaks the standard in numerous parts,
     > mainly

     > - the protocole structures aren't the same (because on linux
     >   the structure used
     > is file_lock)

I don't follow you at all here. Examples please of where this is a
problem with the standard?

     > - lockd doesn't responds with the right message type for
     >   granted locks (more
     > precisely it uses a GRANTED_MSG in cases it should use
     > GRANTED).

See the comment about HP clients above nlmsvc_grant_blocked().

Of course, if you are planning on writing proper support for the
asynchronous RPC, then we can indeed go ahead and make
nlmsvc_grant_blocked() call either NLM_GRANTED or NLM_GRANTED_MSG
depending on whether the client originally called NLM_LOCK or
NLM_LOCK_MSG.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
