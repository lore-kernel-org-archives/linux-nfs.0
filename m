From: Neil Brown <neilb@suse.de>
Subject: Re: rpc.statd  in /sbin or /usr/sbin ??
Date: Fri, 23 Mar 2007 14:21:54 +1100
Message-ID: <17923.18386.141920.241463@notabene.brown>
References: <17917.58341.502839.29524@notabene.brown>
	<200703190924.03153.olaf.kirch@oracle.com>
	<45FE8782.5020001@RedHat.com>
	<17922.4151.996812.925495@notabene.brown>
	<EXNANE01pMmOlbcrYP000000296@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUaLv-0007fR-0C
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 20:22:11 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUaLw-0006ma-6l
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 20:22:09 -0700
In-Reply-To: message from Talpey, Thomas on Thursday March 22
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

On Thursday March 22, Thomas.Talpey@netapp.com wrote:
> At 01:12 AM 3/22/2007, Neil Brown wrote:
> >So how about this: In a similar way that we now try to start statd if
> >'nolock' is not set, we could set 'nolock' if we fail to start statd
> >(and it isn't already running).  What do people think of that?
> 
> Gack. At worst, the mount should fail, instead of silently changing the

Yes, failing would be adequate, and safer.

> mount to one which may break application semantics! This would change
> the default behavior in a way the admin couldn't override. Besides,
> what's to say statd won't die later?

The point is not to be alert for system malfunctions so much as to be
alert for mis-configurations.
Mounting an NFS filesystem with remote-locking enabled but without
having started statd is the wrong thing to do.  It seems that people
discover that and then want to start statd earlier.  I want to make
sure that when they discover that, they are encouraged to use local
locking if appropriate.

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
