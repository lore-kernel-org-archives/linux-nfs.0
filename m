From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Clients not displaying NFS quotas
Date: Fri, 04 May 2007 06:21:20 -0700
Message-ID: <1178284880.6346.31.camel@heimdal.trondhjem.org>
References: <200705030213.l432DFce017563@turbo.physics.adelaide.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hjxiy-0001yX-Ok
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 06:21:28 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/+lWNr1QiTKZEWhKO/W6b1d70Ee9wEH/E=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hjxiy-0006d0-Tf
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 06:21:31 -0700
In-Reply-To: <200705030213.l432DFce017563@turbo.physics.adelaide.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-05-03 at 11:43 +0930, Jonathan Woithe wrote:
> We have a Slackware 9.1 box (with numerous software upgrades) exporting a
> directory to various NFS clients.  While running a 2.4.x kernel this all
> worked fine - users on clients could use "quota" to display their quota
> information.  When the system was moved to a 2.6.19.2 kernel a few months
> ago the clients could no longer display quota information.  The server
> still knew and enforced the quotas, it's just that from the client's
> point of view there were no quotas.
> 
> The system is running the following software versions:
> 
>   * kernel 2.6.19.2
>   * nfs-utils 1.0.10
>   * util-linux 2.12
>   * portmap 5.0
> 
> The filesystem concerned is reiserfs3.  The kernel has reiserfs quota
> support enabled.
> 
> The relevant partition is mounted on the server using an fstab entry of
> 
>   /dev/...  /home/foobar  reiserfs  usrquota
> 
> All clients mount the volume via the automounter with the "hard,intr,bg"
> mount options.
> 
> Users cannot log into the NFS server.
> 
> We have clients running various versions of redhat, fedora and slackware
> with different kernels.  In all cases things worked with the 2.4.x
> kernel and don't now.  It therefore seems to be a server-related issue.
> 
> Does anyone have any idea as to why client access to quota information
> isn't working in this scenario?

The NFS protocol doesn't support quotas, so those have to be transmitted
using a sideband protocol. Check that you have the 'quotad' daemon
running on your server, and that it is accessible from the clients.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
