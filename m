From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: EJUKEBOX and nfs3_proc_read()/nfs3_proc_write()
Date: Fri, 28 Jan 2005 00:38:31 +0100
Message-ID: <20050127233831.GA24817@janus>
References: <20050127225911.GA24398@janus> <1106867997.7192.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuJDj-0001OM-8L
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 15:38:39 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CuJDh-0002kv-KC
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 15:38:39 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1106867997.7192.14.camel@lade.trondhjem.org>
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

On Thu, Jan 27, 2005 at 03:19:57PM -0800, Trond Myklebust wrote:
> to den 27.01.2005 Klokka 23:59 (+0100) skreiv Frank van Maarseveen:
> > I think that the EJUKEBOX wrapper in fs/nfs/nfs3proc.c is not necessary
> > for nfs3_proc_read() and nfs3_proc_write().
> > 
> > Can you confirm this?
> 
> Why do you believe that?

Because you have to open a file first. Well, as you said NFS is stateless
so my guess is that the final lookup would return EJUKEBOX rather
than any I/O on the file-handle. It seems unrealistic to me for a file to
be archived _during_ I/O.

Sure the protocol has the possibility to return EJUKEBOX in the middle
of file I/O but does it make sense?

BTW, I didn't see EJUKEBOX handling in NFSv4.

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
