From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
 kernel
Date: Wed, 12 Jan 2005 14:11:59 -0500
Message-ID: <41E5767F.40204@RedHat.com>
References: <41DD8403.7030601@RedHat.com>	 <1105118040.10979.70.camel@lade.trondhjem.org>	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>	 <41E43DE1.5080703@RedHat.com>	 <1105480745.11430.56.camel@lade.trondhjem.org>  <41E569E3.20206@RedHat.com> <1105554342.23943.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ConuV-0004UI-Mb
	for nfs@lists.sourceforge.net; Wed, 12 Jan 2005 11:12:03 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1ConuV-0002Bb-8d
	for nfs@lists.sourceforge.net; Wed, 12 Jan 2005 11:12:03 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1105554342.23943.1.camel@lade.trondhjem.org>
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



Trond Myklebust wrote:

>===================================================================
>--- linux-2.4.28-rc1.orig/net/sunrpc/clnt.c
>+++ linux-2.4.28-rc1/net/sunrpc/clnt.c
>@@ -209,7 +209,7 @@ void rpc_clnt_sigmask(struct rpc_clnt *c
> 	unsigned long	irqflags;
> 	
> 	/* Turn off various signals */
>-	if (clnt->cl_intr) {
>+	if (clnt->cl_intr && !(current->flags & PF_DUMPCORE)) {
> 		struct k_sigaction *action = current->sig->action;
> 		if (action[SIGINT-1].sa.sa_handler == SIG_DFL)
> 			sigallow |= sigmask(SIGINT);
>  
>
Well did you try  just this? ;-)

Here is what I found.... just adding the PF_DUMPCORE rpc_clnt_sigmask() 
no core was dropped
because __rpc_execute returned -ERESTARTSYS due to signalled() == TRUE.

When I added back the  PF_DUMPCORE check to __rpc_execute(), only the 
header of the core
was dropped  because nfs_wait_event() returned -ERESTARTSYS because 
signalled() == TRUE.

When I added back the PF_DUMPCORE to nfs_wait_event(), the entire core 
was dropped.

So it appears to me that you need both checks.....

steved



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
