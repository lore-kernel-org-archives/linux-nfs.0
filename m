From: Pascal Dameme <pascal.dameme@evidian.com>
Subject: NFSD bug when using nfsdfs (2.6.10 kernel, with reiserfs or ext3
 backing filesystem) ?
Date: Wed, 26 Jan 2005 10:19:01 +0100
Message-ID: <41F76085.7040303@evidian.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtjHh-0002B6-B8
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 01:16:21 -0800
Received: from odin2.bull.net ([192.90.70.84])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CtjHf-0007rs-MB
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 01:16:21 -0800
Received: from frn-001.evcl.evidian.com (frn-001.frcl.bull.fr [129.182.8.51])
	by odin2.bull.net (8.9.3/8.9.3) with ESMTP id KAA46656
	for <nfs@lists.sourceforge.net>; Wed, 26 Jan 2005 10:28:58 +0100
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

Hello,

When a locally exported directory is mounted other itself using nfs V3, 
after
a few minutes, the nfs servers starts issueing "ESTALE" on previously 
perfectly accessible files ... There is
no other activity except for the test script, that does "ls" in a loop ...

This behavior has been observed on redhat Fedora core 2, Suse SLES 9 
*and* 2.6.10 (from kernel.org) kernels.
The less activity there is, the fastest the problem appears ...

For some reason, it manifests *only if the nfsdfs filesystem is mounted*
(in "legacy" mode, where the filesystem is not mounted, the system behaves
normally for at least a week, whereas with the filesystem mounted, ESTALE
is returned after at  most 30 minutes)

Herafter, you will find a test scenario to reproduce the problem,
as well as all information I have dug so far . I searched the archives, 
but did not find anything related ...

Anyone ?

Best regards,
-- 
Pascal Dameme.


---------------------------------------------------------------------------------------------------------------- 

The test scenario to reproduce the problem is as follow (the test 
machine is
a SuSE distribution running a freshly compiled 2.6.10 kernel):

#start nfsd
/etc/rc.d/nfsserver start
#export test directory
exportfs -o rw,insecure,no_root_squash,no_subtree_check 127.0.0.1:/test/dir
#mount
mount -o hard,nolock,vers=3,proto=udp 127.0.0.1:/test/dir /test/dir

The following is a trace of what happens :

atchoum:~ # while true; do date;ls -ld /test/dir; sleep 60;done
Thu Jan  6 14:33:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:34:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:35:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:36:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:37:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:38:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:39:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:40:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:41:41 CET 2005
drwxr-xr-x  8 root root 360 Dec  7 13:46 /test/dir
Thu Jan  6 14:42:41 CET 2005
/bin/ls: /test/dir: Stale NFS file handle
Thu Jan  6 14:43:41 CET 2005
/bin/ls: /test/dir: Stale NFS file handle
Thu Jan  6 14:44:41 CET 2005
/bin/ls: /test/dir: Stale NFS file handle
Thu Jan  6 14:45:42 CET 2005
/bin/ls: /test/dir: Stale NFS file handle
Thu Jan  6 14:46:42 CET 2005
/bin/ls: /test/dir: Stale NFS file handle
Thu Jan  6 14:47:42 CET 2005
/bin/ls: /test/dir: Stale NFS file handle
Thu Jan  6 14:48:42 CET 2005
/bin/ls: /test/dir: Stale NFS file handle
Thu Jan  6 14:49:42 CET 2005
/bin/ls: /test/dir: Stale NFS file handle
Thu Jan  6 14:50:42 CET 2005
/bin/ls: /test/dir: Stale NFS file handle

I enabled the NFS debug messages, this is what is seen in the syslog file
around the problem:

