From: M A Young <m.a.young@durham.ac.uk>
Subject: Re: NFS client fcntl locks going missing on FC6
Date: Sat, 24 Feb 2007 18:06:57 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0702241754030.21958@vega4.dur.ac.uk>
References: <Pine.LNX.4.58.0702232223170.24593@vega3.dur.ac.uk>
	<45E073AB.2040005@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HL1Ip-0004ne-Fi
	for nfs@lists.sourceforge.net; Sat, 24 Feb 2007 10:07:23 -0800
Received: from hermes1.dur.ac.uk ([129.234.8.20])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HL1Ir-0007Xv-1J
	for nfs@lists.sourceforge.net; Sat, 24 Feb 2007 10:07:25 -0800
In-Reply-To: <45E073AB.2040005@RedHat.com>
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

On Sat, 24 Feb 2007, Steve Dickson wrote:

> Looking at the 2.6.20 kernel, it appears some precautions were
> taken for this race since the lock is checked locally for any
> conflicts (i.e. do_vfs_lock() is called with fl_flags & FL_ACCESS),
> but there still might be an problem since if the second call to
> do_vfs_lock() (the one that actually records the lock in the VFS)
> fails, a unlock is *not* sent back to the server....
> Although  this error condition will be noted with the
> following syslog message:
>      "nlmclnt_lock: VFS is out of sync with lock manager!"
>
> So are you seeing this type of message in /var/log/messages?

I have not had a chance to try a 2.6.20 kernel, but with the 2.6.19 Fedora
kernels we do see a lot of errors like
do_vfs_lock: VFS is out of sync with lock manager!

I have been doing more checking, and I couldn't successfully repeat my
experiment running my program twice on a single nfs client, but running it
on two different NFS clients at the same time works every time. The
type of NFS server doesn't seem to matter, as I have reproduced the
problem with a linux NFS server.

	Michael Young

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
