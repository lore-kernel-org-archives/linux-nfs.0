From: Olaf Kirch <okir@suse.de>
Subject: nfsd random drop
Date: Thu, 1 Apr 2004 12:23:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040401102334.GC20772@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8zMI-0001Ky-0Y
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 02:23:38 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B8zMH-0006ne-5q
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 02:23:37 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi,

I hate to bore you all with the same old stuff, but I'm still fighting
problems caused by nfsd's dropping active connections.

The most recent episode in this saga is a problem with the Linux
client.

Consider a network with a single Linux 2.4 based home server, a few
hundred clients, all using TCP. In Linux 2.4, nfsd starts dropping
connections when it reaches a limit of (nrthreads + 3) * 10 open
connections. With 4 threads, this means 70 connections, and with 8 threads
this means 110 connections max. Both of which is totally inadequate for
this network. To get out of the congestion zone, we would need to bump
the number of threads to about 20, which is just silly.

The very same network has been served well with just 4 threads all
the time while using UDP.

With the 2.6 kernel, things get even worse as the formula was changed to
(nrthreads + 3) * 5, so you'll max out at 35 (4 threads) and 55 (with
8 threads), respectively. To serve 200 mounts via TCP simultaneously,
you'd need close to 40 nfsd threads.

In theory, all clients should be able to cope gracefully with such drops,
but even the Linux client runs into a couple of SNAFUs with these.

One: with a 50% probability, nfsd decides to drop the _newest_ connection,
which is the one it just accepted.  When the Linux client sees a fresh
connection go down before it was able to send anything across, it
backs off for 15 to 60 seconds, hanging the NFS mount (with 2.6.5-pre,
it's always 60 seconds). Which is kind of annoying the KDE users here,
because KDE applications like to scribble to the home directory all
the time, and their entire session freezes when NFS hangs.

Second: People have reported that files vanished and/or rename/remove
operations failed.

I also think this is due to the TCP disconnects. What I think
is happening here is this:

 -      user X: unlink("blafoo") 
 -      kernel: sends NFS call to server REMOVE "blafoo" 
 -      nfsd thread A receives request, removes file blafoo. waits for 
	some file system i/o to sync the change to disk 
 -      a new tcp connection comes in. Another nfsd thread B decides 
	it needs to nuke some connections, selects user X's connection 
 -      nfsd thread A decides it should send the response now,
	but finds the socket is gone. Drops the reply.
 -      client kernel: reconnect to NFS server
 -	server drops connection
 -	client waits for a while, reconnects again,
	resends REMOVE "blafoo" 
 -      NFS server: sorry, ENOENT: there's no such file "blafoo" 

Normally, the NFS server's replay cache should protect from this sort
of behavior, but the long timeouts before the client can reconnect
effectively mean the cached reply has been forgotten by the time the
retransmitted call arrives.

This is not a theoretical case; users here have reported that
files vanish mysteriously several times a day.

Three: people reported lots of messages in their syslog saying
"nfs_rename: target foo/bar busy, d_count=2". This is a variation
of the above. nfs_rename finds that someone still has foo/bar
open and decides it needs to do a sillyrename. The rename
fails with the spurious ENOENT error described above, causing
the entire rename operation to fail

Four: Some buggy clients can't deal with it, but I think I mentioned
that already.  Prime offender is zOS; when a fresh connection is killed,
it simply propagates the error to the application, hard mount or not. I
know it's broken, but that doesn't mean we can't be gentler and make
these clients work more smoothly with Linux.

I propose to add the following two patches to the server and client. They
increase the connection limit, stop dropping the neweset socket, and
add some printk's to alert the admin of the contention.

As an alternative to hardcoding a formula based on the number of threads,
I could also make the max number of connections a sysctl.

Comments,
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=sunrpc-svcsock-drop

diff -ur linux-2.6.4-nfsd/net/sunrpc/svcsock.c linux-2.6.4/net/sunrpc/svcsock.c
--- linux-2.6.4-nfsd/net/sunrpc/svcsock.c	2004-03-11 03:55:22.000000000 +0100
+++ linux-2.6.4/net/sunrpc/svcsock.c	2004-03-30 16:58:01.000000000 +0200
@@ -828,21 +828,33 @@
 
 	/* make sure that we don't have too many active connections.
 	 * If we have, something must be dropped.
-	 * We randomly choose between newest and oldest (in terms
-	 * of recent activity) and drop it.
+	 *
+	 * There's no point in trying to do random drop here for
+	 * DoS prevention. The NFS clients does 1 reconnect in 15
+	 * seconds. An attacker can easily beat that.
+	 *
+	 * The only somewhat efficient mechanism would be to drop
+	 * old connections from the same IP first. But right now
+	 * we don't even record the client IP in svc_sock.
 	 */
-	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*5) {
+	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
 		struct svc_sock *svsk = NULL;
 		spin_lock_bh(&serv->sv_lock);
 		if (!list_empty(&serv->sv_tempsocks)) {
-			if (net_random()&1)
-				svsk = list_entry(serv->sv_tempsocks.prev,
-						  struct svc_sock,
-						  sk_list);
-			else
-				svsk = list_entry(serv->sv_tempsocks.next,
-						  struct svc_sock,
-						  sk_list);
+			if (net_ratelimit()) {
+				/* Try to help the admin */
+				printk(KERN_NOTICE "%s: too many open TCP sockets, consider "
+						   "increasing the number of threads\n",
+						   serv->sv_name);
+				printk(KERN_NOTICE "%s: last TCP connect from %u.%u.%u.%u:%d\n",
+							serv->sv_name, 
+							NIPQUAD(sin.sin_addr.s_addr),
+							ntohs(sin.sin_port));
+			}
+			/* Always select the oldest socket. It's not fair, but so is life */
+			svsk = list_entry(serv->sv_tempsocks.prev,
+					  struct svc_sock,
+					  sk_list);
 			set_bit(SK_CLOSE, &svsk->sk_flags);
 			svsk->sk_inuse ++;
 		}

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=sunrpc-verbose-disconnect

--- linux-2.6.4/net/sunrpc/xprt.c.reconnect	2004-03-30 14:19:45.000000000 +0200
+++ linux-2.6.4/net/sunrpc/xprt.c	2004-03-30 15:42:04.000000000 +0200
@@ -1039,6 +1039,11 @@
 	case TCP_SYN_RECV:
 		break;
 	default:
+		if (net_ratelimit()) {
+			printk(KERN_NOTICE "NFS server %u.%u.%u.%u %s connection\n",
+					NIPQUAD(xprt->addr.sin_addr.s_addr),
+					xprt_connected(xprt)? "closed" : "refused");
+		}
 		xprt_disconnect(xprt);
 		break;
 	}

--PEIAKu/WMn1b1Hv9--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
