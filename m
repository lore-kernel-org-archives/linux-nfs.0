From: Ralph Churchill <mrchucho@yahoo.com>
Subject: (no subject)
Date: Tue, 14 Oct 2003 12:50:23 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031014195023.43314.qmail@web11410.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9VBY-0004WQ-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 12:50:24 -0700
Received: from web11410.mail.yahoo.com ([216.136.131.221])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A9VBX-0003PL-GX
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 12:50:23 -0700
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

I am experiencing a strange problem wherein a file
placed on an exported directory accessible by multiple
clients is occassionally only visible to SOME clients.
However, if I "force" some fake activity on the shared
directory (e.g. touching, then deleting a file in an
infinite loop), then ALL clients see the file at ALL
times. This leads me to belive the problem is related
to some buffering or caching... but where?

Relevant information:

Clients
-------
RedHat 9
kernel 2.6.0-test7
mounted
'rsize=8192,wsize=8192,noatime,nodiratime,noac'

Server
------
RedHat 9
kernel 2.4.20-8
nfs-utils-1.0.1-2.9
exported "*(rw)"
dir is 'ext3' mounted with 'noatime, nodiratime'

Any and all help is appreciated.

RMC

__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
