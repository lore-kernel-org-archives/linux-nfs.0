From: Stephen Hemminger <shemminger@osdl.org>
Subject: [NFS] [PATCH] missing export of hash_mem (2.5.55)
Date: 09 Jan 2003 13:09:28 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1042146568.4870.57.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linus Torvalds <torvalds@transmeta.com>
List-ID: <nfs.lists.sourceforge.net>

Can't build nfs server as a module because of missing export of hash_mem


diff -Nru a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
--- a/net/sunrpc/sunrpc_syms.c	Thu Jan  9 13:07:34 2003
+++ b/net/sunrpc/sunrpc_syms.c	Thu Jan  9 13:07:34 2003
@@ -104,6 +104,7 @@
 EXPORT_SYMBOL(qword_get);
 EXPORT_SYMBOL(svcauth_unix_purge);
 EXPORT_SYMBOL(unix_domain_find);
+EXPORT_SYMBOL(hash_mem);
 
 /* Generic XDR */
 EXPORT_SYMBOL(xdr_encode_array);
