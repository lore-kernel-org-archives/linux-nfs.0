From: Steven Marcotte <sdmarcotte@comcast.net>
Subject: Problems writing large files using 2.6 client
Date: Wed, 14 Jan 2004 14:38:56 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1074112736.13992.6.camel@yoshi.private.network>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Agrn4-0007Z5-Sk
	for nfs@lists.sourceforge.net; Wed, 14 Jan 2004 12:39:02 -0800
Received: from rwcrmhc13.comcast.net ([204.127.198.39])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Agrn4-0000Lo-Ki
	for nfs@lists.sourceforge.net; Wed, 14 Jan 2004 12:39:02 -0800
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

I am having problems writing very large files via NFSv3 using a client
with the 2.6 kernel.  The NFS export is a subdirectory on an ext3 
partition.  The writes fail after transferring approximately 4.2 - 4.3
GB.  I can append the files in 1GB increments without any problems. I
can copy multiple 4.1GB files to the server without incident.  

The following command errors out every time, the number of records
written varies slightly.

  dd if=/dev/zero  of=/mnt/backup/test bs=1024 count=6M
  dd: writing `/mnt/backup/test': Invalid argument
  4376337+0 records in
  4376336+0 records out

An strace of the previous command reports the following:

  .
  .
  .
  read(0, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
    1024) = 1024
    
  write(1, 
    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1024) =
    1024

  read(0, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
    1024) = 1024

  write(1,
    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1024) =
    -1 EINVAL (Invalid argument)

  write(2, "dd: ", 4)                     = 4
  write(2, "writing `/mnt/backup/test\'", 26) = 26
  write(2, ": Invalid argument", 18)      = 18
  write(2, "\n", 1)                       = 1
  write(2, "4213600+0 records in\n", 21)  = 21
  write(2, "4213599+0 records out\n", 22) = 22
  close(0)                                = 0
  close(1)                                = 0
  _exit(1)                                = ?

There is nothing in the logs on either the client or the server that
indicates that an error occurred or why the write failed.  Both machines
are using the 2.6 kernel and NFSv3 connected via 100 Mbit link.  

The /etc/exports file on the server looks like:

  /mnt/backup/testing  yoshi(rw,no_root_squash,sync,no_subtree_check)

The /etc/fstab entry on the client looks like:

  qserver:/mnt/backup/testing     /mnt/backup     nfs    
        nfsvers=3,soft,rsize=8192,wsize=8192,noauto,noatime  0 0

The client kernel has the following kernel options set.

  CONFIG_NFS_FS=y
  CONFIG_NFS_V3=y
  CONFIG_NFSD=y
  CONFIG_NFSD_V3=y

I am able to write and 20GB file to the same server if I boot the client
with a 2.4 kernel.  The 2.4 kernel was prebuilt, however the 2.6 kernel
was hand tuned.  

I'm new to NFS so it is quite possible that I have messed something up
when I configured the 2.6 kernel.  Am I missing something obvious, or
have a found a bug?  I'd appreciate any help.


Quattro




-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
