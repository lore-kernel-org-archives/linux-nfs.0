From: Jan Kasprzak <kas@fi.muni.cz>
Subject: mountd gives "illegal port"
Date: Wed, 27 Oct 2004 14:42:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041027124228.GJ4724@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMn8M-00074I-La
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 05:42:34 -0700
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CMn8L-0007r9-Id
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 05:42:34 -0700
Received: from anxur.fi.muni.cz (IDENT:0@anxur.fi.muni.cz [147.251.48.3])
	by anor.ics.muni.cz (8.12.1/8.12.1) with ESMTP id i9RCgU4k025165
	for <nfs@lists.sourceforge.net>; Wed, 27 Oct 2004 14:42:30 +0200
Received: from anxur.fi.muni.cz (IDENT:11561@localhost [127.0.0.1])
	by anxur.fi.muni.cz (8.12.10/8.12.8) with ESMTP id i9RCgTc4011374
	for <nfs@lists.sourceforge.net>; Wed, 27 Oct 2004 14:42:29 +0200 (MEST)
Received: (from kas@localhost)
	by anxur.fi.muni.cz (8.12.10/8.12.8/Submit) id i9RCgT9S011371
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 14:42:29 +0200 (MEST)
To: nfs@lists.sourceforge.net
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

I have discovered the following problem in Linux NFS: When you mount
many filesystems from the same server, mountd sometimes refuses the
request with "illegal port" message in syslog. To reproduce this, I did
the following:

On the NFS server:
# for i in `seq 1 2048`; do mkdir /tmp/nfs/$i; echo "$i" >/tmp/nfs/$i/index-$i.txt; echo "/tmp/nfs/$i    *.fi.muni.cz(ro)"; done >/etc/exports
# exportfs -a

On the NFS client;
# for i in `seq 1 2048`; do mkdir /tmp/nfs/$i; done
# for i in `seq 1 100`; do echo $i; mount -t nfs -r nfs-server:/tmp/nfs/$i /tmp/nfs/$i || break; done

It fails after random number of iterations (seen 6 to 57) with

mount: nfs-server:/tmp/nfs/6 failed, reason given by server: Permission denied

And in NFS server the following is added to syslog:

Oct 27 14:28:48 nfs-server rpc.mountd: refused mount request from nfs-client.fi.muni.cz for /tmp/nfs/6 (/tmp/nfs/6): illegal port 54071

The situation seems a bit better when you add "sleep 5" to the mount loop.
Sleep 2 does not help, though.

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
