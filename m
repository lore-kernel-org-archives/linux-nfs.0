From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: broken_suid mount option
Date: Sun, 05 Sep 2004 18:03:43 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094421823.8081.44.camel@lade.trondhjem.org>
References: <20040905213702.GA29401@janus>
	 <1094420629.8081.39.camel@lade.trondhjem.org>
	 <20040905215558.GA29526@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4576-0001cZ-PR
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 15:03:56 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4575-0003vN-9O
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 15:03:56 -0700
To: Frank van Maarseveen <frankvm@xs4all.nl>
In-Reply-To: <20040905215558.GA29526@janus>
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

P=E5 su , 05/09/2004 klokka 17:55, skreiv Frank van Maarseveen:

> So they run old XFree86 software with broken setuid programs and
> compensate using the broken_suid mount option. They probably use
> an old kernel as well. Isn't it time to change this for 2.6?
> You mentioned the word "security" ;-)

If people agree that we can remove it, then I'll take the patch. The
whole point of making it a mount option (rather than the default as used
to be the case earlier) was to allow us to deprecate it.

Note, though, that we should take this one too to lkml in order to get a
proper concensus.

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
