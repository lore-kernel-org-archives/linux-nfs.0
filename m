From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale NFS file handle
Date: Wed, 23 Mar 2005 08:57:15 -0500
Message-ID: <1111586235.27875.13.camel@lade.trondhjem.org>
References: <20050322210033.BEAC.BRANDEN@terra.com.br>
	 <42416B4C.2010505@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Filipe Brandenburger <branden@terra.com.br>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DE6Ma-0005D1-7H
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 05:57:36 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DE6MY-00083l-Lj
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 05:57:36 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <42416B4C.2010505@RedHat.com>
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

on den 23.03.2005 Klokka 08:12 (-0500) skreiv Steve Dickson:
> Filipe Brandenburger wrote:
> > I have a problem where I'm getting "Stale NFS file handle" errors when a
> > file is updated. I can easily reproduce the problem if I run a sequence
> > of commands in two different hosts.
> > 
> > My environment is:
> > 
> > 1) Server: Netapp FAS940
> > 2) Client 1: Linux RedHat 9 with kernel 2.4.21-4.ELsmp (kernel of RHAS3)
> > 3) Client 2: exactly the same as client 1.
> Sometime back there was an Netapp issue that was causing
> ESTALES with mostly 2.4 kernels... I upgraded the OS on
> our toater and the problem when away....

... yeah, but this was a pretty obvious case of user error.

He was running

while :; do cat test.txt; done >/dev/null

on a client, then deleting the file on the server. Even if the call to
open() is successful, you both can and will get ESTALEs on the
subsequent call to read().

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
