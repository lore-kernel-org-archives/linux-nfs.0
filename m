From: Juan Gomez <juang@us.ibm.com>
Subject: lockd trouble after 2.4.18 -> 2.4.19 Kernel update
Date: Thu, 31 Oct 2002 09:39:03 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF59C09007.A927B087-ON87256C63.0060ACEF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e1.ny.us.ibm.com ([32.97.182.101])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 187JHy-0007vx-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 09:39:28 -0800
To: geg@iitb.fhg.de
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





Sven,

This may be related to one email I previously sent to this list. I think
the piece that may be broken is the version of statd you are using. Red-hat
came out with a patch to drop su priviledges of statd which is broken and
even the fix they recently got for it is also broken. My advice is go get
statd from the nfs-utils @ source forge and replace that at client server
and that should do it.


Regards, Juan



Message: 8
Date: Thu, 31 Oct 2002 17:35:47 +0100
From: Sven Geggus <geg@iitb.fhg.de>
To: nfs@lists.sourceforge.net
Subject: [NFS] lockd trouble after 2.4.18 -> 2.4.19 Kernel update

Hi there,

we have a bunch of diskless Linux workstations with mount almost anything
from a central Server using NFS (v3). No NFS-root though, root-fs is
lokated
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



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
