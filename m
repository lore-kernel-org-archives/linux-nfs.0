From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: SuSE 9 sp1 GA : Busy mounts.
Date: Sat, 02 Jul 2005 01:50:22 +0200
Message-ID: <1120261822.8246.28.camel@lade.trondhjem.org>
References: <20050701104415.91141.qmail@web51601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DoVHP-00053B-5z
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 16:50:43 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DoVHO-0006p0-Bo
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 16:50:42 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050701104415.91141.qmail@web51601.mail.yahoo.com>
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

fr den 01.07.2005 Klokka 03:44 (-0700) skreiv mehta kiran:
> Hi , 
>       I exported a filesystem.
>       Client took lock on a file.
>       Then i stopped all nfs daemons
>       including lockd .I have also 
>       unexported all filesystem. but
>       still filesystems cannot be
>       unmounted.It gives "device busy" error
>       
>       vcslinux4:~ # uname -a
>       Linux vcslinux4 2.6.5-7.139-smp #1 SMP Fri Jan 
>       14 15:41:33 UTC 2005 i686 i686 i3
>       86 GNU/Linux
>      
>       This is rarely reproducible.
>       Please let me nkow if this is a known issue.

A lot of water has been passed under the bridge since 2.6.5. Please
retry with a more recent kernel.

Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
