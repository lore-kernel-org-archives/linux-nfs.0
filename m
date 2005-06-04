From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Unknown error 525 from getdents from a connection to an
	AIX nfs server
Date: Sat, 04 Jun 2005 11:19:15 -0400
Message-ID: <1117898355.11012.6.camel@lade.trondhjem.org>
References: <200506041341.11421.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DeaQt-00020p-KS
	for nfs@lists.sourceforge.net; Sat, 04 Jun 2005 08:19:31 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DeaQs-0000Wr-L7
	for nfs@lists.sourceforge.net; Sat, 04 Jun 2005 08:19:31 -0700
To: Christoph Bartoschek <bartoschek@or.uni-bonn.de>
In-Reply-To: <200506041341.11421.bartoschek@or.uni-bonn.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

lau den 04.06.2005 Klokka 13:41 (+0200) skreiv Christoph Bartoschek:
> Hi,
> 
> I have the problem that rm does not work reliable over the nfs connection to 
> our AIX nfs server. If one deletes a whole directoy recursively one gets an 
> "Unknown error 525". All files but the directory itself are deleted. 
> 
> The error can be reproduced as follows:
> 
> bartosch@feiler:/fs/data/bartosch/temp> mkdir testdir
> bartosch@feiler:/fs/data/bartosch/temp> touch testdir/a
> bartosch@feiler:/fs/data/bartosch/temp> rm -rf testdir
> rm: reading directory `testdir': Unknown error 525
> bartosch@feiler:/fs/data/bartosch/temp> rm -rf testdir
> bartosch@feiler:/fs/data/bartosch/temp>
> 
> strace says that the error message comes from getdents. 

Sounds like a server bug. 525 is the translations of NFSERR_TOOSMALL,
which means "buffer is too small".
i.e. the server is claiming that it suddenly is incapable of fitting the
result of the readdir operation into the same buffer that apparently had
no problems fitting the 3 entry case.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
