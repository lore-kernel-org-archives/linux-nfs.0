From: Amit Gud <agud@redhat.com>
Subject: [PATCH 0 / 2] Move NFS mount code from util-linux to nfs-utils
Date: Thu, 08 Jun 2006 15:05:27 -0400
Message-ID: <448874F7.1070504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoPr5-0003ua-K1
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 12:07:43 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FoPr5-0005Cy-LV
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 12:07:43 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FoPqx-0007Xe-54
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 12:07:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1FoPqg-0005bw-Fk
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 12:07:25 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello Neil,

Here are the patches for nfs-utils part to move the NFS mount code from 
util-linux to nfs-utils. Let me know if there are any issues.

Patch description is below:

---

Moves the NFS mount code out of util-linux to nfs-utils. The primary 
reason being ease of maintainability, and keeping util-linux away from 
all the filesystem-specifc worries.

Adds a new directory 'mount' under utils. Creates a binary mount.nfs. 
Three symbolic links are created to this binary - mount.nfs4, umount.nfs 
and umount.nfs4. It is simpler and avoids code duplication (or overhead 
of fork->exec) by keeping umount code in a single binary along with the 
mount code. Mount code uses umount to handle certain fail cases. It also 
makes sense to keep single binary for all the versions of the NFS, as 
opposed to having seperate binaries mount.nfs and mount.nfs4, since the 
code falls back to lower version if mounting with v4 fails. Adds two man 
pages - mount.nfs(8) and umount.nfs(8).

Patches are split into two parts:
[1/2] nfsmount-migration-to-nfsutils-v2.patch
[2/2] nfsmount-migration-to-nfsutils-support-v2.patch

After applying the patches, do 'sh autogen.sh' before configuring and 
compiling.

---


AG
--
May the source be with you.
http://www.cis.ksu.edu/~gud



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
