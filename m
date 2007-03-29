From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Thu, 29 Mar 2007 12:45:20 -0400
Message-ID: <EXNANE01NKBqujsclWX0000049f@exnane01.hq.netapp.com>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
	<20070329124446.GZ23295@sith.mimuw.edu.pl>
	<1175178043.6182.4.camel@heimdal.trondhjem.org>
	<20070329163521.GB6143@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Jan Rekorajski <baggins@sith.mimuw.edu.pl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWxmi-0002p7-QG
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 09:47:37 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWxmj-0006Lc-VS
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 09:47:39 -0700
In-Reply-To: <20070329163521.GB6143@fieldses.org>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
	<20070329124446.GZ23295@sith.mimuw.edu.pl>
	<1175178043.6182.4.camel@heimdal.trondhjem.org>
	<20070329163521.GB6143@fieldses.org>
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

At 12:35 PM 3/29/2007, J. Bruce Fields wrote:
>> Ditto. svcgssd also assumes that you have mounted /proc/fs/nfsd. Fix
>> your svcgssd init script if this is not already the case.
>
>That's been a common source of errors in the past.  Maybe svcgssd and
>idmapd should be taught to watch for changes to the /proc/ directories
>it cares about, maybe using dnotify or inotify.

Does inotify work on /proc? Cool!

Anyway, I totally agree on the /proc/fs/nfsd pipefs. I remember being
quite surprised when I first discovered that it usually is mounted by a
single-line shell script deeply buried in /etc/modprobe.d/modprobe.conf.dist.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
