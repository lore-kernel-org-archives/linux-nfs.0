From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: Readdirplus compatibility fix for IRIX server
Date: Thu, 11 Dec 2003 06:11:41 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FD850ED.6060907@RedHat.com>
References: <3FD7A2A1.1030109@RedHat.com> <16343.48833.339487.248965@guts.uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070608040905000300030403"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUOjh-0000kI-0B
	for nfs@lists.sourceforge.net; Thu, 11 Dec 2003 03:12:01 -0800
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AUOjg-0007H5-FV
	for nfs@lists.sourceforge.net; Thu, 11 Dec 2003 03:12:00 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <16343.48833.339487.248965@guts.uio.no>
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
--------------070608040905000300030403
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:

>Your patch is merely short-circuiting that recovery mechanism
>
Exactly.... I realized this as soon as I hit the Send button. :-(
Here is a patch that explicitly fixes the problem and only
effects READDIRPLUSs

SteveD


--------------070608040905000300030403
Content-Type: text/plain;
 name="linux-2.4.22-nfs-readdirplus-irix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.22-nfs-readdirplus-irix.patch"

--- linux-2.4.22/fs/nfs/dir.c.org	2003-12-09 14:21:59.000000000 -0500
+++ linux-2.4.22/fs/nfs/dir.c	2003-12-11 05:50:26.000000000 -0500
@@ -437,6 +437,14 @@ static int nfs_readdir(struct file *filp
 				if (res >= 0)
 					continue;
 			}
+			/*
+			 * Some IRIX servers fail READDIRPLUS RPC calls
+			 * with NFSERR_TOOSMALL when a non-existent cookie 
+			 * is requested, which is a bug. So ignore that failure.
+			 */
+			if (desc->plus && desc->error == -ETOOSMALL)
+				desc->error = 0;
+
 			res = 0;
 			break;
 		} else if (res < 0)

--------------070608040905000300030403--



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
