From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Subject: Re: Strange problem with ACL over NFS
Date: Mon, 04 Jul 2005 11:04:22 +0200
Message-ID: <42C8FB96.60806@bio.ifi.lmu.de>
References: <42C3DBDC.5050803@bio.ifi.lmu.de> <1120157929.8922.14.camel@lade.trondhjem.org> <42C4DA08.8070202@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	NFS NFS <nfs@lists.sourceforge.net>, Olaf Kirch <okir@suse.de>,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpMsT-0002rj-7E
	for nfs@lists.sourceforge.net; Mon, 04 Jul 2005 02:04:33 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DpMsR-0007ZA-JI
	for nfs@lists.sourceforge.net; Mon, 04 Jul 2005 02:04:33 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <42C4DA08.8070202@bio.ifi.lmu.de>
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

Frank Steiner wrote

> Here's sth. new I found out this morning: It looks like the _first_
> NFS mount from the server does not get ACLs. I.e., when I switch the
> order of the entries so that /rpm is mounted first, /home second, then
> the ACLs are visible on /home but not on rpm.
> I added a second NFS server with one export and activated ACLs there,
> and it's still the same: Whichever of the three mounts comes first
> does not have ACLs until it is unmounted and remounted. So if the
> new NFS mount entry comes first on the client, both /rpm and /home
> will have ACLs.
> 
> So this looks more like a client bug to me, because it is not always
> the first mount from the same server that does not have ACL, but the
> first overall NFS mount. Like the client was not able to initialize
> ACLs for NFS before the first mount is done...
> 
> I will check a recent kernel on the client side.

Seems to be a bug in <= 2.6.8 (maybe .9, .10). I checked the SuSE kernel
from SuSE 9.3 which is a 2.6.11 (I'm always using SuSE kernels due to some
patches in there that I need), and the problem goes away. Now also the
first mount from the 2.6.8-server has ACLs. So it really looks like a
client bug. Now I must hope that the SuSE team might fix this for the
older kernels :-)

Olaf/Andreas: If you want to take a look at this bug, let me know if
I can provide some logs/debugging info etc. With the server running
the 2.6.8 from 9.2, the bug occurs on the client side with 2.6.8
and the 2.6.5 from SLES9 up to SP2-RC, but not with 2.6.11.4-21.7
from 9.3.

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
