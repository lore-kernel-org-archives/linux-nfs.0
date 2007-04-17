From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Tue, 17 Apr 2007 07:21:27 -0400
Message-ID: <200704170721.27869.vapier@gentoo.org>
References: <17950.44333.118970.276558@notabene.brown>
	<4623BCD9.3090501@RedHat.com>
	<200704171208.51797.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0743840580=="
Cc: Neil Brown <neilb@suse.de>, Olaf Kirch <olaf.kirch@oracle.com>,
	Steve Dickson <SteveD@redhat.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdlkR-00050A-U8
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 04:21:24 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HdlkT-0004Ak-Ap
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 04:21:26 -0700
In-Reply-To: <200704171208.51797.olaf.kirch@oracle.com>
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

--===============0743840580==
Content-Type: multipart/signed; boundary="nextPart3369246.vJA6PknzlH";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart3369246.vJA6PknzlH
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 17 April 2007, Olaf Kirch wrote:
> On Monday 16 April 2007 20:13, Steve Dickson wrote:
> > > But is there some reason that mountd/statd need a priv port that I
> > > haven't thought of?
> >
> > I don't think so... since neither mountd or statd checks to see
> > if the source port is a priv port, its not clear why they should
> > listen on one...
>
> I think portmap let's joe doe replace registrations for non-privileged
> ports. Joe Doe can't do that if the port is < 1024.
>
> Denial of service is obvious. The bad things you can do by spoofing
> file handles are probably even more interesting: "You want to
> mount /diskless/root123? Here, try /home/okir/boobytrapped instead"

seems like that sort of security is hopelessly outdated in today's networki=
ng=20
world ... if the authentication tuple is {ip,port}, then spoofing would=20
certainly already be the source of DoS attacks on portmap
=2Dmike

--nextPart3369246.vJA6PknzlH
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIVAwUARiStt0FjO5/oN/WBAQJYYBAArYyYOzHAtGFyLwfPYbeMirL/7Cei7h7g
XVWBPSEdA63yNG12FZ5hmVHzWV5VzavsxwYyF2FYwcwWZt679LiN1I2703bv+0nk
86FwTG1H/S/nE/7ysITOmzfX6tlDS6Pv1ZljrBfjum8UE7ZBWahkZUmAh9pAX7Y6
ZeSFQRUcGgEQqqR/E3n+1NBhWCUXSGMQhmU3Ossnvq+kMUbi5F3bqhM/x7xmKACR
wBxSk89LNYmEt8ybKvQakN4brZRvS9cOdl4LrArwJZeB+WBkfrLE+vpF4jeDwnNp
KKuJaxepFqtzAhj/QwR8j7dHdy+f7YG2oKE3+V3kCjgjh4uGV0SZWVVGfZ5cHSUQ
BsPgiHDcRyA1Q4tvKcw7P/IYKnF0sDae5uOijMByNBZECBsdfgc0023GXGRNRiy4
giQMR5F8WI2ZQVoNeTkjqVk1DKz9BXbvT5g2s6NQ9WyIldnoa84wFS0ENSrrs9Fy
vd1XwfhOEvrhlingzrmFaQ837/cfK+LoOLjO/4p0G88qeYUvIKCG1GSOzgg41WJI
rqebrEFFcmNLq9WW/1NsysQqCcZpdDaRIYZKAzGSdrURjjXLXZxGX4FIIn+SXb9X
R6cY/pRV/nfUXVlKdqeaQ0yrJAcNXGqWDgwUvz2gb/ps3hJdFmtVESZ5OMXY87bw
sM35KFKlCYw=
=JRZh
-----END PGP SIGNATURE-----

--nextPart3369246.vJA6PknzlH--


--===============0743840580==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0743840580==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0743840580==--
