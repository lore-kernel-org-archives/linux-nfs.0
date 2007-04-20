From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 20 Apr 2007 15:27:11 +0200
Message-ID: <200704201527.12634.olaf.kirch@oracle.com>
References: <17958.48121.280256.493824@notabene.brown>
	<200704200849.27004.olaf.kirch@oracle.com>
	<17960.29596.729732.864556@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>,
	Javier =?iso-8859-1?q?Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HetAD-0008QK-Se
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 06:28:37 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HetAG-0002i7-7p
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 06:28:40 -0700
In-Reply-To: <17960.29596.729732.864556@notabene.brown>
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

On Friday 20 April 2007 10:02, Neil Brown wrote:
> I guess.  It would be really nice if we could delay doing the hostname
> lookup until we find a hostname present in hosts.{allow,deny}.  That
> would make it run-time configurable.  I don't think we can do that
> though.

No, that's not the way tcp_wrappers works. It needs to do the
reverse lookup first.

> > That's nice! However, beware you have to patch rpcinfo so that
> > rpcinfo -u does a bindresvport when run as root. And *that*
> > change needs to go into all distros, or you need to get it past
> > Uli "hell will freeze over first" Drepper.
> 
> No change needed.  The rpc library already does bindresvport when
> creating a client.

Ah. I was under the impression the automatic bindresvport call
had been removed at some point in time. But looking at the
glibc cvs it seems it's still there.

> My understanding is that /var/run is cleared early at bood.  So the
> idea was that the choice of path name made all that work
> automatically.

Well, if you want portmap to chroot, then it either has to keep
a file descriptor open for its map file (which would be at odds
with chrooting, because you do that to completely contain
the process); or you would have to put the map file somewhere
under your chroot tree and have to take care of cleaning it
up on boot in a different way.

> And portmap in initrd?  Just Say No. :-)

People have tried to do that, unfortunately.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
