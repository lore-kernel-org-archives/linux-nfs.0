From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to
 listen	on a privileged port??
Date: Tue, 24 Apr 2007 11:31:05 -0400
Message-ID: <EXNANE01tUvh18cbKTr000008ec@exnane01.hq.netapp.com>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240843.10681.olaf.kirch@oracle.com>
	<17965.45214.71167.310005@notabene.brown>
	<EXNANE01v00J6gX2Xdo000008eb@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Steve Dickson <SteveD@redhat.com>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	=?iso-8859-1?Q?Pe=F1a?= <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgN01-0007L5-UN
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 08:32:14 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgMzz-0003ix-DG
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 08:32:11 -0700
In-Reply-To: <EXNANE01v00J6gX2Xdo000008eb@exnane01.hq.netapp.com>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240843.10681.olaf.kirch@oracle.com>
	<17965.45214.71167.310005@notabene.brown>
	<EXNANE01v00J6gX2Xdo000008eb@exnane01.hq.netapp.com>
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

At 11:15 AM 4/24/2007, Talpey, Thomas wrote:
>At 03:24 AM 4/24/2007, Neil Brown wrote:
>> 2/ tcp sockets that linger in CLOSE_WAIT thus preventing other
>>    sockets from binding to the same address.  This prevents
>>    privilege ports being used at a high rate.
>>    Using UDP avoid this problem but is not always acceptable.
>>    I wonder if we could make more use of SO_REUSEADDR in
>>    bindresvport.
>
>This is risky - while it allows rapid rebinding to the ports, it also
>allows old duplicate packets in the network to arrive at the newly
>rebound port, potentially causing it to reset and/or produce
>unexpected statuses. I would not recommend this as a design
>requirement!

OBTW - I assume you mean TIME_WAIT not CLOSE_WAIT...

SO_REUSEADDR can't seize a port used by a socket in CLOSE_WAIT
because the kernel is waiting for the local file descriptor to be
closed. IOW, this is a different problem, and should be short
lived, provided that the process that owns the fd is running.

There are also such problems as FIN_WAIT_2, which are even
harder to escape from. Bottom line, better to avoid overloading
privileged ports as a protection mechanism here, and instead
strengthen the portmap/rpcbind registration as mentioned before.

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
