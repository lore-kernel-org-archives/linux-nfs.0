From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: /etc/mtab as symbolic link
Date: Wed, 16 Feb 2005 09:17:13 +0100
Message-ID: <42130189.6090207@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1KN6-0000hX-5g
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 00:17:20 -0800
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D1KN4-0007Yo-EZ
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 00:17:20 -0800
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id C417743634
	for <nfs@lists.sourceforge.net>; Wed, 16 Feb 2005 09:17:14 +0100 (CET)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id B27EB43619
	for <nfs@lists.sourceforge.net>; Wed, 16 Feb 2005 09:17:14 +0100 (CET)
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

we are facing a problem which I've found (in google) to be a common
problem with diskless systems:

On diskless clients, mounting / ro from a server, /etc is not writable.
Like on other diskless systems, we are using links from /etc/ to some
local partition (here: /etc/local) and link the files which the clients
need to write to, into /etc/local.

For /etc/mtab, that doesn't work, because mount/umount create tmp
files in /etc/ and would also destroy the link (if they could write
to /etc). Linking /etc/mtab to /proc/mounts is not possible due to the
known drawbacks.
Currently, I patch util-linux myself to set _PATH_MOUNTED to /etc/local/mtab
in pathnames.h and include that file in fstab.h, but that's a very
specific solution for our system.

So my question: Is there a chance to change util-linux to make it

- leave /etc/mtab as symbolic link, i.e. work on the real file
    /etc/mtab is linked to instead of removing the link and recreating
    a normal file /etc/mtab?

- create all the tmp files in the directory where /etc/mtab is linked
    to, e.g., if /etc/mtab is a link to /etc/local/mtab, the tmp files
    should be created in /etc/local/, too?

This would defitinely help for diskless systems. I'm not familiar
with C, otherwise I would try it myself. Maybe it's not that difficult,
because I could change the location by just one definition in pathnames.h
and including this file in fstab.h. Would it be enough to replace the
definition in pathnames.h by some function like "if /etc/mtab is a
link then use the result of `readlink /etc/mtab`, otherwise take the
default location"? But I have no idea how to that in C.

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
