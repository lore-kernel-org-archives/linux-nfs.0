From: Marco.Schwarz@Freudenberg.de
Subject: AW: NFS & Clustering
Date: Wed, 4 Sep 2002 11:26:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <95AF67BA7F70D511829B0002A551737001C9CC@faw-e01.faw.freudenberg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marco.Schwarz@Freudenberg.de
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Small appendix:

What we are looking for is basically a high-availability solution for =
our
NFS server(s). With the numbers of our diskless clients growing, we =
simply
cannot afford downtimes (this is an industrial production environment). =


My options are to either find a high-availabilty solution for the NFS =
server
or to make the clients work when the server is down. I think I'll try =
the
clustering/HA first ;-)

Regards,
Marco

> -----Urspr=FCngliche Nachricht-----
> Von:	Marco.Schwarz@Freudenberg.de [SMTP:Marco.Schwarz@Freudenberg.de]
> Gesendet am:	Mittwoch, 4. September 2002 10:35
> An:	NFS@lists.sourceforge.net
> Betreff:	[NFS] NFS & Clustering
>=20
> Hi all,
>=20
> we are looking into the possibility of building a clustered NFS-root
> server
> for our diskless clients. Does anybody know if this is possible with =
NFS
> and
> which cluster software is best for this task (OpenMOSIX ?).
>=20
> Thanks in advance,
> Marco
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by: OSDN - Tired of that same old
> cell phone?  Get a new here for FREE!
> https://www.inphonic.com/r.asp?r=3Dsourceforge1&refcode1=3Dvs3390
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
