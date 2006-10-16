From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 5] knfsd: Fix bug in recent lockd patches that
	can cause reclaim to fail.
Date: Tue, 17 Oct 2006 09:30:25 +1000
Message-ID: <1061016233025.11354@suse.de>
References: <20061017092702.11224.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZbuh-00017I-Dq
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:31 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZbuh-00074V-I5
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:32 -0700
To: Andrew Morton <akpm@osdl.org>
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


When an nfs server shuts down, lockd needs to release all the locks
even though the client still holds them.

It should therefore not 'unmonitor' the clients, so that the files in
nfs/sm will still be there when the nfs server restarts, so that those
clients will be told to reclaim their locks.

However the hosts are fully unmonitored, so statd may well remove the
files.

lockd has a test for 'sm_sticky' and avoid the unmonitor call if it is
set, but it is currently not set.

So set it when tearing down lockd.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/svcsubs.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff .prev/fs/lockd/svcsubs.c ./fs/lockd/svcsubs.c
--- .prev/fs/lockd/svcsubs.c	2006-10-17 09:10:39.000000000 +1000
+++ ./fs/lockd/svcsubs.c	2006-10-17 09:10:40.000000000 +1000
@@ -324,7 +324,17 @@ nlmsvc_same_host(struct nlm_host *host, 
 static int
 nlmsvc_is_client(struct nlm_host *host, struct nlm_host *dummy)
 {
-	return host->h_server;
+	if (host->h_server)
+	{
+		/* we are destroying locks even though the client
+		 * hasn't asked us too, so don't unmonitor the
+		 * client
+		 */
+		if (host->h_nsmhandle)
+			host->h_nsmhandle->sm_sticky = 1;
+		return 1;
+	} else
+		return 0;
 }
 
 /*

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
