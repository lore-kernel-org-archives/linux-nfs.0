From: Kashif Shaikh <kshaikh@consensys.com>
Subject: nfs-utils/lockd problems
Date: 19 Jul 2002 13:45:08 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1027100709.25617.166.camel@k2x>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [209.47.40.2] (helo=mailnet.consensys.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Vbp3-0006sy-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Jul 2002 10:45:46 -0700
Received: from k2x (bozo@[209.47.40.10])
	by mailnet.consensys.com (8.11.6/8.11.2) with ESMTP id g6JHmlV20316
	for <nfs@lists.sourceforge.net>; Fri, 19 Jul 2002 17:48:47 GMT
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello everyone,

I'm encountering unmount issues with lockd on stock 2.4.18 kernels.  The
problem:

On the raidzone1(ip=192.168.2.224) server host(where knfsd is running on
2.4.18), prior to exporting /home to client 192.168.2.134 with
rw,sync,no_root_squash options, I mount /dev/sda1 to /home. Then I
export the client.(btw, this is the only client+export point in the
kernel tables)

On the nfs client(ip=192.168.2.134) which also has a stock 2.4.18
kernel, I mount the nfs export-point /home from raidzone1 onto /test. I
go ahead and issue a posix file lock(range=whole file) for *one* file 
on the mounted nfs filesystem.  The nfs client acquires the lock
successfully.  

The problem:

Now on the server host I unexport the client via unexportfs -u
192.168.2.134:/home. Checked /proc/fs/nfs/exportfs: cleaned-out,no
entries. Remember: client still has /home mounted on his side.

But, when I try to umount /dev/sda1 from /home, I get a "device is busy"
error.  Same error even if I try to force the umount.

It is important to note, that I only get the umount problems IF the
client has issued locks.  It doesn't matter if the client has open files
on the nfs fs, transferring data, type of lock,etc.

A simple work-around for this problem is to shutdown the nfs subsystem
and restart it.  Another way would be if the client unlocks the files. 
In both cases I can proceed to umount /home.  To me however, such
solutions are unacceptable.  I know this much: this problem is with
lockd.

More investigation reveals that knfsd is informing lockd to remove locks
when a *client* is removed.  Call path: handle_sys_nfsservctl->
nfsdelclient->exp_delcient->exp_freeclient->nfsd_lockd_unexport->
nlmsvc_invalidate_client. Funny thing is, exportfs in
nfs-utils-1.0.1-pre8 never calls nfsctl() with NFS_DELCLIENT when
unexporting a client+export_point; it only calls nfsctl() with
NFS_UNEXPORT.  On the other hand, exportfs does call nfsctl() with
NFS_ADDCLIENT & NFS_EXPORT.


So has anyone come up with a fix where knfsd tells lockd to "remove all
locks on this nfs filesystem/export-point"? 

Thanks for any help,

Kashif Shaikh




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
