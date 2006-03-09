From: Bas van der Vlies <basv@sara.nl>
Subject: Re: NFSD/gfs crashes with oops
Date: Thu, 09 Mar 2006 08:39:23 +0100
Message-ID: <440FDBAB.3000603@sara.nl>
References: <5F4E2391-4553-4A5A-8A92-1033CE717267@sara.nl>	 <440EE57B.2090804@sara.nl> <1141830321.8214.21.camel@lade.trondhjem.org>	 <440EF6E4.4080109@sara.nl> <1141832193.8214.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHFkD-00054D-OY
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 23:39:33 -0800
Received: from surfboard.ka.sara.nl ([145.100.6.3])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FHFkD-0002AD-H1
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 23:39:33 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1141832193.8214.27.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

Just for the recorde. The GFS guys have made a patch for the crash in 
CVS stable:

CVSROOT:	/cvs/cluster
Module name:	cluster
Branch: 	STABLE
Changes by:	bmarzins@sourceware.org	2006-03-08 20:47:09

Modified files:
	gfs-kernel/src/gfs: ops_inode.c

Log message:
  Really gross hack!!!
  This is a workaround for one of the bugs the got lumped into 166701. It
  breaks POSIX behavior in a corner case to avoid crashing... It's icky.
  when NFS opens a file with O_CREAT, the kernel nfs daemon checks to see
  if the file exists. If it does, nfsd does the *right thing* (either
  opens the file, or if the file was opened with O_EXCL, returns an
  error).  If the file doesn't exist, it passes the request down to the
  underlying file system. Unfortunately, since nfs *knows* that the file
  doesn't exist, it doesn't  bother to pass a nameidata structure, which
  would include the intent information. However since gfs is a cluster
  file system, the file could have been created on another node after nfs
  checks for it. If this is the case, gfs needs the intent information to
  do the *right thing*.  It panics when it finds a NULL pointer, instead
  of the nameidata. Now, instead of panicing, if gfs finds a NULL
  nameidata pointer. It assumes that the file was not created with _EXCL.

  This assumption could be wrong, with the result that an application
  could thing that it has created a new file, when in fact, it has opened
  an existing one.

-- 
--
********************************************************************
*                                                                  *
*  Bas van der Vlies                     e-mail: basv@sara.nl      *
*  SARA - Academic Computing Services    phone:  +31 20 592 8012   *
*  Kruislaan 415                         fax:    +31 20 6683167    *
*  1098 SJ Amsterdam                                               *
*                                                                  *
********************************************************************


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
