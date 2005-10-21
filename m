From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: File lock with multiple clients
Date: Thu, 20 Oct 2005 18:20:13 -0700
Message-ID: <1129857613.10026.1.camel@lade.trondhjem.org>
References: <E1ESjPp-0004BW-Qv@mail.sourceforge.net>
	 <17240.14767.472971.724098@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: petter.knutsen@cgi.no, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESla0-0008Or-D6
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 18:20:20 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ESlZy-0001Hg-Qk
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 18:20:20 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17240.14767.472971.724098@cse.unsw.edu.au>
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

fr den 21.10.2005 klokka 10:43 (+1000) skreiv Neil Brown:

> NOTES
>        flock(2) does not lock files over NFS.  Use fcntl(2) instead: that does
>        work  over  NFS,  given  a  sufficiently  recent version of Linux and a
>        server which supports locking.
> 

Note that this is not entirely accurate any more. Recent kernels will
emulate flock() over NFS by using fcntl() locks.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
