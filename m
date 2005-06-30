From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Strange problem with ACL over NFS
Date: Thu, 30 Jun 2005 13:47:40 +0200
Message-ID: <42C3DBDC.5050803@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnxWD-0006rv-DH
	for nfs@lists.sourceforge.net; Thu, 30 Jun 2005 04:47:45 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DnxWC-0004XC-Da
	for nfs@lists.sourceforge.net; Thu, 30 Jun 2005 04:47:45 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.ifi.lmu.de (Postfix) with ESMTP id 144B64367F
	for <nfs@lists.sourceforge.net>; Thu, 30 Jun 2005 13:47:42 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.ifi.lmu.de (Postfix) with ESMTP id 04AAC4367E
	for <nfs@lists.sourceforge.net>; Thu, 30 Jun 2005 13:47:42 +0200 (CEST)
To: NFS NFS <nfs@lists.sourceforge.net>
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

Hi,

I have a strange problem trying to use ACLs over NFS.

Our NFS server exports two directories /home and /rpm.
/rpm is exported ro, /home contains all the user homes
and is exported rw. Both are reiserfs.

The NFS server is running a 2.6.8 SuSE kernel (SuSE 9.2).
To activate ACLs, I stopped the nfs server, remounted
the local FS with acl and restarted the nfs server.
Then I set some acls on some files in /rpm and in /home.

Almost all clients (running the same kernel) could immediately
see the ACLs (i.e., the + sign in the ls output) on both
directories without remounting (so I guess the "defaults"
includes the acl option for NFS mounts already).

But on some hosts (especially some IBM xSeries) the ACLs
are visible in /rpm, but not in /home. Changing the lines
in fstab to "defaults,acl" didn't change that. The ACLs in
/home are not visible, even not after rebooting the host
several times (the "+" does not show up in ls, and getfacl
doesn't report any additional acls).

However, when I unmount /home and remount with "mount /home",
suddendly the ACLs are visible and can even be changed.
(just remounting with "-o remount" does not work).
But when rebooting the host, the ACLs are invisible again
until unmounting and remounting /home once again.

Any ideas what could go wrong here?

All the hosts are installed identically via autoyast (same
kernel, same software distribution, same mounts, users etc.)


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
