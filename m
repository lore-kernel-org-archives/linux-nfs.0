From: Andreas Unterluggauer <au@literaturhaus.at>
Subject: Re: NFS problems across reboot
Date: Mon, 08 Apr 2002 14:15:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CB189DE.1B3AE1CD@literaturhaus.at>
References: <3CACA93C.5010304@blue-labs.org>
		<3CAD6A78.4205CD61@moving-picture.com>
		<3CAFCE8C.5030300@blue-labs.org>
		<15535.55222.401084.736426@notabene.cse.unsw.edu.au>
		<3CAFEE3C.8020606@blue-labs.org> <15537.1257.212812.909225@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Received: from etwasmea.literaturhaus.at ([194.152.172.210] helo=mail.literaturhaus.at)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uY3f-0005w8-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 05:15:40 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

>=20
> "Exporting" a filesystem means doing two things:
>  1/ telling mountd that it is allow to respond positively to mount
>      requests.
>  2/ telling the kernel nfsd that it is allow to respond to access
>      requests.
>=20
> When mountd responds to a mount request, it also tells the kernel to
> respond to access requests.
> But after a reboot, you need to run exportfs.  It reads
> /var/lib/nfs/rmtab to find out which clients have which filesystems
> mounted, and it tells the kernel to allow those clients to access
> those filesystem.

Is it sufficent, if exportfs -r is run before rpc.nfsd are started
instead of exportfs -a?
The startscripts of redhat 6.2 uses exportfs -r (and we sometimes have
troubles with stale mounts).

andi

--=20
Andreas Unterluggauer
Dokumentationsstelle f=FCr neuere =F6sterreichische Literatur
A-1070 Wien, Seidengasse 13      http://www.literaturhaus.at
Tel. +43/1/526 20 44-11, Fax -30, e-mail au@literaturhaus.at

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
