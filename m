From: Olaf Kirch <okir@suse.de>
Subject: NFS suport block sharing
Date: Wed, 18 Feb 2004 17:37:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040218163702.GB31893@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="U+BazGySraz5kW0T"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtUlw-0003wF-KC
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 08:42:04 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AtUZv-0006GN-Af
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 08:29:39 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	by Cantor.suse.de (Postfix) with ESMTP id 080561FBEB2
	for <nfs@lists.sourceforge.net>; Wed, 18 Feb 2004 17:37:03 +0100 (CET)
To: nfs@lists.sourceforge.net
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


--U+BazGySraz5kW0T
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi,

yesterday, I ran into something that puzzled me quite a bit.  I had an
NFS file system (my home directory) mounted in its normal location. For
testing purposes, I wanted to mount it a second time, but with a different
set of options (hard instead of soft, etc).

To my surprise, the second mount continued to act like the original
mount, as if it had been mounted with -o soft. /etc/mtab showed the
options I had specified, but /proc/mounts showed that it indeed used
soft retransmits.

To make a long story short, I think _if_ we do NFS super block
sharing, we should make sure we use don't reuse an existing
sb if it has different options. Attached is a patch that implements
this, at least for the most common set of options.

Comments?

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--U+BazGySraz5kW0T
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfs-super-reuse

--- inode.c-reuse	2004-02-17 16:58:25.000000000 +0100
+++ inode.c	2004-02-17 17:00:01.000000000 +0100
@@ -1320,6 +1320,14 @@
 		return 0;
 	if (old->addr.sin_port != server->addr.sin_port)
 		return 0;
+	if (old->flags != server->flags
+	 || old->rsize != server->rsize
+	 || old->wsize != server->wsize
+	 || old->acregmin != server->acregmin
+	 || old->acregmax != server->acregmax
+	 || old->acdirmin != server->acdirmin
+	 || old->acdirmax != server->acdirmax)
+	 	return 0;
 	return !memcmp(&old->fh, &server->fh, sizeof(struct nfs_fh));
 }
 

--U+BazGySraz5kW0T--


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
