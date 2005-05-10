From: liz <liz@unixgrrl.net>
Subject: NFS and failover
Date: Mon, 09 May 2005 17:37:01 -0700
Message-ID: <4280022D.1080604@unixgrrl.net>
Reply-To: liz@unixgrrl.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVIkC-0002Hl-3L
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 17:37:04 -0700
Received: from imap.infopop.com ([63.251.4.15] ident=mirapoint)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DVIkB-0002fv-Pk
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 17:37:04 -0700
To: nfs@lists.sourceforge.net
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

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Greetings,

I'm a Solaris turned linux admin :P In solaris i was able to specify
multiple hostnames for NFS failover. It appear that Linux has some
support for it. I added the multiple hostnames into the /etc/fstab but
mount throws an error about multiple hostanames not being supported.
Do I need a pathched version of mount. I have read a few web pages in
my search that alluded to the fact client failover was supported? It
also dicusses in my NFS book ( I love that book!)

Any ideas?

Thanks,
Liz
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCgAIslt/irWun80cRArglAJ0VNximm9xuLPHsxvG6abTx6wAkewCdGA07
M5OnAEG5FWPElWgUoTl5Ai0=
=QY3T
-----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
