From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to
 listen	on a privileged port??
Date: Tue, 24 Apr 2007 11:15:57 -0400
Message-ID: <EXNANE01v00J6gX2Xdo000008eb@exnane01.hq.netapp.com>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240843.10681.olaf.kirch@oracle.com>
	<17965.45214.71167.310005@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Javier@sc8-sf-spam2.sourceforge.net, Neil Brown <neilb@suse.de>,
	Steve Dickson <SteveD@redhat.com>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	=?iso-8859-1?Q?_Pe=F1a?= <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgMoI-00065J-Np
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 08:20:07 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgMoL-0006XP-25
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 08:20:09 -0700
In-Reply-To: <17965.45214.71167.310005@notabene.brown>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240843.10681.olaf.kirch@oracle.com>
	<17965.45214.71167.310005@notabene.brown>
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

At 03:24 AM 4/24/2007, Neil Brown wrote:
> 2/ tcp sockets that linger in CLOSE_WAIT thus preventing other
>    sockets from binding to the same address.  This prevents
>    privilege ports being used at a high rate.
>    Using UDP avoid this problem but is not always acceptable.
>    I wonder if we could make more use of SO_REUSEADDR in
>    bindresvport.

This is risky - while it allows rapid rebinding to the ports, it also
allows old duplicate packets in the network to arrive at the newly
rebound port, potentially causing it to reset and/or produce
unexpected statuses. I would not recommend this as a design
requirement!

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
