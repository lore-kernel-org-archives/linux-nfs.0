From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: open O_EXCL works?
Date: Tue, 22 Mar 2005 10:51:18 -0300
Message-ID: <20050322104736.BE97.BRANDEN@terra.com.br>
References: <20050322101843.BE94.BRANDEN@terra.com.br> <1111498903.24016.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDjlv-0003La-6A
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 05:50:15 -0800
Received: from itapoa.terra.com.br ([200.154.55.227])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDjlu-00047b-Kh
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 05:50:15 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111498903.24016.17.camel@lade.trondhjem.org>
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


Hello, once again! :-)

* Tue, 22 Mar 2005 08:41:43 -0500, Trond Myklebust <trond.myklebust@fys.uio.no>:
> >   [repeat the loop below for the data]
> >     hardlink("myfile", "myfile.lock")
> >     -> if it fails, invalidate information
> >     f = open("myfile", O_CREAT|O_WRONLY|O_APPEND)
> >     write(f, "mydata", sizeof(mydata))
> >     close(f)
> >     unlink("myfile.lock")
> >   [end loop]
> 
> Yes. This would work if close-to-open works correctly.

Alright, but in:
>    http://nfs.sourceforge.net/#faq_a8
It's saying that close-to-open was introduced in 2.4.20, and I'm still
with 2.4.9. Will it work with 2.4.9 too? The FAQ mentions something
about "old behavior", what was that exactly? You mentioned too that in
2.4.9 it depends a lot on the synchronization of time between client and
server, how is it?

What I really need to know is if that code above will solve my problem
on 2.4.9 too, or only on 2.4.20 and 2.6 or superior.

Thanks,
Filipe



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
