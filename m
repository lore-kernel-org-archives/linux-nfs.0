From: Dumas Patrice <dumas@centre-cired.fr>
Subject: Re: tunneling of nfs and nfs locks
Date: Fri, 22 Mar 2002 15:53:38 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020322155338.E14182@zeus.centre-cired.fr>
References: <20020319161229.B10434@zeus.centre-cired.fr> <shswuw8y3dl.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16oQSQ-0003me-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Mar 2002 06:55:55 -0800
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id PAA19502
          for <nfs@lists.sourceforge.net>; Fri, 22 Mar 2002 15:55:36 GMT
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g2MErcY15513
	for nfs@lists.sourceforge.net; Fri, 22 Mar 2002 15:53:38 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <shswuw8y3dl.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Tue, Mar 19, 2002 at 04:38:14PM +0100
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

> Locking uses a different protocol. It relies on using the portmapper
> to look up RPC service number 100021. For that reason, it will just
> find the ordinary lockd manager on localhost...

I got it to work, by forwarding 100021 on the server. However this is not a
definite solution, because I cannot have lock with different server.

I think it is a bit strange that it is possible to precise another service
number for mountd and nfs, but not for lockd. Is it a design choice, or could
it be changed ?

I have read a little the statd code and a document on the web about lockd/statd
which is a bit old, but I hope still up to date, and it seems to me that making 
statd work with rpc forwarding should be more complicated or even impossible 
because everything is made on a host basis. As every lock operation will 
appear coming from/to the same host, lockd won't even bother with the status.

Has anybody an idea about that ?

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
