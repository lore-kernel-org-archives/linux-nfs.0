From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: open O_EXCL works?
Date: Mon, 21 Mar 2005 19:01:15 -0500
Message-ID: <1111449675.10980.50.camel@lade.trondhjem.org>
References: <20050314080517.BD8F.BRANDEN@terra.com.br>
	 <1110813864.30085.47.camel@lade.trondhjem.org>
	 <20050321181858.BE73.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDWpu-00065r-05
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 16:01:30 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDWps-0006az-Cl
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 16:01:29 -0800
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050321181858.BE73.BRANDEN@terra.com.br>
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

m=E5 den 21.03.2005 Klokka 18:31 (-0300) skreiv Filipe Brandenburger:
> Hi, there.
>=20
> I'm trying to make my program work correctly over NFS, but apparently I
> still have a race condition, because I'm getting inconsistencies. I
> still can't find out exactly what is happening. This is what I'm doing:
>=20
>=20
>   f =3D open("myfile", O_CREAT|O_WRONLY|O_APPEND)
>=20
>   [repeat the loop below for the data]
>     hardlink("myfile", "myfile.lock")
>     -> if it fails, invalidate information
>     write(f, "mydata", sizeof(mydata))
>     unlink("myfile.lock")
>   [end loop]
>=20
>   close(f)
>=20
>=20
> I would expect to get consistent data, as "hardlink" should be an atomic
> operation over NFS (according to the previous posts on this thread). But
> I'm still having problems.
>=20
> What I think is happening is that one process in one host is silently
> overwriting data just written by another process on another host (this
> overwriting happens on the same second interval), instead of appending
> to the end of the file, just after that other process record...
>=20
> I mean, I found out that append writes are not atomic in Linux 2.4, but
> if I have a hardlink operation just before the write, it should fix the
> issue, shouldn't it?

Append writes are *never* atomic on NFS for any platform. They would
need additional protocol support.

For newer kernels, you should read all about the NFS cache consistency
model on

   http://nfs.sourceforge.net/#faq_a8

That will tell you why you should create the lock file before opening
the file.
On an old kernel, like 2.4.20, you will also have to set the "noac"
mount option. It makes everything very slow, but it is necessary in
order to compensate for the lack of close-to-open cache consistency.

Cheers,
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
