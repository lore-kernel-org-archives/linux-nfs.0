From: Marco.Schwarz@Freudenberg.de
Subject: AW: URGENT: Problems with NFS-Root-Clients
Date: Tue, 27 Aug 2002 17:52:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <95AF67BA7F70D511829B0002A551737001C9C4@faw-e01.faw.freudenberg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [153.95.95.71] (helo=itnts96.freudenberg.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jifI-0000Ze-00
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 08:54:00 -0700
To: bogdan.costescu@iwr.uni-heidelberg.de
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

Right before this the network driver is configured (and yes, its in the
kernel ... it is not working most of the time, but sometime it is, and =
some
days ago it was the other way ... working most of the time, just =
sometimes
problems).

Network cards are Intel EEPro100, but we have a lot more of these (also =
with
diskless clients, same configuration/kernel), and the problem is =
happening
in just this one location ...

The 3 Lines before the errors:

Sending BOOTP requests . OK
IP-Config: Got BOOTP answer from 192.168.0.235, my adress is =
192.168.0.87
IP-Config: Complete:
  (lots of ip adresses, all look OK).

Regards,
Marco

> -----Urspr=FCngliche Nachricht-----
> Von:	Bogdan Costescu [SMTP:bogdan.costescu@iwr.uni-heidelberg.de]
> Gesendet am:	Dienstag, 27. August 2002 17:40
> An:	Marco.Schwarz@Freudenberg.de
> Cc:	nfs@lists.sourceforge.net
> Betreff:	Re: [NFS] URGENT: Problems with NFS-Root-Clients
>=20
> On Tue, 27 Aug 2002 Marco.Schwarz@Freudenberg.de wrote:
>=20
> > NET4: Unix domain sockets 1.0/SMP for Linux NET4.0
>=20
> What are the lines just before this one ? Some network driver should =
be=20
> initialized there, provided that you selected it for compilation into =
the=20
> kernel (you did, didn't you ?)
>=20
> > Root-NFS: Server returned error -5 while mounting
> /netclients/192.168.0.87
>=20
> The whole thing seems to me like there is no network connectivity.
>=20
> --=20
> Bogdan Costescu
>=20
> IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
> Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
> Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
> E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
