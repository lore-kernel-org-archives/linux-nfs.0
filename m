From: Steve Dickson <steved@4Dicksons.org>
Subject: nfs-utils-1.0.5 is not backwards compatible with 2.4
Date: Thu, 31 Jul 2003 12:05:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F293E33.1090708@4Dicksons.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iFvR-0000Ho-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 09:05:09 -0700
To: "Neil F. Brown" <neilb@cse.unsw.edu.au>
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

Hey Neil,

It seems in nfs-utils-1.05 (actually it happen in 1.0.4)
the NFSEXP_CROSSMNT define was changed to 0x4000 and the
NFSEXP_NOHIDE define (which is not supported in 2.4) took
over the 0x0200 bit.. This breaks backwards compatibly with
1.0.3 and the 2.4 kernels...

So could please add this patch that simply switchs the bits
so NFSEXP_CROSSMNT stays the same and the new NFSEXP_NOHIDE define
gets the higher bit?

--- support/include/nfs/export.h.diff   Mon Jul 14 18:14:01 2003
+++ support/include/nfs/export.h        Thu Jul 31 11:58:05 2003
@@ -20,11 +20,11 @@
 #define NFSEXP_UIDMAP          0x0040
 #define NFSEXP_KERBEROS                0x0080          /* not available */
 #define NFSEXP_SUNSECURE       0x0100
-#define NFSEXP_NOHIDE          0x0200
+#define NFSEXP_CROSSMNT                0x0200
 #define NFSEXP_NOSUBTREECHECK  0x0400
 #define NFSEXP_NOAUTHNLM       0x0800
 #define NFSEXP_FSID            0x2000
-#define        NFSEXP_CROSSMNT         0x4000
+#define        NFSEXP_NOHIDE           0x4000
 #define NFSEXP_NOACL           0x8000 /* reserved for possible ACL 
related use */
 #define NFSEXP_ALLFLAGS                0xFFFF


SteveD.




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
