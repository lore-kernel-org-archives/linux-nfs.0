From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: action "debugfs-like" through nfs?
Date: 23 Jul 2003 17:11:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1xwhtgzv.fsf@charged.uio.no>
References: <3F1E892B.8020508@pd.infn.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19fLHa-0008FE-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Jul 2003 08:11:58 -0700
To: Rosario Turrisi <turrisi@pd.infn.it>
In-Reply-To: <3F1E892B.8020508@pd.infn.it>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Rosario Turrisi <turrisi@pd.infn.it> writes:

     > Hi, I have a fileserver from Raidtec which uses ext2
     > filesystems.  Due to a double (!!!) disk failure, I had the
     > strange behaviour that a directory is seen as a whole file,
     > with strange attributes, like "?r--r-sr-T" and changed
     > owner/group.  I believe that an operation like "debugfs" could
     > fix the problem, but it cannot be done (it seems) on an
     > nfs-mounted filesystem (I cannot enter the fileserver system as
     > it is "raidtec-copyrighted").  Any suggestion very very
     > welcome.  Cheers,

Errr... Why is fixing it on the server itself (where "debugfs" is more
likely to work) not an option?

The NFS protocol has no support for doing low-level disk ioctls on the
server so you can forget doing this sort of thing on the client.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
