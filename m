From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] fs/nfsd/nfs4state.c: make a struct static
Date: Tue, 4 Apr 2006 18:30:10 +0200
Message-ID: <20060404163010.GQ6529@stusta.de>
References: <20060404014504.564bf45a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQoQ6-000694-D3
	for nfs@lists.sourceforge.net; Tue, 04 Apr 2006 09:30:18 -0700
Received: from mailout.stusta.mhn.de ([141.84.69.5])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FQoQ4-00051R-T6
	for nfs@lists.sourceforge.net; Tue, 04 Apr 2006 09:30:18 -0700
To: Andrew Morton <akpm@osdl.org>, NeilBrown <neilb@suse.de>
In-Reply-To: <20060404014504.564bf45a.akpm@osdl.org>
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

On Tue, Apr 04, 2006 at 01:45:04AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.16-mm2:
>...
> +knfsd-locks-flag-nfsv4-owned-locks.patch
>...
>  knfsd updates.
>...

This patch makes the needlessly global struct nfsd_posix_mng_ops static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-rc1-mm1-full/fs/nfsd/nfs4state.c.old	2006-04-04 18:03:25.000000000 +0200
+++ linux-2.6.17-rc1-mm1-full/fs/nfsd/nfs4state.c	2006-04-04 18:03:38.000000000 +0200
@@ -2507,7 +2507,7 @@
 
 /* Hack!: For now, we're defining this just so we can use a pointer to it
  * as a unique cookie to identify our (NFSv4's) posix locks. */
-struct lock_manager_operations nfsd_posix_mng_ops  = {
+static struct lock_manager_operations nfsd_posix_mng_ops  = {
 };
 
 static inline void


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
