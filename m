From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: [PATCH] SGI 905314 (1/2): make NFSSVC_MAXBLKSIZE depend on
 PAGE_SIZE
Date: Mon, 01 Dec 2003 10:26:00 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FCA7C88.E4C9E528@melbourne.sgi.com>
References: <3FC742E7.910F518B@melbourne.sgi.com> <16330.28333.153593.711963@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AQaxK-00019n-00
	for <nfs@lists.sourceforge.net>; Sun, 30 Nov 2003 15:26:22 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AQaxK-0005yn-DM
	for nfs@lists.sourceforge.net; Sun, 30 Nov 2003 15:26:22 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Neil Brown wrote:
> 
> What you you think of simply:
> 
>    #define NFSSVC_MAXBLKSIZE (PAGE_SIZE * 2)
> 

It's not that simple; the ia64 port can be configured for 64K pages,
which would result in nfsd reporting 128K for wtmax on UDP.

Here's a patch which is closer to that simple ideal ;-)

--- /usr/tmp/TmpDir.26244-0/linux/linux/include/linux/nfsd/const.h_1.5	Mon Dec  1
10:24:10 2003
+++ linux/include/linux/nfsd/const.h	Mon Dec  1 10:24:11 2003
@@ -12,6 +12,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
 #include <linux/nfs3.h>
+#include <asm/page.h>
 
 /*
  * Maximum protocol version supported by knfsd
@@ -19,9 +20,16 @@
 #define NFSSVC_MAXVERS		3
 
 /*
- * Maximum blocksize supported by daemon currently at 8K
+ * Maximum blocksize supported by daemon.  We want the largest
+ * value which 1) fits in a UDP datagram less some headers
+ * 2) is a multiple of page size 3) can be successfully kmalloc()ed
+ * by each nfsd.   
  */
-#define NFSSVC_MAXBLKSIZE	(8*1024)
+#if PAGE_SIZE > (16*1024)
+#define NFSSVC_MAXBLKSIZE	(32*1024)
+#else
+#define NFSSVC_MAXBLKSIZE	(2*PAGE_SIZE)
+#endif
 
 #ifdef __KERNEL__
 


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
