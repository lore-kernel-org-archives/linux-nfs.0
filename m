From: "Ryurick M. Hristev" <r.hristev@phys.canterbury.ac.nz>
Subject: Linux: nfsroot and a Tulip card
Date: Tue, 30 Apr 2002 09:05:49 +1200 (NZST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204300855040.18407-100000@loony.phys.canterbury.ac.nz>
References: <DAV25aE7WD84jBtwuie00001eb9@hotmail.com>
Reply-To: "Ryurick M. Hristev" <r.hristev@phys.canterbury.ac.nz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cantva.canterbury.ac.nz ([132.181.30.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 172ILO-00009I-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Apr 2002 14:05:59 -0700
Received: from CONVERSION-DAEMON.it.canterbury.ac.nz by it.canterbury.ac.nz (PMDF V6.1 #39332) id <01KH63NCMLFK9F59JD@it.canterbury.ac.nz> for nfs@lists.sourceforge.net; Tue, 30 Apr 2002 09:05:49 +1200 (NEW ZEALAND STANDARD TIME)
Received: from loony.phys.canterbury.ac.nz (loony.phys.canterbury.ac.nz [132.181.41.100]) by it.canterbury.ac.nz (PMDF V6.1 #39332) with ESMTP id <01KH63NCSE0U936UUH@it.canterbury.ac.nz> for nfs@lists.sourceforge.net; Tue,
 30 Apr 2002 09:05:49 +1200 (NEW ZEALAND STANDARD TIME)
Received: from localhost (physrmh@localhost)	by loony.phys.canterbury.ac.nz (8.11.6/8.11.2) with ESMTP id g3TL5nM19005	for <nfs@lists.sourceforge.net>; Tue, 30 Apr 2002 09:05:49 +1200
In-Reply-To: <DAV25aE7WD84jBtwuie00001eb9@hotmail.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,

After a prolonged mucking around I am finally out of any idea.

I have a problem:

I have a Linux based PC with a Tulip type network card which refuses
to read the root filesystem over nfs.

Given that the card have to be DHCP configured the network driver
is compiled into the kernel. The system boots, it gets configured
via DHCP, mounts the root via nfs (as shown by the logs) then hangs. 

I have other systems with different network cards which do work
with the same setup. The system also works with Linux 2.2 but not 2.4

The tulip driver in Linux kernel 2.4 appears to be FUBAR so I used
the de4x5 which apparently works up to reading the nfsroot
(IIRC that was recommended by someone on the tulip driver mailing list).

TIA for any pointers, ideas, etc,

Cheers,
-- 
Ryurick M. Hristev mailto:r.hristev@phys.canterbury.ac.nz
Computer Systems Manager
University of Canterbury, Physics & Astronomy Dept., New Zealand


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
