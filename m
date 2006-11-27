From: Ian Kent <raven@themaw.net>
Subject: Re: "mount: File exists" when trying to mount a second
	krb5	volume!
Date: Mon, 27 Nov 2006 19:58:04 +0800
Message-ID: <1164628684.3178.10.camel@localhost>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<1164228193.5694.38.camel@lade.trondhjem.org>
	<52109fb10611221443w356ff6s4eae49ebb0d935ec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gof7m-0004jO-KH
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 03:58:14 -0800
Received: from out2.smtp.messagingengine.com ([66.111.4.26])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gof7l-0005fF-Nk
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 03:58:16 -0800
To: Paarvai Naai <opensource3141@gmail.com>
In-Reply-To: <52109fb10611221443w356ff6s4eae49ebb0d935ec@mail.gmail.com>
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

On Wed, 2006-11-22 at 14:43 -0800, Paarvai Naai wrote:
> Hi Trond,
> 
> I'm certain the problem is causing a crash on my machine.
> When I am on the console and just do an umount the machine is okay
> for about 2 seconds and then it crashes.  If I instead just try to do
> /sbin/reboot then I see a big OOPS when the initscripts end up 
> unmounting the NFS filesystems, although it's hard to make sense
> of it or write any info down at that point.

Doesn't it get logged.
syslog should shutdown after autofs and NFS.

Ian



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
