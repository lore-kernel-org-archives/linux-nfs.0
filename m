From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: nfsd stales when restarting too fast
Date: Tue, 10 Aug 2004 11:06:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4118900F.9090602@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: shylendra.bhat@hp.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BuSaS-0003SZ-76
	for nfs@lists.sourceforge.net; Tue, 10 Aug 2004 02:06:28 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BuSaR-0002sI-IE
	for nfs@lists.sourceforge.net; Tue, 10 Aug 2004 02:06:28 -0700
To: nfs@lists.sourceforge.net
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

Hi,

I posted this on the kernel list already, but now that I'm subscribed here
I guess this is the better place :-) Neil already reacted to my mail on
LKML but the first proposal didn't help (order of exportfs and killall).

System is: SuSE 9.0 with 2.6.7 (tested up to 2.6.8rc3) and util-linux-2.12

Also tested with SuSE 9.1/SLES9 and SuSEs kernel 2.6.5.

When running "/etc/init.d/nfsserver restart" on the server, the clients
will react with "stale nfs handle" for all mounted directories that were
in use during the restart (e.g. if /var is mounted and syslogd is running,
or if some "find" is running on a mounted directory). The stale directories
will never come back to sane state (except restarting with sleep, see below).

When using
/etc/init.d/nfsserver stop
sleep 2
/etc/init.d/nfsserver start

(or putting a "sleep 1" between the lines "$0 stop" and "$0 start" in the
init script), everything goes fine. Restarting with sleep 2 will also
bring back the client dirs that were staled from a former restart without
sleep.

Without the init script, it can be traced down to:

killall -9 nfsd
killall -9 /usr/sbin/rpc.mountd
/usr/sbin/exportfs -au
[sleep 2]
/usr/sbin/exportfs -r
/usr/sbin/rpc.nfsd
/usr/sbin/rpc.mountd

Stales without the sleep, does not with the sleep. That behaviour is
independent from options like v3/v4, tcp/udp, lock/nolock, and it did
not happen with 2.4.

Unless this is sth. easy to fix in the kernel nfsd or client, it might
be a good idea to insert such a sleep statement in the distributors
init scripts to avoid people running into this error. I assume the
problem in the mail "machine hangs - SLES9/NFS" was caused by the
same problem.


cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
