From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Prevent oops in nfs_sb_init
Date: Tue, 23 Mar 2004 17:23:16 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040323162316.GO30984@suse.de>
References: <20040323101740.GE24978@suse.de> <1080057625.3109.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5ogR-0007ut-7V
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 08:23:19 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5ogQ-0003ED-Kf
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 08:23:18 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1080057625.3109.10.camel@lade.trondhjem.org>
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

On Tue, Mar 23, 2004 at 11:00:25AM -0500, Trond Myklebust wrote:
> P=E5 ty , 23/03/2004 klokka 05:17, skreiv Olaf Kirch:
> > nfs_sb_init will crash when the fsinfo call fails, because
> > it tries to iput() an uninitialized pointer. The attached patch
> > should fix this.
>=20
> This bug should already be fixed in 2.6.5-rc2...

Ah, good to know.

Thanks,
Olaf
--=20
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
