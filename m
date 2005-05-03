From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS honouring chattr +a
Date: Tue, 03 May 2005 09:29:31 -0400
Message-ID: <1115126971.12088.30.camel@lade.trondhjem.org>
References: <42770C23.8050403@qut.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSyS9-0003Uo-Ss
	for nfs@lists.sourceforge.net; Tue, 03 May 2005 07:32:49 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DSyS8-00073u-Bh
	for nfs@lists.sourceforge.net; Tue, 03 May 2005 07:32:49 -0700
To: Paul Stepowski <p.stepowski@qut.edu.au>
In-Reply-To: <42770C23.8050403@qut.edu.au>
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

ty den 03.05.2005 Klokka 15:29 (+1000) skreiv Paul Stepowski:
> Hi,
> 
> I've already searched the archives on this topic and didn't see anything useful. 
>   I set up a test NFS server (v3) on a linux box and exported a partition 
> rw,no_squash_root.  I set the attributes of a file in the exported partition as 
> follows:
> 
> # chattr +a <file>
> 
> So the file is append only. When I attempt to read/write/append to the file I 
> get a permission denied errror. Is there any way of getting NFS to honour this 
> attribute as append only?

There is a patch in recent kernels that prevents NFS from returning an
I/O error in the case of a READ, but there is no protocol support at all
for APPEND-only files, so there is nothing we can do for writes.

You'll have to find a different solution to your problem.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
