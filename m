From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: open O_EXCL works?
Date: Tue, 22 Mar 2005 09:04:57 -0500
Message-ID: <1111500297.24016.39.camel@lade.trondhjem.org>
References: <20050322101843.BE94.BRANDEN@terra.com.br>
	 <1111498903.24016.17.camel@lade.trondhjem.org>
	 <20050322104736.BE97.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDk0R-00042T-Ss
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 06:05:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDk0Q-0006YU-3o
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 06:05:15 -0800
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050322104736.BE97.BRANDEN@terra.com.br>
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

ty den 22.03.2005 Klokka 10:51 (-0300) skreiv Filipe Brandenburger:
> Hello, once again! :-)
> 
> * Tue, 22 Mar 2005 08:41:43 -0500, Trond Myklebust <trond.myklebust@fys.uio.no>:
> > >   [repeat the loop below for the data]
> > >     hardlink("myfile", "myfile.lock")
> > >     -> if it fails, invalidate information
> > >     f = open("myfile", O_CREAT|O_WRONLY|O_APPEND)
> > >     write(f, "mydata", sizeof(mydata))
> > >     close(f)
> > >     unlink("myfile.lock")
> > >   [end loop]
> > 
> > Yes. This would work if close-to-open works correctly.
> 
> Alright, but in:
> >    http://nfs.sourceforge.net/#faq_a8
> It's saying that close-to-open was introduced in 2.4.20, and I'm still
> with 2.4.9. Will it work with 2.4.9 too? The FAQ mentions something
> about "old behavior", what was that exactly? You mentioned too that in
> 2.4.9 it depends a lot on the synchronization of time between client and
> server, how is it?


I wrote:
However, I had forgotten how the 2.4.9 code worked. If the file has been
modified within the last hour, then the kernel should revalidate the
attribute cache on open. This scheme very much relies on you using ntp
or something like that to ensure that the clock on the server and client
are in reasonable sync.


> What I really need to know is if that code above will solve my problem
> on 2.4.9 too, or only on 2.4.20 and 2.6 or superior.

As you can see from the above, the answer is _no guarantees_.

It may, assuming that your file changes frequently, and client and
server are in sync timewise.

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
