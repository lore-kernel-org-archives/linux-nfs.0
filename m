From: Sven Geggus <geg@iitb.fhg.de>
Subject: lockd trouble after 2.4.18 -> 2.4.19 Kernel update
Date: Thu, 31 Oct 2002 17:35:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021031163547.GA3866@sol.ers.iitb.fhg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailgw1.fraunhofer.de ([153.96.1.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187IIa-0003SF-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 08:36:00 -0800
Received: from mailgw1.fraunhofer.de (localhost [127.0.0.1])
	by mailgw1.fraunhofer.de (8.11.6/8.11.6) with ESMTP id g9VGZns28565
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 17:35:49 +0100 (MET)
Received: from kso.iitb.fhg.de (cmpm.iitb.fhg.de [153.96.8.2])
	by mailgw1.fraunhofer.de (8.11.6/8.11.6) with ESMTP id g9VGZmU28561
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 17:35:48 +0100 (MET)
Received: from iitb.fhg.de (iitb.iitb.fhg.de [153.96.12.2])
	by kso.iitb.fhg.de (8.11.1/8.11.1) with ESMTP id g9VGZm712944
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 17:35:48 +0100 (MET)
Received: from venus.ers.iitb.fhg.de (localhost [127.0.0.1])
	by iitb.fhg.de (8.11.1/8.11.1) with ESMTP id g9VGZm006773
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 17:35:48 +0100 (MET)
Received: from geg by venus.ers.iitb.fhg.de with local (Exim 3.35 #1 (Debian))
	id 187IIN-00010x-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 17:35:47 +0100
To: nfs@lists.sourceforge.net
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

Hi there,

we have a bunch of diskless Linux workstations with mount almost anything
from a central Server using NFS (v3). No NFS-root though, root-fs is lokated
insid an initial Ramdisk.

This worked fine with 2.4. Kernels up to 2.4.18.

Starting from 2.4.19 the diskless amcheines do not even boot.

All we get are messages like this:

lockd: failed to monitor <ip-of-server>

The Kernel od the Server did not change at all (2.4.17 at the time of
writing).

Any hint howto debug this?

diff of 2.4.18 and 2.4.19 Kernel sources do not show any changes in lockd.c
:(

Which other change in the Kernel Sources could cause this trouble?

TIA for hints

Sven

P.S.: both Kernels are vanilla Kernels from ftp.kernel.org

-- 
Sven Geggus @ Fraunhofer IITB, Karlsruhe (http://wsd.iitb.fhg.de/)
Phone: +49 721 6091-422, Fax: +49 721 6091-213
Linux powered DATA aquisition and evaluation, embedded systems,
combustion engine diagnosis


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
