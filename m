From: James Bardin <jbardin@bu.edu>
Subject: autofs and krb5 in CentOS5
Date: Mon, 23 Apr 2007 13:18:03 -0400
Message-ID: <462CEA4B.6090103@bu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg2Av-0002EE-5Y
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 10:18:05 -0700
Received: from wx-out-0506.google.com ([66.249.82.224])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg2Aw-0005bx-FK
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 10:18:07 -0700
Received: by wx-out-0506.google.com with SMTP id i30so3058756wxd
	for <nfs@lists.sourceforge.net>; Mon, 23 Apr 2007 10:18:05 -0700 (PDT)
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

Hello,

I'm testing out my lab setup with CentOS5
When using autofs to mount sec=krb5 (nfs3) home directories, I get these 
errors when a user logs in through gdm:

kernel: net/sunrpc/rpc_pipe.c: rpc_lookup_parent failed to find path 
/nfs/clnt3e/krb5
kernel: net/sunrpc/rpc_pipe.c: rpc_lookup_parent failed to find path 
/nfs/clnt3f/krb5
kernel: net/sunrpc/rpc_pipe.c: rpc_lookup_parent failed to find path 
/nfs/clnt40/krb5

These continue until the user logs out.
This is only when logging in through gdm and the home directory is 
mounted through autofs.
I have gdm logging debug messages, but nothing looks relevant there. 
rpc.gssd isn't giving me anything useful either.

kernel 2.6.18-8.1.1.el5
nfs-utils-1.0.9-16.el5

I'm not sure what to test next.

thanks
-jim


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
