From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Using mmap result in data corruption
Date: Fri, 12 Nov 2004 14:34:53 -0500
Message-ID: <1100288093.15999.17.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0411122101130.10567@ihme.ihme.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CShCR-0000sC-OS
	for nfs@lists.sourceforge.net; Fri, 12 Nov 2004 11:35:11 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CShCN-0002rK-LE
	for nfs@lists.sourceforge.net; Fri, 12 Nov 2004 11:35:11 -0800
To: Miika Pekkarinen <miipekk@ihme.org>
In-Reply-To: <Pine.LNX.4.58.0411122101130.10567@ihme.ihme.org>
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

fr den 12.11.2004 Klokka 21:06 (+0200) skreiv Miika Pekkarinen:

> I have found a reproducable issue with NFS that will lead to file
> corruption on server. When a file is created with O_TRUNC and data is
> copied using mmap, the new file on the server will be filled with null bytes.

mmap() offers absolutely NO guarantees that the file will be synced to
disk on close. Use msync(MS_SYNC) if you want such a guarantee.

Cheers,
 Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
