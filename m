From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Client Performance Question
Date: Wed, 13 Jul 2005 16:16:11 -0400
Message-ID: <1121285771.8234.7.camel@lade.trondhjem.org>
References: <111aefd050713113071f0c9ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dsneh-0004hI-AS
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 13:16:31 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dsnef-0004I3-Sz
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 13:16:31 -0700
To: penney@msu.edu
In-Reply-To: <111aefd050713113071f0c9ce@mail.gmail.com>
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

on den 13.07.2005 Klokka 14:30 (-0400) skreiv Chris Penney:
> The client mount options are:
>    rw,nosuid,bg,hard,intr,nfsvers=3,tcp,rsize=32768,wsize=32768

Does this match the entry for this mountpoint in /proc/mounts ?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
