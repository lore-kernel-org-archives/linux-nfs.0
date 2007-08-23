From: z00t@gmx.net
Subject: umount fails with device busy
Date: Thu, 23 Aug 2007 20:45:44 +0200
Message-ID: <20070823184544.237460@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOHhm-00085d-8U
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 11:46:55 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IOHgp-0007qL-Bi
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 11:45:56 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi guys,

I get the device busy error when I try to umount an NFS file system althoug=
h there is no process with an open file on it (at least fuser -m /mnt/point=
 and lsof +f -- /mnt/point don't find anything).

To be more precise this only happens, when I run the umount right after sto=
pping an application which has its executables and work directory on this f=
ile system. Running umount again some seconds later works fine. =


I do not have any submounts under this mount point. There are no packet tra=
nsmit or receive errors nor any NFS/RPC errors only a very small number of =
RPC retransmitts. So it seems that I have a stable environment. Client and =
server is SLES9 with 2.6.5-7.202.7-smp/X86_64. =


I enabled NFS debug output and the only noticeable thing is, that some NFS =
operations are still ongoing after the application processes have already t=
erminated:

  Aug 23 08:25:23 marvin kernel: NFS reply getattr
  Aug 23 08:25:23 marvin kernel: NFS: nfs_update_inode(0:12/149296 ct=3D1 i=
nfo=3D0x6)
  Aug 23 08:25:23 marvin kernel: NFS: (0:12/149296) revalidation complete
  Aug 23 08:25:23 marvin kernel: nfs: flush(0:12/149296)
  Aug 23 08:25:23 marvin kernel: NFS: dentry_delete(bin/stop, 0)
  Aug 23 08:25:23 marvin kernel: NFS: revalidating (0:12/2)
  Aug 23 08:25:23 marvin kernel: NFS call  getattr
  Aug 23 08:25:23 marvin kernel: NFS reply getattr
  Aug 23 08:25:23 marvin kernel: NFS: nfs_update_inode(0:12/2 ct=3D1 info=
=3D0x6)
  Aug 23 08:25:23 marvin kernel: NFS: (0:12/2) revalidation complete
  Aug 23 08:25:25 marvin kernel: NFS call  fsstat
  Aug 23 08:25:25 marvin kernel: NFS reply statfs: 0
  Aug 23 08:25:35 marvin kernel: NFS call  fsstat
  Aug 23 08:25:35 marvin kernel: NFS reply statfs: 0
  Aug 23 08:25:38 marvin kernel: NFS: 6368 initiated commit call
  Aug 23 08:25:38 marvin kernel: NFS: 6369 initiated commit call
  Aug 23 08:25:38 marvin kernel: NFS: 6370 initiated commit call
  Aug 23 08:25:38 marvin kernel: NFS: 6371 initiated commit call
  Aug 23 08:25:38 marvin kernel: NFS: 6368 nfs_commit_done (status 0)
  Aug 23 08:25:38 marvin kernel: NFS: commit (0:12/121805 3207@0)NFS: dentr=
y_delete(log/mux_marvin.trc, 0)
  Aug 23 08:25:38 marvin kernel:  OK
  Aug 23 08:25:38 marvin kernel: NFS: 6369 nfs_commit_done (status 0)
  Aug 23 08:25:38 marvin kernel: NFS: commit (0:12/149304 2238@0)NFS: dentr=
y_delete(log/pw_marvin_1.trc, 0)
  Aug 23 08:25:38 marvin kernel:  OK
  Aug 23 08:25:38 marvin kernel: NFS: 6370 nfs_commit_done (status 0)
  Aug 23 08:25:38 marvin kernel: NFS: commit (0:12/149297 2238@0)NFS: dentr=
y_delete(log/pw_marvin_0.trc, 0)
  Aug 23 08:25:38 marvin kernel:  OK
  Aug 23 08:25:38 marvin kernel: NFS: 6371 nfs_commit_done (status 0)
  Aug 23 08:25:38 marvin kernel: NFS: commit (0:12/149295 965@0)NFS: dentry=
_delete(net.trc, 0)
  Aug 23 08:25:38 marvin kernel:  OK
  Aug 23 08:25:45 marvin kernel: NFS call  fsstat
  Aug 23 08:25:45 marvin kernel: NFS reply statfs: 0
  Aug 23 08:25:55 marvin kernel: NFS call  fsstat

When I run umount during these ops I get an device busy. Any help would be =
very appreciated!


-- =

Der GMX SmartSurfer hilft bis zu 70% Ihrer Onlinekosten zu sparen! =

Ideal f=FCr Modem und ISDN: http://www.gmx.net/de/go/smartsurfer

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
