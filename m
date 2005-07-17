From: Jeff Layton <jtlayton@poochiereds.net>
Subject: making the 'addr=' mount option an address hint
Date: Sun, 17 Jul 2005 11:38:28 -0400
Message-ID: <1121614708.6713.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuBDs-0004OU-7w
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 08:38:32 -0700
Received: from ms-smtp-04-lbl.southeast.rr.com ([24.25.9.103] helo=ms-smtp-04-eri0.southeast.rr.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DuBDr-0000RT-O2
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 08:38:32 -0700
Received: from mail.poochiereds.net (cpe-065-190-221-104.nc.res.rr.com [65.190.221.104])
	by ms-smtp-04-eri0.southeast.rr.com (8.12.10/8.12.7) with ESMTP id j6HFcSL4023389
	for <nfs@lists.sourceforge.net>; Sun, 17 Jul 2005 11:38:28 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.poochiereds.net (Postfix) with ESMTP id DBCD93C122
	for <nfs@lists.sourceforge.net>; Sun, 17 Jul 2005 11:38:27 -0400 (EDT)
Received: from mail.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 19526-04 for <nfs@lists.sourceforge.net>;
	Sun, 17 Jul 2005 11:38:27 -0400 (EDT)
Received: from tleilax.poochiereds.net (tleilax.poochiereds.net [192.168.1.3])
	by mail.poochiereds.net (Postfix) with ESMTP id B1E583C05D
	for <nfs@lists.sourceforge.net>; Sun, 17 Jul 2005 11:38:27 -0400 (EDT)
To: nfs@lists.sourceforge.net
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
  I've been working on a fairly major overhaul of the autofs mount_nfs
code. One of the things I've recently added is making it prefer to mount
from server addresses that are on the same subnet as the client.

  Unfortunately, I've found that when the mount program does a
gethostbyname() call to get the address of the host, it simply picks the
first address in the list, without regard for how "close" it is to the
client.

The upshot of this is that if even autofs picks a replicated mount entry
that is on the same subnet as the client, we may end up mounting across
a router anyway.

A simple way to correct this would be to make autofs pass the address
instead of the hostname when calling "mount". However, that will make
for an ugly /proc/mounts, especially if we have a lot of automounted NFS
mounts (it's more human-friendly to keep the hostname info when looking
at the list of mounts).

So, what I'd like to do is roll a patch for mount to change the behavior
of the 'addr=' option. Instead of ignoring it, we'd treat it as an
address hint. If one of the addresses returned by gethostbyname()
matches this address, then we'd mount using that address. Otherwise, the
existing behavior would prevail (use the first address in the list).

I'm writing this to solicit some feedback before I dive in and start
working on it. Does this sound like a reasonable idea? Is there
something I'm not considering that would prevent this from working?

Thanks,
Jeff




-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
