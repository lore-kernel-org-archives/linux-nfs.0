From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 8 - Export news symbols in sunrpc
Date: Wed, 16 Oct 2002 16:03:15 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E181hH1-0000J2-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181hHC-0002mi-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 23:03:26 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 16 Oct 2002 16:03:17 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

The new caching and auth code needs symbols to be exported.



 ----------- Diffstat output ------------
 ./net/sunrpc/sunrpc_syms.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+)

--- ./net/sunrpc/sunrpc_syms.c	2002/10/16 04:46:08	1.1
+++ ./net/sunrpc/sunrpc_syms.c	2002/10/16 04:46:11	1.2
@@ -92,6 +92,25 @@ EXPORT_SYMBOL(svc_proc_unregister);
 EXPORT_SYMBOL(svc_proc_read);
 #endif
 
+/* caching... */
+EXPORT_SYMBOL(auth_domain_find);
+EXPORT_SYMBOL(cache_fresh);
+EXPORT_SYMBOL(unix_domain_find);
+EXPORT_SYMBOL(auth_domain_put);
+EXPORT_SYMBOL(cache_flush);
+EXPORT_SYMBOL(cache_unregister);
+EXPORT_SYMBOL(add_hex);
+EXPORT_SYMBOL(cache_check);
+EXPORT_SYMBOL(svcauth_unix_purge);
+EXPORT_SYMBOL(get_word);
+EXPORT_SYMBOL(cache_clean);
+EXPORT_SYMBOL(cache_register);
+EXPORT_SYMBOL(auth_unix_lookup);
+EXPORT_SYMBOL(auth_unix_add_addr);
+EXPORT_SYMBOL(cache_init);
+EXPORT_SYMBOL(auth_unix_forget_old);
+EXPORT_SYMBOL(add_word);
+
 /* Generic XDR */
 EXPORT_SYMBOL(xdr_encode_array);
 EXPORT_SYMBOL(xdr_encode_string);


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
