From: Neil Brown <neilb@suse.de>
Subject: Re: RFC - NFS startup order
Date: Wed, 4 Apr 2007 12:56:47 +1000
Message-ID: <17939.5103.141632.576498@notabene.brown>
References: <17937.44243.21793.371809@notabene.brown>
	<4d569c330704030649n14c6d82bw633aafc390a0e09e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Kevin Coffman" <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYvgF-00026P-0b
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 19:57:03 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYvgF-0005Ef-Qj
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 19:57:05 -0700
In-Reply-To: message from Kevin Coffman on Tuesday April 3
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


Thanks for the fixes.

On Tuesday April 3, kwc@citi.umich.edu wrote:
> 
> idmapd should be started before mounting any NFSv4 filesystems.
> gssd is only needed when filesystems are mounted securely (with
> Kerberos or SPKM3).  It must be started before mounting any NFS
> filesystems securely.

Would it be practical/valuable to auto-start idmapd and gssd similar
to the way we now auto-start statd.
And would it be OK to refuse to mount if the relevant daemon could not
be started?

I would want code in mount.nfs that could reliably test if the daemon
were running, and would probably replace 'start-statd' with
'start-nfs-daemons' and give it a list of daemons required.

Thoughts?

> 
> Both the server and client need idmapd to be running.  If idmapd is
> started (for the client) before starting nfsd (or is it mountd?), then
> idmapd should be sent a HUP signal after starting nfsd (mountd?) to
> signal that the server channels should be opened.

I've changed that to

      Both the server and client need idmapd to be running.  If idmapd
      is started (for the client) before starting nfsd the 'nfsd'
      filesystem is mounted, then idmapd should be sent a HUP signal
      afterwards to signal that the server channels should be opened.

Let me know if I've got it wrong.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
