From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: open O_EXCL works?
Date: Tue, 22 Mar 2005 08:41:43 -0500
Message-ID: <1111498903.24016.17.camel@lade.trondhjem.org>
References: <20050322073459.BE83.BRANDEN@terra.com.br>
	 <1111494435.21559.20.camel@lade.trondhjem.org>
	 <20050322101843.BE94.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDjeE-0002ye-UN
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 05:42:18 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDjdv-0003PJ-24
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 05:42:18 -0800
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050322101843.BE94.BRANDEN@terra.com.br>
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

ty den 22.03.2005 Klokka 10:28 (-0300) skreiv Filipe Brandenburger:

> Would this work? Also, using fcntl(F_SETLK) implies mounting filesystems
> without the "nolock" option (that is what I'm using now), and implies
> running lockd, right? Also, wouldn't I have problems if some process
> dies between locking and unlocking with fcntl?

Not necessarily. Cache invalidation should happen whether or not you use
the nolock option.

> Would change the position of "open" and "close" to inside the hardlink
> lock solve the problem? What I mean is, would this code work as I expect,
> with appends being atomic between different clients?
> 
> 
>   [repeat the loop below for the data]
>     hardlink("myfile", "myfile.lock")
>     -> if it fails, invalidate information
>     f = open("myfile", O_CREAT|O_WRONLY|O_APPEND)
>     write(f, "mydata", sizeof(mydata))
>     close(f)
>     unlink("myfile.lock")
>   [end loop]

Yes. This would work if close-to-open works correctly.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
