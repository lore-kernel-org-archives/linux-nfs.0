From: "Adam J. Richter" <adam@yggdrasil.com>
Subject: Patch?: linux-2.5.42/net/sunrpc/sunrpc_syms.c - symbols needed by new nfsd
Date: Sun, 13 Oct 2002 11:24:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021013112452.A286@baldur.yggdrasil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ikeVEW9yuYc//A+q"
Cc: linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from h-64-105-34-19.snvacaid.covad.net ([64.105.34.19] helo=freya.yggdrasil.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 180nob-0000nf-00
	for <nfs@lists.sourceforge.net>; Sun, 13 Oct 2002 11:50:13 -0700
To: okir@monad.swb.de, neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

	nfsd in 2.5.42 needs a bunch of symbols that the sunrpc module
does not export.  This patch adds them to net/sunrpc/sunrpc_syms.c.
I am now running the nfsd and sunrpc modules based on this patch.

	I suspect that some of symbol exports in this patch may need
to be bracketed in some kind of #ifdef CONFIG_foo....#endif conditionals.

	Also, I know that having a central exports file like
sunrpc_syms.c impedes efforts to split the module if it turns out
that some users of it only need certain functions, but I thought I
ought to keep this patch as small as possible.  I would be happy to
make a patch to move the EXPORT_SYMBOL declarations in sunrpc_syms.c
to the files that actually define them if there is interest.

-- 
Adam J. Richter     __     ______________   575 Oroville Road
adam@yggdrasil.com     \ /                  Milpitas, California 95035
+1 408 309-6081         | g g d r a s i l   United States of America
                         "Free Software For The Rest Of Us."

--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sunrpc.diff"

--- linux-2.5.42/net/sunrpc/sunrpc_syms.c	2002-10-11 21:22:18.000000000 -0700
+++ linux/net/sunrpc/sunrpc_syms.c	2002-10-13 11:15:13.000000000 -0700
@@ -111,6 +111,24 @@
 EXPORT_SYMBOL(nlm_debug);
 #endif
 
+EXPORT_SYMBOL(add_hex);
+EXPORT_SYMBOL(add_word);
+EXPORT_SYMBOL(auth_domain_find);
+EXPORT_SYMBOL(auth_domain_put);
+EXPORT_SYMBOL(auth_unix_add_addr);
+EXPORT_SYMBOL(auth_unix_forget_old);
+EXPORT_SYMBOL(auth_unix_lookup);
+EXPORT_SYMBOL(cache_check);
+EXPORT_SYMBOL(cache_clean);
+EXPORT_SYMBOL(cache_flush);
+EXPORT_SYMBOL(cache_fresh);
+EXPORT_SYMBOL(cache_init);
+EXPORT_SYMBOL(cache_register);
+EXPORT_SYMBOL(cache_unregister);
+EXPORT_SYMBOL(get_word);
+EXPORT_SYMBOL(svcauth_unix_purge);
+EXPORT_SYMBOL(unix_domain_find);
+
 static int __init
 init_sunrpc(void)
 {

--ikeVEW9yuYc//A+q--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
