From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Thu, 19 Apr 2007 11:50:44 -0400
Message-ID: <20070419155044.GD9101@fieldses.org>
References: <17950.44333.118970.276558@notabene.brown>
	<4623BCD9.3090501@RedHat.com>
	<200704171208.51797.olaf.kirch@oracle.com>
	<17957.50539.958277.446719@notabene.brown>
	<17958.48121.280256.493824@notabene.brown>
	<46278794.6050307@RedHat.com> <20070419152149.GA9101@fieldses.org>
	<46278DE3.9020509@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Matthias Koenig <mkoenig@novell.com>,
	nfs@lists.sourceforge.net, jfs@computer.org,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeYuF-00007J-Lj
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 08:50:48 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeYuH-0001Hj-1G
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 08:50:50 -0700
In-Reply-To: <46278DE3.9020509@RedHat.com>
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

On Thu, Apr 19, 2007 at 11:42:27AM -0400, Steve Dickson wrote:
> J. Bruce Fields wrote:
> >And it that upstream version could still live in the nfs-utils tree,
> >couldn't it?  Or it annoying to build multiple binary packages from one
> >upstream tree for some reason?
> Its not so much the annoyance... its the fact that other services
> like NIS also depend on portmap/rpcbind. Why should we require an
> AFS shop to install nfs-utils just so they can run NIS?

Right.  I mean:  can't you build separate portmap and nfs-utils rpms
from the same nfs-utils source, and then make AFS depend only on the
portmap package?  I thought it was pretty common to do that sort of
thing.

But maybe there's no particular advantage to having the two together
anyway.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
