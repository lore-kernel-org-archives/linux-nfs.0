From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: intercepting NFS RPC requests
Date: Tue, 7 Nov 2006 14:36:38 -0500
Message-ID: <20061107193638.GD11346@fieldses.org>
References: <9c8209a10611071050p475a2cf1y6656153a4b6a24e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhWkS-00061N-BY
	for nfs@lists.sourceforge.net; Tue, 07 Nov 2006 11:36:40 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhWkS-0006ba-9G
	for nfs@lists.sourceforge.net; Tue, 07 Nov 2006 11:36:41 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611071050p475a2cf1y6656153a4b6a24e7@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, Nov 07, 2006 at 10:50:54AM -0800, Murali Bashyam wrote:
> Is there a feature on the linux v3 or v4 NFS server to allow a process to
> intercept the NFS RPC requests for file operations (open, close, read, write
> etc) and handle them in user space?

No.

> If so, can these be handled asynchronously?
> 
> Alternatively, if this is not possible, is this achievable through VFS
> i.ehave a process create and register a file system through VFS and
> export it
> through NFS? Now when the server handles a client's file operation, it goes
> through VFS and ends up with that vector registered by that process?

No. You could modify fuse to support nfsd, or you could write a
userspace NFS server (or modify an existing server).

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
