From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: userspace NFS daemon
Date: Sun, 05 Sep 2004 17:25:52 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094419552.8081.33.camel@lade.trondhjem.org>
References: <20040905210902.GA29182@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C44X9-0008Fd-LT
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 14:26:47 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C44X8-0007QY-67
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 14:26:47 -0700
To: Frank van Maarseveen <frankvm@xs4all.nl>
In-Reply-To: <20040905210902.GA29182@janus>
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

P=E5 su , 05/09/2004 klokka 17:09, skreiv Frank van Maarseveen:
> Isn't this one completely obsolete?

Yes. Debian still keeps it around, though.

> So maybe we could drop sys_setfsuid() and sys_setfsgid() if those calls
> have no other use then for running unfsd as root?

That is really a question to be put to lkml rather than this list,
however note that we still do have userspace file-servers to support.
Does Samba use it, for instance?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
