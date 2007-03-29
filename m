From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Thu, 29 Mar 2007 10:20:43 -0400
Message-ID: <1175178043.6182.4.camel@heimdal.trondhjem.org>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
	<20070329124446.GZ23295@sith.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWvUo-0003ZD-EH
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 07:20:58 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/W5VgGEf05bFDK67WCVbOCyVE2iAzdyIQ=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWvUn-0006on-Do
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 07:21:00 -0700
In-Reply-To: <20070329124446.GZ23295@sith.mimuw.edu.pl>
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

On Thu, 2007-03-29 at 14:44 +0200, Jan Rekorajski wrote:

> >   - idmapd and svcgssd should be started before nfsd
> 
> Here I must disagree, my experience shows that idmapd must be started (or
> at least restarted) after mountd (or exportfs) is run.
> I had no id mapping when I started idmapd before mountd/nfsd.

The only reason I can think of why you might have to restart idmapd
after mountd is if your idmapd init script is failing to
mount /proc/fs/nfsd.

> >  idmapd/svcgssd/gssd:
> >    simply provide service to the kernel modules.   So they should
> >    be running before the kernel wants them.
> 
> What's troubling me here is svcgssd - does it behave like idmapd and
> requires mountd? My quick investigation in the source telss me it is so.

Ditto. svcgssd also assumes that you have mounted /proc/fs/nfsd. Fix
your svcgssd init script if this is not already the case.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
