From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 3 strange things in the lockd code ?
Date: 08 Apr 2002 15:12:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shselhq49n2.fsf@charged.uio.no>
References: <20020404194238.E25342@zeus.centre-cired.fr>
	<shs8z7yo0ml.fsf@charged.uio.no>
	<20020408145459.B12049@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uYwm-0005uK-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 06:12:37 -0700
To: Dumas Patrice <dumas@centre-cired.fr>
In-Reply-To: <20020408145459.B12049@zeus.centre-cired.fr>
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

     > I didn't saw something really saying non-monitored clients
     > aren't allowed to do NLM_LOCK or NLM_LOCK_MSG, but I assume
     > they aren't. However I am pretty sure that monitored clients
     > can do NLM_LOCK_MSG and thus they can receive in turn
     > NLM_GRANTED_MSG, which should trigger them to send a
     > NLM_GRANTED_RES. And indeed the dmesg output I send in a mail
     > with subject "lockd bug (?)" shows linux nfs clients do send
     > NLM_GRANTED_MSG.

I would certainly accept patches that fix the support for asynchronous
calls on the server side. I'd be more sceptical about actually using
them for the client though.

    >> I agree. We should be checking the host address as well.

     > I will try to make a patch.

Thanks...

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
