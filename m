From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: possible client stale filehandle bug?
Date: Tue, 25 Jan 2005 22:06:27 -0800
Message-ID: <1106719587.10014.4.camel@lade.trondhjem.org>
References: <20050125173945.GU12269@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtgLP-00016r-2X
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:07:59 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CtgLN-0001zu-H7
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:07:58 -0800
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20050125173945.GU12269@polop.usc.edu>
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

ty den 25.01.2005 Klokka 09:39 (-0800) skreiv Garrick Staples:
> Hi all,
>    I have lots of storage in a large Solaris samfs environment that is NFS
> shared to a large number of Solaris and RHEL3 clients.  Under some conditions,
> linux apps have been getting stale filehandles during the normal course of
> their activity.  Various file handling syscalls like read() or open() might
> error.  Lots of renames and setattrs calls seem to trigger the problem.  
> 'ci' and 'cvs commit' are particularly good at this.

ESTALE is usually a sign that someone is deleting a file on the server
that is in use by the client. It is a sign that you are doing something
that violates the caching rules of NFS.

> It seems that the Solaris clients never report any such errors, only the Linux
> clients.  However, watching 'snoop' on the Solaris NFS server, I see that it IS
> returning stale file handles to both OSes, but Solaris clients seem to retry
> the request several times; and the Linux clients immediately pass the error up
> to the application.
> 
> Is there some condition that the 2.4 kernel is handling incorrectly?

I do not believe that Solaris redrives ESTALE on read, but they may do
it on open(). Linux does not redrive either case. See the many
discussions in the NFS list archives for why.

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
