From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: On NFS mounted file system access time not updated
Date: Sun, 18 Jun 2006 15:46:40 -0400
Message-ID: <1150660000.6771.189.camel@lade.trondhjem.org>
References: <b01966ec0606170504p1575f325y560aa3b764dc47a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neil@brown.name, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fs3Ef-0000n6-LR
	for nfs@lists.sourceforge.net; Sun, 18 Jun 2006 12:47:05 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fs3Ee-0006uM-Im
	for nfs@lists.sourceforge.net; Sun, 18 Jun 2006 12:47:05 -0700
To: Nida M <nidajm@gmail.com>
In-Reply-To: <b01966ec0606170504p1575f325y560aa3b764dc47a2@mail.gmail.com>
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

On Sat, 2006-06-17 at 17:34 +0530, Nida M wrote:
> Hi
>  
> I am phasing a problem on MIPS platform for kernel 2.6.16 that, 
> on NFS mounted file system the atime is not getting updated.
>  
> To test this i have written a test program ,in which I am doing a
> read(), 
> and then I do a stat() to check the changed attribute of the file
> being read.
> But I found the access time [atime]  is not getting updated..
>  
> For 2.6 kernel has any patch is released to fix this problem ..?
> I need to fix this problem .. Can Anybody help me in this..??

If the client reads the file from its own cache the atime does not get
updated on the server.

  Trond



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