Jan  6 14:40:41 atchoum kernel: NFS: revalidating (0:f/113840)
Jan  6 14:40:41 atchoum kernel: NFS call  getattr
Jan  6 14:40:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 14:40:41 atchoum kernel: nfsd: GETATTR(3)  12: 00000001 02000800 
0001bcb0 00000000 00000000 00000000
Jan  6 14:40:41 atchoum kernel: nfsd: fh_verify(12: 00000001 02000800 
0001bcb0 00000000 00000000 00000000)
Jan  6 14:40:41 atchoum kernel: NFS reply getattr
Jan  6 14:40:41 atchoum kernel: NFS: nfs_update_inode(0:f/113840 ct=1 
info=0x6)
Jan  6 14:40:41 atchoum kernel: NFS: (0:f/113840) revalidation complete
Jan  6 14:41:41 atchoum kernel: NFS: revalidating (0:f/113840)
Jan  6 14:41:41 atchoum kernel: NFS call  getattr
Jan  6 14:41:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 14:41:41 atchoum kernel: nfsd: GETATTR(3)  12: 00000001 02000800 
0001bcb0 00000000 00000000 00000000
Jan  6 14:41:41 atchoum kernel: nfsd: fh_verify(12: 00000001 02000800 
0001bcb0 00000000 00000000 00000000)
Jan  6 14:41:41 atchoum kernel: NFS reply getattr
Jan  6 14:41:41 atchoum kernel: NFS: nfs_update_inode(0:f/113840 ct=1 
info=0x6)
Jan  6 14:41:41 atchoum kernel: NFS: (0:f/113840) revalidation complete
Jan  6 14:41:42 atchoum kernel: exp_export: export of non-dev fs without 
fsidfound domain localhost
Jan  6 14:41:42 atchoum kernel: found fsidtype 0
Jan  6 14:41:42 atchoum kernel: found fsid length 8
Jan  6 14:41:42 atchoum kernel: Path seems to be <>
Jan  6 14:42:41 atchoum kernel: NFS: revalidating (0:f/113840)
Jan  6 14:42:41 atchoum kernel: NFS call  getattr
Jan  6 14:42:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 14:42:41 atchoum kernel: nfsd: GETATTR(3)  12: 00000001 02000800 
0001bcb0 00000000 00000000 00000000
Jan  6 14:42:41 atchoum kernel: nfsd: fh_verify(12: 00000001 02000800 
0001bcb0 00000000 00000000 00000000)
Jan  6 14:42:41 atchoum kernel: NFS reply getattr
Jan  6 14:42:41 atchoum kernel: nfs_revalidate_inode: (0:f/113840) 
getattr failed, error=-116
Jan  6 14:43:41 atchoum kernel: NFS: revalidating (0:f/113840)
Jan  6 14:43:41 atchoum kernel: NFS call  getattr
Jan  6 14:43:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 14:43:41 atchoum kernel: nfsd: GETATTR(3)  12: 00000001 02000800 
0001bcb0 00000000 00000000 00000000
Jan  6 14:43:41 atchoum kernel: nfsd: fh_verify(12: 00000001 02000800 
0001bcb0 00000000 00000000 00000000)
Jan  6 14:43:41 atchoum kernel: NFS reply getattr
Jan  6 14:43:41 atchoum kernel: nfs_revalidate_inode: (0:f/113840) 
getattr failed, error=-116

Somehow, it seems that check_export gets confused ...

I tried to mount the directory using the fsid= option, this seems to help a
little, but after some time, the following message appears in the syslog:

Jan  6 18:35:41 atchoum kernel: NFS: nfs_update_inode(0:f/113904 ct=1 
info=0x6)
Jan  6 18:35:41 atchoum kernel: NFS: (0:f/113904) revalidation complete
Jan  6 18:36:41 atchoum kernel: NFS: revalidating (0:f/113904)
Jan  6 18:36:41 atchoum kernel: NFS call  getattr
Jan  6 18:36:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 18:36:41 atchoum kernel: nfsd: GETATTR(3)  8: 00010001 00000309 
00000000 00000000 00000000 00000000
Jan  6 18:36:41 atchoum kernel: nfsd: fh_verify(8: 00010001 00000309 
00000000 00000000 00000000 00000000)
Jan  6 18:36:41 atchoum kernel: NFS reply getattr
Jan  6 18:36:41 atchoum kernel: NFS: nfs_update_inode(0:f/113904 ct=1 
info=0x6)
Jan  6 18:36:41 atchoum kernel: NFS: (0:f/113904) revalidation complete
Jan  6 18:37:41 atchoum kernel: NFS: revalidating (0:f/113904)
Jan  6 18:37:41 atchoum kernel: NFS call  getattr
Jan  6 18:37:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 18:37:41 atchoum kernel: nfsd: GETATTR(3)  8: 00010001 00000309 
00000000 00000000 00000000 00000000
Jan  6 18:37:41 atchoum kernel: nfsd: fh_verify(8: 00010001 00000309 
00000000 00000000 00000000 00000000)
Jan  6 18:37:41 atchoum kernel: nfsd: Dropping request due to malloc 
failure!
Jan  6 18:37:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 18:37:41 atchoum kernel: nfsd: GETATTR(3)  8: 00010001 00000309 
00000000 00000000 00000000 00000000
Jan  6 18:37:41 atchoum kernel: nfsd: fh_verify(8: 00010001 00000309 
00000000 00000000 00000000 00000000)
Jan  6 18:37:41 atchoum kernel: nfsd: Dropping request due to malloc 
failure!
Jan  6 18:37:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 18:37:41 atchoum kernel: nfsd: GETATTR(3)  8: 00010001 00000309 
00000000 00000000 00000000 00000000
Jan  6 18:37:41 atchoum kernel: nfsd: fh_verify(8: 00010001 00000309 
00000000 00000000 00000000 00000000)
Jan  6 18:37:41 atchoum kernel: nfsd: Dropping request due to malloc 
failure!
Jan  6 18:37:41 atchoum kernel: nfsd_dispatch: vers 3 proc 1
Jan  6 18:37:41 atchoum kernel: nfsd: GETATTR(3)  8: 00010001 00000309 
00000000 00000000 00000000 00000000
Jan  6 18:37:41 atchoum kernel: nfsd: fh_verify(8: 00010001 00000309 
00000000 00000000 00000000 00000000)
Jan  6 18:37:41 atchoum kernel: nfsd: Dropping request due to malloc 
failure!

Looks like a  memory leak ...



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
