From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS performance issue - P3 vs P4
Date: Sat, 12 Oct 2002 01:40:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15783.24963.812219.739740@charged.uio.no>
References: <shs1y6witaj.fsf@charged.uio.no>
	<Pine.LNX.3.95a.1021011220934.18295B-100000@kiwi.caspur.it>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    g.palumbo@caspur.it
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1809Oq-0001qw-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 16:40:57 -0700
To: Andrei Maslennikov <andrei@caspur.it>
In-Reply-To: <Pine.LNX.3.95a.1021011220934.18295B-100000@kiwi.caspur.it>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

>>>>> " " == Andrei Maslennikov <andrei@caspur.it> writes:

     > PS One point still remains unclear - how then it could be
     > explained that
     >    P3 client was not manifesting any problem with P3 server? It
     >    had exactly the buggy 2.4.18-10smp, like P4. Maybe it may be
     >    attributed to a higher (2 Ghz against 1 Ghz of P3's) CPU
     >    clock on P4 client?

Yep: I would guess it would be a timing thing. The flooding only
occurs when the socket buffer is (almost) full. If the socket buffer
does not get filled (because the NIC is able to send off requests
faster than the P3 can generate them) then you are safe...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
