From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux NFS Implementation
Date: 05 May 2002 13:19:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8z6ykfki.fsf@charged.uio.no>
References: <6550723576.20020505124553@netzone.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 174K31-0007k5-00
	for <nfs@lists.sourceforge.net>; Sun, 05 May 2002 04:19:23 -0700
To: Gavin Woodhatch <gavin.woodhatch@netzone.ch>
In-Reply-To: <6550723576.20020505124553@netzone.ch>
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

>>>>> " " == Gavin Woodhatch <gavin.woodhatch@netzone.ch> writes:

     > Hello All Are all NFSv3 Fuctions Implemented in Linux (like
     > readdirplus) ?

Are you talking about the client or the server?

     > What C Funtions should be best used to open / read a file on a
     > NFS Server ? Or doesn't it make a difference ?

The standard POSIX functions should be fine.

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
