From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: PATCH - RPC/TCP 2 of 4 - Allow  SO_REUSEADDR for NFS sockets
Date: 14 Aug 2002 03:17:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsvg6ensro.fsf@charged.uio.no>
References: <15704.30117.665447.109832@notabene.cse.unsw.edu.au>
	<Pine.BSO.4.33.0208122322420.6948-100000@citi.umich.edu>
	<15704.41158.32143.348415@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <cel@citi.umich.edu>,  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17emmz-0000da-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 18:17:33 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15704.41158.32143.348415@notabene.cse.unsw.edu.au>
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

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

    >> it's been suggested that the client should also try reusing the
    >> port number when reconnecting over TCP... any thoughts on that?

     > Why?  You would not be able to reconnect until the TCP timeout
     > on connection re-use has passed, and by that time any benefit
     > that you might gain is probably lost.  How does the TCP timeout
     > compare with the replay-cache timeout??

The connection may break for other reasons (network partition for
instance). Reusing the port number guarantees that the replay cache
works as expected.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
