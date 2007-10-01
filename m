From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 35/35] knfsd: Support adding transports by writing portlist
	file
Date: Mon, 01 Oct 2007 14:28:48 -0500
Message-ID: <20071001192847.3250.33505.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQwi-0005g8-Ri
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:48 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQwn-0007bm-BL
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:54 -0700
In-Reply-To: <20071001191426.3250.15371.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Update the write handler for the portlist file to allow creating new
listening endpoints on a transport. The general form of the string is:

<transport_name><space><port number>

For example:

tcp 2049

This is intended to support the creation of a listening endpoint for
RDMA transports without adding #ifdef code to the nfssvc.c file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfsctl.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index baac89d..923b817 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -554,6 +554,22 @@ static ssize_t write_ports(struct file *
 		kfree(toclose);
 		return len;
 	}
+	/*
+	 * Add a transport listener by writing it's transport name
+	 */
+	if (isalnum(buf[0])) {
+		int err;
+		char transport[16];
+		int port;
+		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
+			err = nfsd_create_serv();
+			if (!err)
+				err = svc_create_xprt(nfsd_serv,
+						      transport, port,
+						      SVC_SOCK_ANONYMOUS);
+			return err < 0 ? err : 0;
+		}
+	}
 	return -EINVAL;
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
