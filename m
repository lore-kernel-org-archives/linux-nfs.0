From: Greg Bradner <gregb@rhythm.com>
Subject: mounting problem
Date: Wed, 15 Jun 2005 06:46:16 -0700
Message-ID: <42B03128.7070807@rhythm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiYDm-0004r2-CD
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 06:46:22 -0700
Received: from centennial.earthnet.net ([66.151.173.5])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DiYDl-00050Q-Vp
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 06:46:22 -0700
Received: from mail.rhythm.com (mail.rhythm.com [24.130.28.101])
	by centennial.earthnet.net (Postfix) with ESMTP id C3DB633266
	for <nfs@lists.sourceforge.net>; Wed, 15 Jun 2005 07:44:27 -0600 (MDT)
Received: from mailhost.rhythm.com (gw-dmz.rhythm.com [24.130.28.100])
	by mail.rhythm.com (8.13.1/8.12.5) with ESMTP id j5FDkG3d016515
	for <nfs@lists.sourceforge.net>; Wed, 15 Jun 2005 06:46:16 -0700
Received: from [10.4.7.102] (lid2.rhythm.com [10.4.7.102])
	by mailhost.rhythm.com (8.12.9/8.12.5) with ESMTP id j5FDkGJv017590
	for <nfs@lists.sourceforge.net>; Wed, 15 Jun 2005 06:46:16 -0700
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

I'm new to the list and apologize if this is a rehash.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


This happens with autofs or using mount directly.

However I mount the NAS disk the first time, the same characteristics 
are passed to future mounts.

## This is a read only mount point and you can see the options in the 
/proc/mounts file at the bottom
 > cd /nfs/ro3/fs14/a/rla/

 > df -k .
Filesystem           1K-blocks      Used Available Use% Mounted on
fs14:/a/rla          657148928 545010048 112138880  83% /nfs/ro3/fs14/a/rla

## Then when I go to a mount point that shouldn't be read only, it take 
the options from the previous mount.
 > cd /fs14a/rla/

 > df -k .
Filesystem           1K-blocks      Used Available Use% Mounted on
fs14:/a/rla          657148928 545010048 112138880  83% /fs14a/rla

 > touch test
touch: cannot touch `test': Read-only file system

 > tail /proc/mounts
automount(pid3481) /ntap10 autofs rw 0 0
automount(pid3599) /morph autofs rw 0 0
automount(pid3538) /systems autofs rw 0 0
/dev/hda7 /home/gregb ext3 rw 0 0
fs14:/a/jobs /nfs/ro3/fs14/a/jobs nfs 
ro,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=fs14 0 0
fs14:/a/rla /nfs/ro3/fs14/a/rla nfs 
ro,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=fs14 0 0
fs14:/b/rla /nfs/ro3/fs14/b/rla nfs 
ro,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=fs14 0 0
fs14:/root0 /nfs/ro3/fs14/root0 nfs 
ro,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=fs14 0 0
fs14:/root1 /nfs/ro3/fs14/root1 nfs 
ro,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=fs14 0 0
fs14:/a/rla /fs14a/rla nfs 
ro,nosuid,nodev,v3,rsize=32768,wsize=32768,hard,intr,udp,lock,addr=fs14 0 0


What is the culprit and is there a fix?

-- 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
gregb@rhythm.com



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
