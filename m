From: Tobias Burnus <tobias.burnus@physik.fu-berlin.de>
Subject: NFS problem if NFS server dies
Date: Wed, 4 Dec 2002 17:57:00 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0212041741510.12033-100000@warp9.physik.fu-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from up.physik.fu-berlin.de ([160.45.34.5])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Jcq8-00015a-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Dec 2002 08:57:36 -0800
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

Hi,

in our larger installation we encountered really big problems if the NFSd
server of a auto mounted scratch partition died. (Which happend twice the
last two days :-()

This /net/<comp>/* directory was accessed by a number crunching job, which
then suddenly couldn't write anymore.

The problem is not that that single process hangs, but that this rendered
the complete computer almost useless, since it was both _really_ slow
(load of >=5) and unrelated NFS operations (different server) didn't work
well either. (This might be due to the fact that almost all directories
use the automounter which also serves /net)

Those /net/*/* directories are mounted with
  rw,nosuid,nodev,noquota,intr
(despite the "noquota", quota does hang, if /net/*/ hangs)

Any idea what we could to limit those problems, thus one could continue to
interactively work with that computer, until a manual intervention (such
as reanimating the dying server).

With best regards,

Tobias Burnus

PS: We use a - more or less - vanilla 2.4.18 kernel. In those cases
described above, both server and client are Linux computers.



-------------------------------------------------------
This SF.net email is sponsored by: Microsoft Visual Studio.NET 
comprehensive development tool, built to increase your 
productivity. Try a free online hosted session at:
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
