From: Jan Kasprzak <kas@fi.muni.cz>
Subject: nfsd: too may open TCP sockets
Date: Thu, 11 Nov 2004 16:11:27 +0100
Message-ID: <20041111151127.GN13905@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: unix@fi.muni.cz
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CSGce-0001We-SY
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 07:12:28 -0800
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CSGcd-00048s-6j
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 07:12:28 -0800
Received: from anxur.fi.muni.cz (IDENT:0@anxur.fi.muni.cz [147.251.48.3])
	by anor.ics.muni.cz (8.12.1/8.12.1) with ESMTP id iABFCPC0027919
	for <nfs@lists.sourceforge.net>; Thu, 11 Nov 2004 16:12:25 +0100
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

	Hi all,

I've got the following on my server (after migrating home directories
of ~2200 users and serving ~200 clients from it):

nfsd: too many open TCP sockets, consider increasing the number of nfsd threads

We have increased nfsd threads to 50, then 100, and now I am at 200:

# ps ax|grep -c nfsd
202

The server has load avg <1, so maybe it should be possible to increase
a per-thread descriptor count or something like that. How can I do this?
I think it is an overkill to have 200 nfsd threads on a machine with
only 4 CPUs and ~10 RAID volumes.

	Thanks,

-Yenya

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
> Whatever the Java applications and desktop dances may lead to, Unix will <
> still be pushing the packets around for a quite a while.      --Rob Pike <


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
