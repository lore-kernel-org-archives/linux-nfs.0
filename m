From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale NFS file handle
Date: Wed, 23 Mar 2005 12:26:55 -0500
Message-ID: <1111598815.13619.1.camel@lade.trondhjem.org>
References: <42416B4C.2010505@RedHat.com>
	 <1111586235.27875.13.camel@lade.trondhjem.org>
	 <20050323140845.BED8.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DE9dR-00048a-6V
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 09:27:13 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DE9dP-0004Ml-GG
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 09:27:13 -0800
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050323140845.BED8.BRANDEN@terra.com.br>
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

on den 23.03.2005 Klokka 14:15 (-0300) skreiv Filipe Brandenburger:

> If it's really not possible to change it on the NFS client (the kernel),
> what workaround would you suggest me to use?

Rename the file, then delete it once you know that the clients no longer
have it open. That's the obvious and standard way of dealing with this
sort of problem over NFS.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by Microsoft Mobile & Embedded DevCon 2005
Attend MEDC 2005 May 9-12 in Vegas. Learn more about the latest Windows
Embedded(r) & Windows Mobile(tm) platforms, applications & content.  Register
by 3/29 & save $300 http://ads.osdn.com/?ad_id=6883&alloc_id=15149&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
