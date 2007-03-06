From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: mountd memory leaks in 1.0.12
Date: Tue, 6 Mar 2007 15:59:07 +0100
Message-ID: <20070306145907.GA31463@uio.no>
References: <20070306125230.GA30735@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOb8v-00069U-5f
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 06:59:57 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOb8v-00085a-0J
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 06:59:59 -0800
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1HOb8Z-0001H0-FY
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 15:59:35 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1HOb87-0008CL-00
	for <nfs@lists.sourceforge.net>; Tue, 06 Mar 2007 15:59:07 +0100
In-Reply-To: <20070306125230.GA30735@uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, Mar 06, 2007 at 01:52:30PM +0100, Steinar H. Gunderson wrote:
> Over time, this amounts to gigabytes of RAM on a busy server. Either the
> blkid library is generally really leaky (in which case we probably shouldn't
> be using it until it's fixed), or we're using it wrong somehow. :-)

I found the leaks in libblkid (see the separate e-mail I sent). This patch
fixes a minor leak in mountd itself, and with the patch applied and a fixed
libblkid, it appears that mountd is no longer leaking memory.

--- nfs-utils-1.0.12.orig/support/export/client.c       2007-03-06 15:51:39.000000000 +0100
+++ nfs-utils-1.0.12/support/export/client.c    2007-03-06 15:51:53.000000000 +0100
@@ -329,6 +329,7 @@
                strcat(new, ",");
                strcat(new, cp);
        }
+       free(old);
        return new;
 }

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
