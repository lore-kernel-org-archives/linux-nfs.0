From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: fcntl locks prevent unmounting of underlying filesystem
Date: Wed, 26 May 2004 12:43:15 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085589795.20517.41.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT1Ut-0007sx-4A
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:43:19 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BT1Us-0003jK-Kz
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:43:18 -0700
Received: from localhost (localhost [127.0.0.1])
	by salusa.poochiereds.net (Postfix) with ESMTP id BE7CEE429
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 12:43:09 -0400 (EDT)
Received: from salusa.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 14956-07 for <nfs@lists.sourceforge.net>;
	Wed, 26 May 2004 12:43:09 -0400 (EDT)
Received: from localhost (salusa.poochiereds.net [192.168.1.2])
	by salusa.poochiereds.net (Postfix) with ESMTP id 6CF462622
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 12:43:09 -0400 (EDT)
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

I've seem to have run across a problem with NFS and fcntl locks. I'm
trying to implement a HA-NFS solution using heartbeat, DRBD, LVM2, etc.
I'm running the following:

2.6.6 kernel
nfs-kernel-server and nfs-common 1.0.6-3 (debian packages)

The underlying filesystem is reiserfs. Essentially what I'm seeing is
that when I try to shut down NFS and unmount the filesystem for a
failover, I'm unable to unmount if I have an fcntl lock on the file.

Here's the C program I used to test the locks (my C coding is not the
best, I copied a lot of this from R. Stevens' book):


-------------------------[snip]------------------------

#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
                                                                                
#define write_lock(fd, offset, whence, len) \
        lock_reg(fd, F_SETLK, F_WRLCK, offset, whence, len)
                                                                                
int main( int argv, char *argc[] ) {
                                                                                
    int fd;
                                                                                
    fd = open(argc[1], O_RDWR);
 
    if ( write_lock(fd, 0, SEEK_SET, 0) < 0 ) {
        printf("Unable to acquire lock!\n");
    } else {
        printf("Got the lock. Sleeping for 300 secs.\n");
        sleep(300);
    }
 
    close(fd);
}
 
int lock_reg (int fd, int cmd, int type, off_t offset, int whence, off_t
len) {
 
    struct flock lock;
 
    lock.l_type = type;
    lock.l_start = offset;
    lock.l_whence = whence;
    lock.l_len = len;
 
    return (fcntl(fd, cmd, &lock)); 
}

-----------------------[snip]-----------------------------

I run this program against a file on an NFS mounted directory on the
client machine. On the server, I then shut down NFS (using the debian
nfs-common and nfs-kernel-server startup scripts).

I'm then unable to unmount the underlying filesystem. The error message
is (yes, umount prints it twice for some reason):

umount: /services/NFS/home: device is busy
umount: /services/NFS/home: device is busy

If I then start up NFS again, and kill the locktest program, I'm then
able to shut down nfs and unmount the filesystem.

I also did a test where I just opened the file r/w without locking it,
and it didn't seem to have the same problem, so it seems like the
fcntl() lock is what is causing the problem (though I could be wrong
here).

I've been able to replicate this problem with /proc/fs/nfsd mounted and
unmounted on the server.

I also tried applying the exportfs patch that was in the thread:

   nfsd, rmtab, failover, and stale filehandles

on this mailing list earlier this month, and it didn't help. Has anyone
else seen this problem?

If there's any other info you need me to provide to help diagnose this,
please don't hesitate to ask!

Thanks,
Jeff




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
