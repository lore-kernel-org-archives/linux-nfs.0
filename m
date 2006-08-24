From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 11] knfsd: call lockd_down when closing a
	socket via a write to nfsd/portlist
Date: Thu, 24 Aug 2006 16:36:45 +1000
Message-ID: <1060824063645.4937@suse.de>
References: <20060824162917.3600.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GG8pY-0002za-CV
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:44 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GG8pY-0007ZF-G9
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 23:36:45 -0700
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


The refcount that nfsd holds on lockd is based on the number
of open sockets.
So when we close a socket, we should decrement the ref (with lockd_down).

Currently when a socket is closed via writing to the portlist
file, that doesn't happen.

So: make sure we get an error return if the socket that was requested
does is not found, and call lockd_down if it was.

Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c     |    2 ++
 ./net/sunrpc/svcsock.c |    2 ++
 2 files changed, 4 insertions(+)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2006-08-24 16:24:21.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2006-08-24 16:24:21.000000000 +1000
@@ -545,6 +545,8 @@ static ssize_t write_ports(struct file *
 		if (nfsd_serv)
 			len = svc_sock_names(buf, nfsd_serv, toclose);
 		unlock_kernel();
+		if (len >= 0)
+			lockd_down();
 		kfree(toclose);
 		return len;
 	}

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-08-24 16:23:37.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-08-24 16:24:21.000000000 +1000
@@ -493,6 +493,8 @@ svc_sock_names(char *buf, struct svc_ser
 	spin_unlock(&serv->sv_lock);
 	if (closesk)
 		svc_delete_socket(closesk);
+	else if (toclose)
+		return -ENOENT;
 	return len;
 }
 EXPORT_SYMBOL(svc_sock_names);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
