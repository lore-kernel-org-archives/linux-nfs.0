From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Prevent oops in nfs_sb_init
Date: Tue, 23 Mar 2004 11:00:25 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080057625.3109.10.camel@lade.trondhjem.org>
References: <20040323101740.GE24978@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5oKR-0004jc-Rc
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 08:00:35 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B5oKR-0005Fj-Lj
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 08:00:35 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040323101740.GE24978@suse.de>
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

P=E5 ty , 23/03/2004 klokka 05:17, skreiv Olaf Kirch:
> nfs_sb_init will crash when the fsinfo call fails, because
> it tries to iput() an uninitialized pointer. The attached patch
> should fix this.

This bug should already be fixed in 2.6.5-rc2...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
