From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS O_DIRECT data_updates desync
Date: Mon, 17 May 2004 12:15:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084810546.3669.36.camel@lade.trondhjem.org>
References: <20040517153229.GN14755@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPkmS-0000ij-97
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 09:15:56 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BPkmR-0002f3-VZ
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 09:15:56 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040517153229.GN14755@suse.de>
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

P=E5 m=E5 , 17/05/2004 klokka 11:32, skreiv Olaf Kirch:
> Hi Trond, Chuck,
>=20
> there's a code path in nfs_direct_write_seg where
> NFS_I(inode)->data_updates can get out of sync with reality,
> which will lead to a BUG() in nfs_clear_inode later on.
>=20
> I'm attaching a patch that addresses this issue.

Applied...

Thanks,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
