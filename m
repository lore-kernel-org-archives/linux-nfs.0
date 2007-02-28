From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: nfs-utils 1.0.11 still seems broken
Date: Wed, 28 Feb 2007 11:47:26 +0100
Message-ID: <20070228104726.GA6866@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMMME-0000yB-2N
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 02:48:26 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HMMME-0001Vl-NY
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 02:48:28 -0800
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1HMMM7-0006i7-D5
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 11:48:19 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1HMMLG-0001nK-00
	for <nfs@lists.sourceforge.net>; Wed, 28 Feb 2007 11:47:26 +0100
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

Hi,

It looks like nfs-utils 1.0.11 is still broken, only now in completely
different ways. My NFS server (kernel 2.6.19.2) upgraded yesterday, and
tonight my desktop machine with NFS root (2.6.19) seems to have hung. The
screen said

  Looking up port of RPC 100003/2 on 10.0.0.10
  Looking up port of RPC 100005/1 on 10.0.0.10

And then nothing more until it gave up. (It seemed to send stuff on port 2049
to the NFS server, though.)

This was consistent across boots. Downgrading to 1.0.10 fixed the problems
immediately; the second I go back to 1.0.11 and restart the server the client
goes "nfs: server 10.0.0.10 not responding, still trying". Downgrading again
fixes it.

With 1.0.11, dmesg seems to show:

  nfsd: last server has exited
  nfsd: unexporting all filesystems
  RPC: failed to contact portmap (errno -5).
  NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
  NFSD: starting 90-second grace period

so this looks to be portmap related somehow. It should be noted that I also
see the issue with

  Feb 28 11:46:17 moccamaster nfsd[6273]: nfssvc: writting fds to kernel failed: errno 0 (Success)

but that also shows up with 1.0.10, so it probably isn't that.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
