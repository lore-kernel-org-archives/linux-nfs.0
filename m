From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: Re: Number of nfsd processes?
Date: Sun, 25 Jun 2006 09:30:50 -0400
Message-ID: <1151242251.23280.5.camel@pc>
References: <40b437200606241759u3ec0ccd7q578c1ac476d498d9@mail.gmail.com>
	<17566.23170.136301.392306@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1804751643=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FuUhX-0001wq-Gs
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 06:30:59 -0700
Received: from linux.interlinx.bc.ca ([66.11.173.224])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FuUhW-00050Z-A0
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 06:30:59 -0700
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 002BBCBC20
	for <nfs@lists.sourceforge.net>; Sun, 25 Jun 2006 09:30:51 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <17566.23170.136301.392306@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============1804751643==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-dL9bZ/UTDBD54nGGN860"


--=-dL9bZ/UTDBD54nGGN860
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Neil,

Your description was a bit ungrokkable.  Let me try to put some real
world values to it and try to make it out...

On Sun, 2006-06-25 at 19:42 +1000, Neil Brown wrote:
> Look at the line starting 'th'.

th 32 1439 108.420 17.016 6.044 3.724 2.464 0.296 0.256 0.280  0.672

>  The first number is the number of threads

Yup, 32 of them.

>  The second is the number of times the a thread has started handling
>   a request when all other threads were busy

1439 in my case.  I guess ideally you want this number quite low.  How
low is low enough?

>  The remainder are the number of seconds when
>     0-10% of threads were in use

108.420 seconds in my example.  By and far the largest value with the
next one being only 17.016 seconds.

>    10-20% of threads were in user

17.016 seconds

>    20-30%

6.044

>     ...
>    90-100%

0.672

Quite low indeed, yes?

>=20
>  From this you should be able to get an idea of how many threads
>  are getting used.
>  Ideally, the top few numbers

What do you mean by the "top few numbers"

>  should be very small compared with the
>  earlier numbers.

What do you mean by the "earlier numbers"?

>   If they are, increase the number of threads.

So, should I increase threads?

>  I usually run with 128, but there are probably 100-200 clients, but
>  they aren't very busy clients.

Any WAGs (or better) on the "cost" of a thread?

b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-dL9bZ/UTDBD54nGGN860
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEnpAKl3EQlGLyuXARAvJdAJkBaontPx19h5605NMNd3PA9rNwzgCgiT8W
WUv2qtHaxvd7gtmxRwpzBdQ=
=ekGJ
-----END PGP SIGNATURE-----

--=-dL9bZ/UTDBD54nGGN860--



--===============1804751643==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1804751643==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1804751643==--
