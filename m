From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.6.0 -- nfs client runs 15x faster if client app runs as
 root.
Date: Thu, 08 Jan 2004 08:12:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FFD7353.6A51DEC7@amis.com>
References: <34280.141.211.133.197.1073512478.squirrel@webmail.uio.no> <3FFD660F.1333683F@oleane.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AecKw-0004ID-Nt
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 07:44:42 -0800
Received: from p02m168.mxlogic.net ([216.173.230.168])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AecKw-0000O1-D8
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 07:44:42 -0800
To: =?iso-8859-1?Q?Ga=EBl?= Roualland <gael.roualland@oleane.net>
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

Yesterday after some more debug, Trond sent a patch that fixed the proble=
m.  =


Yes the file has exec set. That might help explain some other behavior th=
at I
was also noticing when running benchmarks.

eric



Ga=EBl Roualland wrote:
> =

> Has the file exec permission set ?
> If yes this would look like an earlier problem that seems to still occu=
r
> on 2.6.0.
> See http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D106966481311224 and=

> http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D106981736010493.
> =

> Ga=EBl.
> =

> --
> Ga=EBl Roualland -+- gael.roualland@oleane.net


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
