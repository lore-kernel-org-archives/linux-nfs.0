From: =?koi8-r?Q?=22?=Peter Lojkin=?koi8-r?Q?=22=20?= <ia6432@inbox.ru>
Subject: Re: nfsd random drop
Date: Thu, 01 Apr 2004 20:14:25 +0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1B94pl-000G74-00.ia6432-inbox-ru@f13.mail.ru>
References: <20040401102334.GC20772@suse.de>
Reply-To: =?koi8-r?Q?=22?=Peter Lojkin=?koi8-r?Q?=22=20?= <ia6432@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: =?koi8-r?Q?=22?=Neil Brown=?koi8-r?Q?=22=20?= <neilb@cse.unsw.edu.au>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9AXM-0007ck-VU
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 14:19:48 -0800
Received: from fallback.mail.ru ([194.67.57.14] helo=mx4.mail.ru)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9AXM-0005Jz-Gk
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 14:19:48 -0800
Received: from f13.mail.ru (f13.mail.ru [194.67.57.43])
	by mx4.mail.ru (mPOP.Fallback_MX) with ESMTP id 0E9CFE83EC
	for <nfs@lists.sourceforge.net>; Thu,  1 Apr 2004 20:22:33 +0400 (MSD)
To: =?koi8-r?Q?=22?=Olaf Kirch=?koi8-r?Q?=22=20?= <okir@suse.de>
In-Reply-To: <20040401102334.GC20772@suse.de>
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

On Thu, 1 Apr 2004 at 12:23:34 +0200, Olaf Kirch wrote:

> I hate to bore you all with the same old stuff, but I'm still fighting
> problems caused by nfsd's dropping active connections.
thank you for trying to resolve this!

> Consider a network with a single Linux 2.4 based home server, a few
> hundred clients, all using TCP. In Linux 2.4, nfsd starts dropping
> connections when it reaches a limit of (nrthreads + 3) * 10 open
> connections. With 4 threads, this means 70 connections, and with 8 thre=
ads
> this means 110 connections max. Both of which is totally inadequate for
> this network. To get out of the congestion zone, we would need to bump
> the number of threads to about 20, which is just silly.
>=20
> The very same network has been served well with just 4 threads all
> the time while using UDP.
YES! we have exactly such setup and we need tcp.

> Second: People have reported that files vanished and/or rename/remove
> operations failed.
YES! we do have such problems. not often (about once or twice per week)
but it's really annoying and we had to insert a lot of checks and
timeouts in our soft as a workaround. we never found out what was the
cause of it and how to reliably repeate the fault...

> I propose to add the following two patches to the server and client. Th=
ey
> increase the connection limit, stop dropping the neweset socket, and
> add some printk's to alert the admin of the contention.
i hope this will help. i'll try this patches next time we reboot
fileserver...

> As an alternative to hardcoding a formula based on the number of thread=
s,
> I could also make the max number of connections a sysctl.
this would be better i think...



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
