From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd clients and server have the same rpc_clnt for each host
Date: 15 May 2002 22:28:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs7km5cfzq.fsf@charged.uio.no>
References: <20020515183511.E27252@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1785PS-0007TX-00
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 13:30:06 -0700
To: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
In-Reply-To: <20020515183511.E27252@zeus.centre-cired.fr>
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

>>>>> " " == Patrice DUMAS <dumas@centre-cired.fr> writes:

     > It seems to me that the hosts structure is common to all the
     > lockd clients and the lockd server. Is it true (because
     > nlm_hosts is a static array) ?

The structure is common, but the entries shouldn't be.

Hmm... It looks like nlm_match_host() might want a small fix in order
to take that into account...

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
