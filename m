From: Steve Dickson <SteveD@redhat.com>
Subject: Re: oops in rpc_pipe_release
Date: Tue, 08 Nov 2005 13:58:53 -0500
Message-ID: <4370F56D.6090606@RedHat.com>
References: <436FEB9B.3010007@google.com> <4370B4E0.6090306@RedHat.com> <4370F072.3090104@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080508000604080102040704"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZYgM-0002Tp-6y
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 10:58:58 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EZYgL-0003mI-3b
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 10:58:58 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <4370F072.3090104@google.com>
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

This is a multi-part message in MIME format.
--------------080508000604080102040704
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



Vince Busam wrote:
> I tried that with and without the linux-2.6.13-CITI_NFS4_ALL-1.dif 
> patch, and either way it ends up causing another NULL pointer 
> dereference in __rpc_purge_upcall after an hour or two.
See if the attached patch helps... It makes gss_pipe_release()
handles the fact that given pointer that are passed in
could be NULL. This seem to fix the problem I was seeing...

Trond, Is this something that's a bit more palatable? :)

steved.

--------------080508000604080102040704
Content-Type: text/x-patch;
 name="linux-2.6.14-rpc-gss-oops.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.14-rpc-gss-oops.patch"

--- linux-2.6.9/net/sunrpc/auth_gss/auth_gss.c.orig	2005-11-07 11:05:52.800401000 -0500
+++ linux-2.6.9/net/sunrpc/auth_gss/auth_gss.c	2005-11-08 13:16:05.576222000 -0500
@@ -513,7 +513,10 @@ gss_pipe_release(struct inode *inode)
 	struct rpc_auth *auth;
 	struct gss_auth *gss_auth;
 
-	clnt = rpci->private;
+	clnt = ((rpci != NULL) ? ((struct rpc_clnt *)rpci->private) : NULL);
+	if (clnt == NULL || clnt->cl_auth == NULL)
+		return;
+
 	auth = clnt->cl_auth;
 	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
 	spin_lock(&gss_auth->lock);

--------------080508000604080102040704--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
