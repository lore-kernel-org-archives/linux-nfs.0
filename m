From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: async vs. sync
Date: Wed, 28 Jul 2004 14:35:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407281435.54555.bernd-schubert@web.de>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407270006.08581.bernd-schubert@web.de> <20040728085644.GD20264@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpnfD-0007I0-J5
	for nfs@lists.sourceforge.net; Wed, 28 Jul 2004 05:36:07 -0700
Received: from smtp06.web.de ([217.72.192.224])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpnfC-0001Re-RX
	for nfs@lists.sourceforge.net; Wed, 28 Jul 2004 05:36:07 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040728085644.GD20264@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello Olaf,

> the way the sync export option affects NFSv3 writes is limited to
> COMMITs, so if you see a slow-down here it must be bottle-necking in
> that part of the code.
>
> Quite possibly, this is a problem of the underlying file system.
> You're using a journaled file system, right? So what seems to happen
> is that on every n-th commit call or so all nfsd processes stall
> as the file system tries to write its journal. Note that the
> VM currently allows dirty data to accumulate for up to 30 seconds
> before it is forcibly written to disk (dirty_expire_centisecs sysctl).
>
> A good way to simulate this is to run several iozone processes on the
> server and tell them to sync() every 1 MB or so.
>
> 	iozone -s 1g -r 1m -o -i 0

I just did some tests:

/home: 10MB/s (mirrored via drbd)
/worka: 60MB/s (not mirrored)

The filesystem is reiserfs in both cases, but it seems drbd has in this case a 
terrible performance problem. I also tested to write to a drbd mirrored ext2 
partition, but it has the same problem, so I think this is filesystem 
independent.

Well, during the testing period of our server, I also tested the drbd 
performance, but unfortunately I did most tests with linux-2.6.7. With 2.6.7 
I got more than 30MB/s over drbd. Well, I also did some tests with 2.4., but 
this was with drbd-0.6.12, now we are using drbd-0.7.0. As far as I remember 
the numbers with drbd-0.6+linux-2.4 were similar or even faster than 
drbd-0.7+linux-2.6.

>
> This takes NFS out of the equation.

It seems you are right, its not a nfs issue.

>
> Maybe it would help to play with the dirty writeback strategy, e.g. by
> lowering /proc/sys/vm/dirty_writeback_centisecs (to e.g. 250), increasing
> dirty_background_ratio or lowering vm_dirty_ratio.

Well, I only see this on 2.6. systems, but not on 2.4., are there similar 
triggers in 2.4.?  With 2.6. we don't have the problem at all.


Thanks a lot for pointing me in the right direction!


Best regards,
	Bernd



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
