From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd stales when restarting too fast
Date: Wed, 18 Aug 2004 13:24:34 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16674.52210.884853.119652@cse.unsw.edu.au>
References: <4118900F.9090602@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    shylendra.bhat@hp.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxH4I-0008Sa-Ou
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 20:24:54 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BxH4H-0004H9-0W
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 20:24:54 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: message from Frank Steiner on Tuesday August 10
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

On Tuesday August 10, fsteiner-mail@bio.ifi.lmu.de wrote:
> Hi,
> 
> I posted this on the kernel list already, but now that I'm subscribed here
> I guess this is the better place :-) Neil already reacted to my mail on
> LKML but the first proposal didn't help (order of exportfs and killall).
> 
> System is: SuSE 9.0 with 2.6.7 (tested up to 2.6.8rc3) and util-linux-2.12
> 
> Also tested with SuSE 9.1/SLES9 and SuSEs kernel 2.6.5.
> 
> When running "/etc/init.d/nfsserver restart" on the server, the clients
> will react with "stale nfs handle" for all mounted directories that were
> in use during the restart (e.g. if /var is mounted and syslogd is running,
> or if some "find" is running on a mounted directory). The stale directories
> will never come back to sane state (except restarting with sleep, see below).
> 
> When using
> /etc/init.d/nfsserver stop
> sleep 2
> /etc/init.d/nfsserver start
> 
> (or putting a "sleep 1" between the lines "$0 stop" and "$0 start" in the
> init script), everything goes fine. Restarting with sleep 2 will also
> bring back the client dirs that were staled from a former restart without
> sleep.
> 
> Without the init script, it can be traced down to:
> 
> killall -9 nfsd
> killall -9 /usr/sbin/rpc.mountd
> /usr/sbin/exportfs -au
> [sleep 2]
> /usr/sbin/exportfs -r
> /usr/sbin/rpc.nfsd
> /usr/sbin/rpc.mountd
> 
> Stales without the sleep, does not with the sleep. That behaviour is
> independent from options like v3/v4, tcp/udp, lock/nolock, and it did
> not happen with 2.4.

Probably the best solution is to "not do that" - why do you want to
stop and then restart the server anyway?  Why not just leave it
running.

However there is a race the, and "sleep 1" would fix it.
Another fix would be to use "-1" instead of "-9" to kill nfsd.  This
causes it to exit without clearing the export table.
Another fix would be to apply to following patch to your 2.6 kernel.

NeilBrown


diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2004-08-18 13:07:44.000000000 +1000
+++ ./net/sunrpc/cache.c	2004-08-18 13:12:10.000000000 +1000
@@ -400,9 +400,10 @@ void cache_flush(void)
 
 void cache_purge(struct cache_detail *detail)
 {
-	detail->flush_time = get_seconds()+1;
+	detail->flush_time = LONG_MAX;
 	detail->nextcheck = get_seconds();
 	cache_flush();
+	detail->flush_time = 1;
 }
 
 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
