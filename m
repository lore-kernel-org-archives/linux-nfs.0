From: Ian Thurlbeck <ian@stams.strath.ac.uk>
Subject: Re: Strange delays on NFS server
Date: Tue, 24 Aug 2004 10:48:14 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412B0EDE.5010206@stams.strath.ac.uk>
References: <411A17F2.2060203@RedHat.com> <411A448D.3080205@stams.strath.ac.uk> <20040811164135.GA11101@suse.de> <411B8987.1030609@stams.strath.ac.uk> <411CD601.1080308@RedHat.com> <4120AB46.1080606@stams.strath.ac.uk> <20040816131434.GL3510@suse.de> <4120C8D5.3040606@stams.strath.ac.uk> <20040816145435.GQ3510@suse.de> <4124CD95.7020007@stams.strath.ac.uk> <20040820095854.GC23176@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzXun-0005bY-5P
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 02:48:29 -0700
Received: from vif-img1.cc.strath.ac.uk ([130.159.248.61] helo=khafre.cc.strath.ac.uk)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BzXul-0007q4-Es
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 02:48:28 -0700
Received: from dunnet.stams.strath.ac.uk ([130.159.240.95]:41467)
	by khafre.cc.strath.ac.uk with smtp (Exim 4.20 #1)
	id 1BzXuZ-00046n-0L
	for <nfs@lists.sourceforge.net>; Tue, 24 Aug 2004 10:48:15 +0100
To: Olaf Kirch <okir@suse.de>,  nfs@lists.sourceforge.net
In-Reply-To: <20040820095854.GC23176@suse.de>
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


Dear Olaf, NFS list

Olaf sent me a patch to test:

--- fs/nfsd/vfs.c.orig  2003-06-13 16:51:37.000000000 +0200
+++ fs/nfsd/vfs.c       2004-08-16 16:52:53.000000000 +0200
@@ -760,6 +760,21 @@
                 }
                 last_ino = inode->i_ino;
                 last_dev = inode->i_dev;
+       } else if (err >= 0 && !stable) {
+               /* If we've been writing several pages, schedule them
+                * for the disk immediately. The client may be streaming
+                * and we don't want to hang on a huge journal sync when the
+                * commit comes in
+                */
+               struct address_space    *mapping;
+
+               /* This assumes a minimum page size of 1K, and will issue
+                * a filemap_flushfast call every 64 pages written by the
+                * client. */
+               if ((cnt & 4095) == 0
+                && ((offset >> 12) & 63) == 0
+                && (mapping = inode->i_mapping) != NULL)
+                       filemap_fdatasync(mapping);
         }

         dprintk("nfsd: write complete err=%d\n", err);



I have tested the patched kernel - it is no different. In fact
I'd say it's slightly worse.  I've been running "atop" to monitor
net/disk io and during an "event" I see that the main 3ware raid
array is writing at 100% (60MB/sec+) for up to 50 seconds.  There
is little network traffic. During this period client machines are
unusable if they are requesting stuff off the server.

What on earth could be writing up to 3GB of data to the drive ?
As before the usual suspects of kjournald, kupdated, bdflush and
nfsd turn up on the process list.

Just how big is the nfs write cache on a typical server ? Is it
writing the whole lot one go ?

Thanks for your efforts

Ian
-- 
Ian Thurlbeck                http://www.stams.strath.ac.uk/
Statistics and Modelling Science, University of Strathclyde
Livingstone Tower, 26 Richmond Street, Glasgow, UK,  G1 1XH
Tel: +44 (0)141 548 3667           Fax: +44 (0)141 552 2079



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
