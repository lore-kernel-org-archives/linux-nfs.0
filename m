From: Amit Gud <agud@redhat.com>
Subject: [PATCH 0 / 1] Move NFS mount code from util-linux to
 nfs-utils - take2
Date: Mon, 12 Jun 2006 19:02:17 -0400
Message-ID: <448DF279.8090005@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050008010100070706070902"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpvND-00073K-NT
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 15:59:07 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FpvND-0007Sq-CJ
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 15:59:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FpvNC-00022w-8d
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 15:59:07 -0700
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

This is a multi-part message in MIME format.
--------------050008010100070706070902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


--------------050008010100070706070902
Content-Type: text/plain; name="nfsmount-migration-to-nfsutils-v4.patch.desc"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="nfsmount-migration-to-nfsutils-v4.patch.desc"

Moves the NFS mount code out of util-linux to nfs-utils. The primary reason being ease of maintainability, and keeping util-linux away from all the filesystem-specifc worries.

Adds a new directory 'mount' under utils. Creates a binary mount.nfs. Three symbolic links are created to this binary - mount.nfs4, umount.nfs and umount.nfs4. It is simpler and avoids code duplication (or overhead of fork->exec) by keeping umount code in a single binary along with the mount code. Mount code uses umount to handle certain fail cases. It also makes sense to keep single binary for all the versions of the NFS, as opposed to having seperate binaries mount.nfs and mount.nfs4, since the code falls back to lower version if mounting with v4 fails. Adds two man pages - mount.nfs(8) and umount.nfs(8).

Patches are split into two parts:
[1/2] nfsmount-migration-to-nfsutils-v2.patch
[2/2] nfsmount-migration-to-nfsutils-support-v2.patch

After applying the patches before configuring and compiling, do:
$ rpcgen -c utils/mount/nfsmount.x > utils/mount/nfsmount_xdr.c
$ rpcgen -h utils/mount/nfsmount.x > utils/mount/nfsmount.h
$ sh autogen.sh

---


--------------050008010100070706070902
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--------------050008010100070706070902
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050008010100070706070902--
