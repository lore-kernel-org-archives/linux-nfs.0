From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Move .nfsXXXX files
Date: Wed, 31 Jan 2007 19:42:28 -0800
Message-ID: <1170301348.5795.33.camel@lade.trondhjem.org>
References: <6ffeae550701310533p3bc731b3of53e4da4dd05d98d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trinabh Shukla <trinabh@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCSqZ-0003Am-Ol
	for nfs@lists.sourceforge.net; Wed, 31 Jan 2007 19:42:53 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/gzQ70bncne+KjukgsYwENZ+pSgBZajEM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HCSqb-0006xC-Ca
	for nfs@lists.sourceforge.net; Wed, 31 Jan 2007 19:42:53 -0800
In-Reply-To: <6ffeae550701310533p3bc731b3of53e4da4dd05d98d@mail.gmail.com>
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

On Wed, 2007-01-31 at 19:03 +0530, Trinabh Shukla wrote:
> The .nfsXXXX file get created when I remove a file while it's being
> kept open by one of the process. Due to this I can't remove directory
> which hold this file. So I want to move this .nfsXXXX file on
> different temp directory on the same nfs file system and delete that
> directory. Here it's working properly. 
> 
> But let me know that is it a correct solution? And removal of .nfs
> files does not cause the server serious integrity. 

The .nfsXXX file is a sign that some process still has that file open.
If you forcibly delete the file, you are very likely to screw up that
process. Better then just to kill the process.

You might be able to move the file to another directory, but the problem
then is that the process that tried to delete the file may not have
write access to that directory. In this case, the unlink may fail, and
you will be left with a dangling .nfsXXX file.

> Also it will be good, if you lead some pointers about how
> this .nfsXXXX files handle by the NFS server. 

As far as the NFS server is concerned, this is a file just like any
other. The server attaches no special meaning to it.

Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
