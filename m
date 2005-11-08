From: Steve Dickson <SteveD@redhat.com>
Subject: Re: oops in rpc_pipe_release
Date: Tue, 08 Nov 2005 09:23:28 -0500
Message-ID: <4370B4E0.6090306@RedHat.com>
References: <436FEB9B.3010007@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZUNw-0007Kg-Fh
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 06:23:40 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EZUNu-0006d6-4S
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 06:23:40 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <436FEB9B.3010007@google.com>
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



Vince Busam wrote:
> I'm using NFS3 with kerberos authentication, and 25 hour tickets that 
> refresh when
> unlocking the screensaver.  Over the weekend, it'll hang with one of the 
> following stack
> traces.  Any ideas what could cause this?
I believe this is caused by the fact gss_pipe_release()
(i.e. rpci->ops->release_pipe(inode)) is being called
with a freed clnt->cl_auth pointer. I proposed the
following patch a while back that I thought fixed the
problem, but Trond said the patch "prevents anyone from
reopening the pipe after the first close(), so if gssd
needs to be restarted, then all pipes will forever block."
So the patch got reverted....


--- linux-2.6.13/net/sunrpc/rpc_pipe.c.orig	2005-08-28 
19:41:01.000000000 -0400
+++ linux-2.6.13/net/sunrpc/rpc_pipe.c	2005-09-16 11:18:53.598157000 -0400
@@ -177,6 +177,8 @@ rpc_pipe_release(struct inode *inode, st
  		__rpc_purge_upcall(inode, -EPIPE);
  	if (rpci->ops->release_pipe)
  		rpci->ops->release_pipe(inode);
+	if (!rpci->nreaders && !rpci->nwriters)
+		rpci->ops = NULL;
  out:
  	up(&inode->i_sem);
  	return 0;

I think the main problem here is there is no way of telling
if a rpc_inode is or is not valid (or active) so there
is no way of knowing whether or not a release call is needed...

steved.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
