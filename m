From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: async vs. sync
Date: Tue, 27 Jul 2004 00:06:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407270006.08581.bernd-schubert@web.de>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407261905.40248.bernd-schubert@web.de> <41055FE5.3030206@bruvoll.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_QBYBBgwspxh2bJx";
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpDbu-0000JA-FN
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 15:06:18 -0700
Received: from smtp05.web.de ([217.72.192.209])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpDbt-0007jz-RB
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 15:06:18 -0700
Received: from [80.140.20.159] (helo=bathl.lan.fli4l)
	by smtp05.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.101 #44)
	id 1BpDbm-0002PL-00
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 00:06:11 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <41055FE5.3030206@bruvoll.com>
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


--Boundary-02=_QBYBBgwspxh2bJx
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

> are you doing anything "interesting" underneath NFS, ie. what are you
> storing your files on?

Its similar to your configuration ;)

> My set-up has about the same performance data, however my big problem is
> that the server dies when I hook all my clients up... Raw throughput

=46ortunately that doesn't seem to happen in our case.

> seemed ok, but when you started complaining about the speed, I started
> thinking that my figures weren't all that great anymore.

At least its good to know that we are not alone. Well, I do know about the=
=20
performance decrease of sync-exports for a pretty long time, but I was neve=
r=20
sure if its not only a problem of our server (the previous one was a=20
PII-450).

>
> The set-up is a dual 3Ghz Xeon, 2Gb RAM, and a DRBD-mirrored partition
> sitting on a 3Ware Escalade 7500 to 7200rpm disks. Kernel

Here its a dual opteron, 3GB RAM, adaptec 79xx PCI-X scsi, transtec scsi-id=
e=20
raid. Local disk i/o is over 70MB/s. The server is connected with GBit, the=
=20
clients only with 100MBit. Here are some performace numbers when the server=
=20
was still running 2.6.7:

writing to /worka (async exported): 4 clients, all at full 11MB/s

writing to /home, (sync,no_wdelay exported): 4 clients at 7MB/s

(When I did the tests I was simply to lazy to test with more clients. Actua=
lly=20
I thought that 4 times 7 MB/s is more than sufficient for usual work).

The /home partition is also mirrored via drbd to a failover server, /worka =
is=20
not mirrored (mirroring 1.7TB is not that easy as mirroring 200GB ;) ).

So I really don't think that the server performance is the problem.

> 2.4.26-gentoo-r5, everything else newest version. The annoying thing is
> that the server this new set-up is replacing is an old P3/650 that
> easily copes with the load... :-\

Well, as I said, when I tested our old server with sync mounts, it had the=
=20
same problem. Are you sure that your old server did not export asynchronous?

Cheers,
	Bernd

--Boundary-02=_QBYBBgwspxh2bJx
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBBYBQC8BUnAF+ydYRAkY0AJ0WDSYRXG9ZD6DPdPme6+pBTYnFfACfWadk
fDNGthBbgF4R2uIeiepDRus=
=1uIT
-----END PGP SIGNATURE-----

--Boundary-02=_QBYBBgwspxh2bJx--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
