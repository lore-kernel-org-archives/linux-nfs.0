From: Neil Brown <neilb@suse.de>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Fri, 30 Mar 2007 12:19:49 +1000
Message-ID: <17932.29637.650203.597630@notabene.brown>
References: <17931.15549.578071.112573@notabene.brown>
	<200703291151.59120.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Bernd Schubert <bernd-schubert@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HX6iZ-0001hX-BJ
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 19:19:55 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HX6ib-0008MD-5Q
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 19:19:57 -0700
In-Reply-To: message from Bernd Schubert on Thursday March 29
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

On Thursday March 29, bernd-schubert@gmx.de wrote:
> On Thursday 29 March 2007 06:12:45 Neil Brown wrote:
> > I've finished fiddling with statd, and am happy with mount.nfs now, so
> > it must be time for the first release candidate for nfs-utils-1.1.0.
> >
> 
> While you are working on statd, maybe you can look into a problem I recently 
> had? 
> After the update from Debian Sarge to Etch, the update scripts dumped the 
> current portmapper status to read them in after the portmap restart. Well, 
> this was an update of a chroot and the portmapper never got restartet on the 
> server and so also the dump file wasn't deleted.
> The diskless clients using this chroot read in the dump file, but also 
> couldn't delete it, since it was located in a read-only nfs-export (*).
> 
> The problem was statd, the dumpfile said that statd is running on a port < 
> 1024, but since rpc.statd as user statd is not allowed to use ports <1024, it 
> refused to start up at all.
> 
> Well, while this clearly can and should be solved by removing the stale 
> portmapper dump file, maybe there's also a solution for rpc.statd?

rpc.statd used to drop root privilege before binding the port to
listen on.  This is fixed in 1.1.0, so that little part of your
problem should go away.

NeilBrown


> 
> 
> Thanks,
> Bernd
> 
> PS: (*) Somewhere in /var, which will become writable after a union mount, 
> which will be done after the start-up of portmap.
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys-and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
