From: James Pearson <james-p@moving-picture.com>
Subject: Re: Cannot umount NFS mounted cdrom
Date: Fri, 18 Oct 2002 14:21:39 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DB00AE3.70C60391@moving-picture.com>
References: <200210181441.14640.Nicolas.Turro@sophia.inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182X4Y-0003Oo-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Oct 2002 06:21:50 -0700
To: Nicolas Turro <Nicolas.Turro@sophia.inria.fr>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Try unexporting the CD mount point on host A - see:

http://marc.theaimsgroup.com/?l=linux-nfs&m=100166778506852&w=2

James Pearson

Nicolas Turro wrote:
> 
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Hi,
> We use linux 2.4.17 and knfsd-0.2.1-1 and we have a problem :
> 1- we mount an ISO cdrom on host A on /mnt/cdrom
> 2- we do a NFS mount of A:/mnt/cdrom /tmp/remotecdrom on host B
> 3- we umount /tmp/remotecdrom on host B
> 4- when we try to umount /mnt/cdrom on host A, he get fs busy and it fails.
> lsof doesn't give any process using /mnt/cdrom
> 
> Is-this a known problem ? Any workaround ?
> 
> Thx in advance.
> 
> N. Turro
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.0.6 (GNU/Linux)
> Comment: For info see http://www.gnupg.org
> 
> iD8DBQE9sAFqty/HpgyBIboRAiu+AJ0R2fJDOEp4zGcLZxBKYiDczFbg/gCfUwUX
> nIUTITIVtDN+9Ch05JM1bco=
> =0oqr
> -----END PGP SIGNATURE-----
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
