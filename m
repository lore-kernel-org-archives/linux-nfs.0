From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Mon, 06 Sep 2004 08:47:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413C081E.9010307@bio.ifi.lmu.de>
References: <chdp06$e56$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4DII-0006y3-MZ
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 23:48:02 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C4DIH-0006eO-Vv
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 23:48:02 -0700
To: =?ISO-8859-1?Q?Sven_K=F6hler?= <skoehler@upb.de>
In-Reply-To: <chdp06$e56$1@sea.gmane.org>
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

I had two issues which caused the same behavious for me. Maybe check those.

1) there was a race condition in the nfs server, not yet fixed in 2.6.8.1
    that caused stale handels if the server restarted too fast, i.e.,
    without at least a "sleep 1" between stop and start.
    Neil sent a patch for this on the list on August 18th.

2) on SuSE 9.0, (maybe 9.1, maybe earlier too) the /etc/init.d/nfsserver
    script was broken in that it called "/usr/sbin/exportfs -au" before
    "killproc rpc.mountd" which caused a lot of stale handles. Maybe
    you have sth. similar?

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
