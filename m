From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: open O_EXCL works?
Date: Mon, 21 Mar 2005 18:31:52 -0300
Message-ID: <20050321181858.BE73.BRANDEN@terra.com.br>
References: <20050314080517.BD8F.BRANDEN@terra.com.br> <1110813864.30085.47.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDUTo-0007Yi-6H
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 13:30:32 -0800
Received: from itapoa.terra.com.br ([200.154.55.227])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDUTl-0001Xn-VV
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 13:30:32 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110813864.30085.47.camel@lade.trondhjem.org>
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


Hi, there.

I'm trying to make my program work correctly over NFS, but apparently I
still have a race condition, because I'm getting inconsistencies. I
still can't find out exactly what is happening. This is what I'm doing:


  f =3D open("myfile", O_CREAT|O_WRONLY|O_APPEND)

  [repeat the loop below for the data]
    hardlink("myfile", "myfile.lock")
    -> if it fails, invalidate information
    write(f, "mydata", sizeof(mydata))
    unlink("myfile.lock")
  [end loop]

  close(f)


I would expect to get consistent data, as "hardlink" should be an atomic
operation over NFS (according to the previous posts on this thread). But
I'm still having problems.

What I think is happening is that one process in one host is silently
overwriting data just written by another process on another host (this
overwriting happens on the same second interval), instead of appending
to the end of the file, just after that other process record...

I mean, I found out that append writes are not atomic in Linux 2.4, but
if I have a hardlink operation just before the write, it should fix the
issue, shouldn't it?

Or somehow isn't the hardlink operation atomic? Or is the information of
the file size (for the append) being held in some cache, and not being
looked up just before each write (and just after we assure the file is
ours with the lockfile hardlink)? Could you explain what is happening?
Could you suggest a way to fix this and reliably append data to the file?

I can provide more information upon request. By the way, the NFS client
platform is Linux RedHat 7.3, with kernel from RHAS 2.1, uname returns
2.4.9-e.49enterprise, NFS servers are a mix of EMC Celerra, EMC NS-700
(Clariion) and Netapp FAS940.

Thanks a lot,
Filipe



* Mon, 14 Mar 2005 10:24:23 -0500, Trond Myklebust <trond.myklebust@fys.uio.=
no>:
> m=E5 den 14.03.2005 Klokka 08:18 (-0300) skreiv Filipe Brandenburger:
> > My question is to know what would happen if:
> > a) at the time the "lookup" call is made, the hardlink/symlink/director=
y
> > does not exist yet, so that I can go to the next call;
> > b) when I call the main function (link/symlink/mkdir), the
> > hardlink/symlink/directory was already created by another process (mayb=
e
> > on another host).
>=20
> Both symlink and mkdir return errors that close the race. In fact, we
> shouldn't have to do that lookup at all (and one of these days, I will
> get round to setting up the intent flags for all these cases).
>=20
> Cheers,
>   Trond
>=20
> --=20
> Trond Myklebust <trond.myklebust@fys.uio.no>




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
