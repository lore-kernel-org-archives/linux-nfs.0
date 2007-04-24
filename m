From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Tue, 24 Apr 2007 08:43:09 +0200
Message-ID: <200704240843.10681.olaf.kirch@oracle.com>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>,
	Javier =?iso-8859-1?q?Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgElE-0004xi-Bd
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 23:44:24 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgElF-0001EY-Pf
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 23:44:27 -0700
In-Reply-To: <17965.15503.703515.820793@notabene.brown>
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

On Tuesday 24 April 2007 01:09, Neil Brown wrote:
> It would be nice if the libritpc version of bindrecvport could be
> configured to avoid some list of ports, whether from /etc/services or
> from elsewhere.

BTW, I wouldn't use /etc/services as the blacklist for bindresvport.
The range of available privileged ports is rather tight already. If
you exclude everything found in /etc/services, you're down to
249 ports in the 512-1024 range (for TCP and UDP, each). This
will not please the 10,000 mounts crowd at Prominent CPU Vendor :)
I really think you want to go with a separate blacklist file.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
