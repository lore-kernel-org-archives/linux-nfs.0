From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Mon, 06 Sep 2004 11:59:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094486357.8342.12.camel@lade.trondhjem.org>
References: <chdp06$e56$1@sea.gmane.org>
	 <1094348385.13791.119.camel@lade.trondhjem.org>  <413A7119.2090709@upb.de>
	 <1094349744.13791.128.camel@lade.trondhjem.org>  <413A789C.9000501@upb.de>
	 <1094353267.13791.156.camel@lade.trondhjem.org>
	 <1094464633.3986.36.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Sven =?ISO-8859-1?Q?K=F6hler?= <skoehler@upb.de>,  linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4Lu5-0004YV-Vx
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 08:59:37 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4Lu5-0002Bb-5I
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 08:59:37 -0700
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1094464633.3986.36.camel@imladris.demon.co.uk>
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

P=E5 m=E5 , 06/09/2004 klokka 05:57, skreiv David Woodhouse:

> The fact that we require a persistent table of exports at all, and can't
> call back to mountd to authenticate 'new' clients instead of just
> telling them to sod off if the kernel doesn't already know about them,
> is considered by some to be a bug in knfsd.=20

That should have been fixed in 2.6.x. If you do mount /proc/fs/nfsd, and
use a recent enough version of mountd, then knfsd can and will work
without any extra help from exportfs.

The one problem I have found with this implementation is that it relies
very heavily on reverse-DNS lookups, so it may give unexpected results
if you have more than one name for your client. I can't see why that
shouldn't be fixable, though...

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
