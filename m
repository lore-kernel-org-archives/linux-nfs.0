From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: EJUKEBOX and nfs3_proc_read()/nfs3_proc_write()
Date: Thu, 27 Jan 2005 15:19:57 -0800
Message-ID: <1106867997.7192.14.camel@lade.trondhjem.org>
References: <20050127225911.GA24398@janus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuIw1-0000XO-3g
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 15:20:21 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CuIvu-0004An-7V
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 15:20:21 -0800
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20050127225911.GA24398@janus>
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

to den 27.01.2005 Klokka 23:59 (+0100) skreiv Frank van Maarseveen:
> I think that the EJUKEBOX wrapper in fs/nfs/nfs3proc.c is not necessary
> for nfs3_proc_read() and nfs3_proc_write().
> 
> Can you confirm this?

Why do you believe that?

NFS is a stateless protocol: the server does not know when it is optimal
to cache a particular file, nor does it know exactly when it is optimal
to stop caching it (unless of course you delete it).

So sure, not only does the protocol allow the server to return EJUKEBOX
for both READ and WRITE requests, but it may also have a good reason to
do so (namely that it is no longer caching the file, and it has to read
it in from tape/cd/...).

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
