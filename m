From: Dexter Filmore <Dexter.Filmore@gmx.de>
Subject: Strange copy/syncing behavior
Date: Sun, 2 May 2004 12:47:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040502124731.2ff6b9dd@shodan.citadel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKEVX-0008Uk-Pj
	for nfs@lists.sourceforge.net; Sun, 02 May 2004 03:47:39 -0700
Received: from imap.gmx.net ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BKEVX-0007jJ-8x
	for nfs@lists.sourceforge.net; Sun, 02 May 2004 03:47:39 -0700
To: nfs@lists.sourceforge.net <nfs@lists.sourceforge.net>
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


System setup: two Slackware 9.1/current machines, both almost identically
configured.
Both act as NFS servers.
As client from one machine everything is perfectly alright, but:

That machine acting as a server is strange, when I try and copy stuff to it,
let's say a 200MB file.
midnight commander will then report a transfer speed of around 30MB (which on
a 100MBit net is impossible), when the progress bar is completed, it will
stall for about 20 seconds, which together with the actually reported copy
process is the time it takes to copy the file at around 7.5MB/s, which is a
sane value.
exports line shoes as follows:
/mnt/a5 192.168.0.0/255.255.255.0(rw,sync,no_root_squash)
file system there is XFS.

When mounting with "sync" parameter, tho it should be synced anyway, transfer
speed drops to 200k/s.

Like I said, when that machine as client and the other as server it's smooth
sailing, mc nicely reports 7.some MB/s (which btw kicks Samba square in the
balls), progress bar advances as the transfer does, not all at once.

Any pointers?

Dex


-- 
-----BEGIN GEEK CODE BLOCK-----
Version: 3.12
GCS d--(+)@ s-:+ a- C+++(++++) UL+>++++ P+>++ L+++>++++ E-- W++ N o? K-
w--(---) !O M+ V- PS++(+) PE(-) Y+ PGP(-) t++(---)@ 5 X+(++) R+(++) tv--(+)@ 
b+(+++) DI+++ D G++ e* h>++ r%>* y?
------END GEEK CODE BLOCK------

http://www.againsttcpa.com - nothing fights like the opposition


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
