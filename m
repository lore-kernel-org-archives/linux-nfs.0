From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs problem: nfs could be mounted and viewed but errors
	on file opening
Date: Fri, 10 Sep 2004 12:26:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094833610.8605.29.camel@lade.trondhjem.org>
References: <1094795240.3169.17.camel@roach.aldevinco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5oEt-0003bj-Sq
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 09:27:07 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5oEt-0001eg-DN
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 09:27:07 -0700
To: ronald rojas <alsonsdev_mis@dctech.com.ph>
In-Reply-To: <1094795240.3169.17.camel@roach.aldevinco.com>
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

P=E5 fr , 10/09/2004 klokka 01:50, skreiv ronald rojas:
> kernel ver. 2.6.8

ftp://ftp.kernel.org/pub/linux/kernel/v2.6/LATEST-IS-2.6.8.1


Summary of changes from v2.6.8 to v2.6.8.1
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

<jgarzik@pobox.com>
        [PATCH] Fix NFS client screw-up in fcntl f_op removal

        Fix stupid thinkos in the fcntl f_op removal code.

<torvalds@ppc970.osdl.org>
        Linux 2.6.8.1


 Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
