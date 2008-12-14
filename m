From: Jonathan Andrews <jon-6sjJsz/Jqtu8qtKVGud/9w@public.gmane.org>
Subject: [NFS] nfs-utils 1.0.12 cant build
Date: Sun, 14 Dec 2008 22:56:31 +0000
Message-ID: <1229295391.2924.5.camel@jonspcb>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37989 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbYLNX7U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Dec 2008 18:59:20 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LC0rm-00078L-9i
	for linux-nfs@vger.kernel.org; Mon, 15 Dec 2008 10:59:18 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


configure:22158: gcc -o conftest -g -O2  -D_GNU_SOURCE  conftest.c -lblkid   >&5
/usr/lib/libblkid.a(probe.o)(.text+0x2b3): In function `set_uuid':
/root/src/GNU/unmodified_gnu/nfs-utils-1.0.12/e2fsprogs-1.41.3/lib/blkid/probe.c:132: undefined reference to `uuid_is_nu
ll'
/usr/lib/libblkid.a(probe.o)(.text+0x2d0):/root/src/GNU/unmodified_gnu/nfs-utils-1.0.12/e2fsprogs-1.41.3/lib/blkid/probe
.c:133: undefined reference to `uuid_unparse'
/usr/lib/libblkid.a(probe.o)(.text+0x3af): In function `get_ext2_info':
/root/src/GNU/unmodified_gnu/nfs-utils-1.0.12/e2fsprogs-1.41.3/lib/blkid/probe.c:162: undefined reference to `uuid_is_nu
ll'
collect2: ld returned 1 exit status
configure:22164: $? = 1
configure: failed program was:
| /* confdefs.h.  */


Anyone any ideas ?




------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

