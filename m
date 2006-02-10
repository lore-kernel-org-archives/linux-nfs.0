From: Levent Serinol <lserinol@gmail.com>
Subject: [PATCH] more verbose output for rpc auth weak error
Date: Fri, 10 Feb 2006 11:50:33 +0200
Message-ID: <2c1942a70602100150q630758eqda2565831ccd7d81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, Olaf Kirch <okir@suse.de>,
	NeilBrown <neilb@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F7bMZ-0000WW-3s
	for nfs@lists.sourceforge.net; Fri, 10 Feb 2006 08:43:15 -0800
Received: from pproxy.gmail.com ([64.233.166.183])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F7bMY-0004aN-0W
	for nfs@lists.sourceforge.net; Fri, 10 Feb 2006 08:43:15 -0800
Received: by pproxy.gmail.com with SMTP id s49so237790pyc
        for <nfs@lists.sourceforge.net>; Fri, 10 Feb 2006 08:43:08 -0800 (PST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Summary: more verbose output for rpc auth weak error

This patch adds server ip address to be printed out when "server
requires stronger authentication" error occured.

Signed-off-by: Levent Serinol <lserinol@gmail.com>

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.16-rc2/net/sunrpc/clnt.c.org      2006-02-10
10:17:01.000000000 +0200
+++ linux-2.6.16-rc2/net/sunrpc/clnt.c  2006-02-10 10:23:53.000000000 +0200
@@ -1193,8 +1193,8 @@ call_verify(struct rpc_task *task)
                        task->tk_action =3D call_bind;
                        goto out_retry;
                case RPC_AUTH_TOOWEAK:
-                       printk(KERN_NOTICE "call_verify: server
requires stronger "
-                              "authentication.\n");
+                       printk(KERN_NOTICE "call_verify: server %s
requires stronger "
+                              "authentication.\n",task->tk_client->cl_serv=
er);
                        break;
                default:
                        printk(KERN_WARNING "call_verify: unknown auth
error: %x\n", n);
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D




--

Stay out of the road, if you want to grow old.
~ Pink Floyd ~.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
