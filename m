From: Dan Yocum <yocum@fnal.gov>
Subject: Null characters in files on NFS mounted volume....
Date: Mon, 13 May 2002 09:33:03 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CDFCE9F.2BE050D5@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from heffalump.fnal.gov ([131.225.9.20] helo=fnal.gov)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Gsq-0001j7-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 07:33:04 -0700
Received: from fnal.gov ([131.225.7.82]) by smtp.fnal.gov (PMDF V6.0-24 #37519)
 with ESMTP id <0GW200LJL0F3EO@smtp.fnal.gov> for nfs@lists.sourceforge.net;
 Mon, 13 May 2002 09:33:03 -0500 (CDT)
To: nfs list <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi all,

I've got a "New and Exciting" <tm> bug using 2.4.18 with Trond's client
patches (sans the rpc_tweaks dif), but I'm not sure it's a client side
problem.

This is an intermitent problem:  When attempting to read a file (any file)
on an NFS mounted volume, there appear to be "holes" in the file filled with
ASCII NULL characters.  Reading the file on the local machines shows no such
holes, and other NFS clients don't see the holes, either.  A simple
umount/remount solves the problem.

Oh, I should add that these are autofs mounted volumes.

We thought these might be network driver problems, but we're seeing it on
natsemi, acenic and eepro100 drivers, and I doubt they could all be flaky.

Any ideas?

Thanks,
Dan


-- 
Dan Yocum
Sloan Digital Sky Survey, Fermilab  630.840.6509
yocum@fnal.gov, http://www.sdss.org
SDSS.  Mapping the Universe.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
