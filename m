From: Rex Dieter <rdieter@math.unl.edu>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Thu, 11 Jul 2002 14:14:03 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207111414.03258.rdieter@math.unl.edu>
References: <E17SjDh-00067R-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mathstat.unl.edu ([129.93.48.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SjOA-0005pq-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 12:14:06 -0700
Received: from duran.unl.edu (IDENT:O5vGMO7IOeT0hjPaSV3gVLWS/XUfDpyj@duran.unl.edu [129.93.50.93])
	by mathstat.unl.edu (8.9.3/8.9.3) with ESMTP id OAA10973
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 14:14:04 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <E17SjDh-00067R-00@usw-sf-list2.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> >>>>> " " =3D=3D Matthias Andree <ma@dt.e-technik.uni-dortmund.de> writ=
es:
>      > What if the NFS stuff is not mounted with sync or explicitly
>      > mounted async? Will an nfsd still do synchronous writes to
>      > directories?

> Of course. It is not possible for the NFS client to switch this
> behaviour off, since it is part of the server side specifications in
> the protocol.
> The only thing that can screw you up is if you use the 'async' option
> in /etc/exports on the server.

How is specifying 'async' in /etc/exports on the NFS server different tha=
n a=20
NFS client explicitly mounting async?

-- Rex


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
