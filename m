From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFS as a Cluster File System.
Date: 14 Jan 2003 16:46:58 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsk7h720p9.fsf@charged.uio.no>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
	<3E1DE9D6.7040406@unix.sh>
	<15907.5456.68906.820989@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Robertson <alanr@unix.sh>,  Lorn Kay <lorn_kay@hotmail.com>,
	  nfs@lists.sourceforge.net,  linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YTHm-0008Ot-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 07:47:30 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15907.5456.68906.820989@notabene.cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

     > NFSv4 does not try to "fix" this.  It makes no attempts at
     > "cache coherency" beyond what NFSv2/3 provide which is "close
     > to open" cohenrence, meaning that if only one process has a
     > file open at a time, then everythnig will appear coherent, and
     > if multiple processes have the file open at the same time, they
     > need to use record locking.

Note, though, that in addition to supporting file locking, NFSv4 adds
support for file 'delegation' which allow the NFS client to do locking
entirely as a local operation (i.e. there is no need to contact the
server). For most applications, this will make locking a much faster
operation...

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
