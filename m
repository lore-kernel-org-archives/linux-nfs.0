From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
	kernel
Date: Wed, 12 Jan 2005 13:25:42 -0500
Message-ID: <1105554342.23943.1.camel@lade.trondhjem.org>
References: <41DD8403.7030601@RedHat.com>
	 <1105118040.10979.70.camel@lade.trondhjem.org>
	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>
	 <41E43DE1.5080703@RedHat.com>
	 <1105480745.11430.56.camel@lade.trondhjem.org>  <41E569E3.20206@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-EC558xtkbm5neit0E0Md"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ConBu-0001xl-9p
	for nfs@lists.sourceforge.net; Wed, 12 Jan 2005 10:25:58 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1ConBs-0005Qu-Ky
	for nfs@lists.sourceforge.net; Wed, 12 Jan 2005 10:25:58 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41E569E3.20206@RedHat.com>
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


--=-EC558xtkbm5neit0E0Md
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

on den 12.01.2005 Klokka 13:18 (-0500) skreiv Steve Dickson:

> >You should, however, mask off all other signals, including SIGINT and
> >SIGQUIT. The latter two (+ sigkill) are the only ones that
> >rpc_clnt_sigmask() does not currently mask out when "intr" is set.
> >  
> >
> Good point... that attached patch does just that....

I meant something more like the following.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-EC558xtkbm5neit0E0Md
Content-Disposition: inline; filename=fix_coredump.dif
Content-Type: text/plain; name=fix_coredump.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

 fs/exec.c         |    1 +
 net/sunrpc/clnt.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.4.28-rc1/fs/exec.c
===================================================================
--- linux-2.4.28-rc1.orig/fs/exec.c
+++ linux-2.4.28-rc1/fs/exec.c
@@ -1125,6 +1125,7 @@ int do_coredump(long signr, struct pt_re
 	if (current->rlim[RLIMIT_CORE].rlim_cur < binfmt->min_coredump)
 		goto fail;
 
+	current->flags |= PF_DUMPCORE;
  	format_corename(corename, core_pattern, signr);
 	file = filp_open(corename, O_CREAT | 2 | O_NOFOLLOW, 0600);
 	if (IS_ERR(file))
Index: linux-2.4.28-rc1/net/sunrpc/clnt.c
===================================================================
--- linux-2.4.28-rc1.orig/net/sunrpc/clnt.c
+++ linux-2.4.28-rc1/net/sunrpc/clnt.c
@@ -209,7 +209,7 @@ void rpc_clnt_sigmask(struct rpc_clnt *c
 	unsigned long	irqflags;
 	
 	/* Turn off various signals */
-	if (clnt->cl_intr) {
+	if (clnt->cl_intr && !(current->flags & PF_DUMPCORE)) {
 		struct k_sigaction *action = current->sig->action;
 		if (action[SIGINT-1].sa.sa_handler == SIG_DFL)
 			sigallow |= sigmask(SIGINT);

--=-EC558xtkbm5neit0E0Md--



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
