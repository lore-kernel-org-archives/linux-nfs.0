From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: Stale NFS file handle
Date: Wed, 23 Mar 2005 14:15:04 -0300
Message-ID: <20050323140845.BED8.BRANDEN@terra.com.br>
References: <42416B4C.2010505@RedHat.com> <1111586235.27875.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DE9QF-0002yq-Mc
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 09:13:35 -0800
Received: from itapoa.terra.com.br ([200.154.55.227])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DE9QE-0002bB-4N
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 09:13:35 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111586235.27875.13.camel@lade.trondhjem.org>
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


* Wed, 23 Mar 2005 08:57:15 -0500, Trond Myklebust <trond.myklebust@fys.uio.no>:
> He was running
> 
> while :; do cat test.txt; done >/dev/null
> 
> on a client, then deleting the file on the server. Even if the call to
> open() is successful, you both can and will get ESTALEs on the
> subsequent call to read().

Ok,

But then, how do you suggest I should change applications to do it? The
applications that publish content to the NFS run on one host and are
based on rsync, the applications that deliver content are web servers 
(Apache) reading from this same NFS on another pool of hosts (these are
the ones that get the ESTALE error).

Where is the problem? On the applications that publish? Should they open
the file and update it in-place instead of creating a new one and
renaming? I don't think so! This would lead to content that is a mix of
the old and the new, that is corrupt.

Or is the webserver? Should the application protect itself from ESTALE
errors and retry? Somehow that seems wrong to me also. Then I would have
to change all applications that read this content to do it. Why doesn't
the NFS client recover from this kind of errors?

If it's really not possible to change it on the NFS client (the kernel),
what workaround would you suggest me to use?

Thanks,
Filipe



-------------------------------------------------------
This SF.net email is sponsored by Microsoft Mobile & Embedded DevCon 2005
Attend MEDC 2005 May 9-12 in Vegas. Learn more about the latest Windows
Embedded(r) & Windows Mobile(tm) platforms, applications & content.  Register
by 3/29 & save $300 http://ads.osdn.com/?ad_id=6883&alloc_id=15149&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
