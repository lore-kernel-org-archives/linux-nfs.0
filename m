From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: EJUKEBOX and nfs3_proc_read()/nfs3_proc_write()
Date: Thu, 27 Jan 2005 16:43:53 -0800
Message-ID: <1106873033.9636.58.camel@lade.trondhjem.org>
References: <20050127225911.GA24398@janus>
	 <1106867997.7192.14.camel@lade.trondhjem.org>
	 <20050127233831.GA24817@janus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuKFI-0004NE-1y
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 16:44:20 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CuKFD-0002Mv-JD
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 16:44:19 -0800
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20050127233831.GA24817@janus>
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

fr den 28.01.2005 Klokka 00:38 (+0100) skreiv Frank van Maarseveen:

> Because you have to open a file first. Well, as you said NFS is stateless
> so my guess is that the final lookup would return EJUKEBOX rather
> than any I/O on the file-handle. It seems unrealistic to me for a file to
> be archived _during_ I/O.
>
> Sure the protocol has the possibility to return EJUKEBOX in the middle
> of file I/O but does it make sense?

Of course it does. Files are only paged in from the storage medium on
demand in all modern OSes. That goes for ordinary disks, jukeboxed CDs,
tape,...
It is not as if the entire contents are read into memory when you call
open() on a disk-backed file either.

> BTW, I didn't see EJUKEBOX handling in NFSv4.

It is there, but you won't see it by just grepping the code for JUKEBOX:
in the NFSv4 protocol it has been renamed NFS4ERR_DELAY in order to
clarify its purpose. From RFC3530:

   NFS4ERR_DELAY         The server initiated the request, but was not
                         able to complete it in a timely fashion. The
                         client should wait and then try the request
                         with a new RPC transaction ID.  For example,
                         this error should be returned from a server
                         that supports hierarchical storage and receives
                         a request to process a file that has been
                         migrated. In this case, the server should start
                         the immigration process and respond to client
                         with this error.  This error may also occur
                         when a necessary delegation recall makes
                         processing a request in a timely fashion
                         impossible.

The Linux NFSv4 server may also return that error if it has to make an
upcall that for some reason takes longer than expected. For instance,
this may occur when translating a local uid or gid into the canonical
"name@domain" strings used by the NFSv4 GETATTR ops.


Note also that the NFSv4 (or Samba) "delegation recall" process is
something that will affect NFSv3 clients too if the same file is being
exported under NFSv4 (or Samba) and NFSv3. In that case it would be
appropriate for the NFSv3 server to send EJUKEBOX to the NFSv3 client
that has to wait.

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
