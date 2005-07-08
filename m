From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS: procfs/sysctl interfaces for lockd do not work on x86_64
Date: Fri, 08 Jul 2005 14:41:39 -0400
Message-ID: <42CEC8E3.8040300@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010303090907040002000109"
Cc: linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DqxnM-0007CT-B2
	for nfs@lists.sourceforge.net; Fri, 08 Jul 2005 11:41:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DqxnM-0002Lm-4g
	for nfs@lists.sourceforge.net; Fri, 08 Jul 2005 11:41:52 -0700
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

This is a multi-part message in MIME format.
--------------010303090907040002000109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is an problem that was brought to my attention and I noticed
it was not fixed in any of the upstream kernels I looked at.

steved.

--------------010303090907040002000109
Content-Type: text/x-patch;
 name="linux-2.6.12.2-lockd-sysctl.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.12.2-lockd-sysctl.patch"

A trivial patch that allows the setting of NLM timeouts and grace periods
through the proc and sysclt interfaces on x86_64 architectures

Signed-off-by: Steve Dickson <steved@redhat.com>

--- linux-2.6.12.2/fs/lockd/svc.c.orig	2005-06-29 19:00:53.000000000 -0400
+++ linux-2.6.12.2/fs/lockd/svc.c	2005-07-08 14:26:41.671010000 -0400
@@ -329,7 +329,7 @@ static ctl_table nlm_sysctls[] = {
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nlm_grace_period",
 		.data		= &nlm_grace_period,
-		.maxlen		= sizeof(int),
+		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= &proc_doulongvec_minmax,
 		.extra1		= (unsigned long *) &nlm_grace_period_min,
@@ -339,7 +339,7 @@ static ctl_table nlm_sysctls[] = {
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nlm_timeout",
 		.data		= &nlm_timeout,
-		.maxlen		= sizeof(int),
+		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= &proc_doulongvec_minmax,
 		.extra1		= (unsigned long *) &nlm_timeout_min,

--------------010303090907040002000109--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
