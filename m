From: James Pearson <james-p@moving-picture.com>
Subject: Server/client mismatch over status of a mount ...
Date: Mon, 17 Feb 2003 14:06:09 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E50EC51.6022D3A7@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18klux-0008Ed-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 06:06:47 -0800
To: nfs@lists.sourceforge.net, autofs@linux.kernel.org
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

We've had a number of cases recently whereby NFS servers think a client
has umounted a disk, but the client still has the disk mounted.

i.e. the client's entry in the server's /var/lib/nfs/rmtab has been
removed.

The clients mount the NFS disks using autofs

This doesn't cause a problem in normal use (processes running on the
client can access the mounted file system OK) - but if the server
reboots, processes on the client get 'permission denied' when accessing
the mounted file system from the server (not surprising, as the server
has no record on the mount).

The problem _seems_ to occur with processes on the client that are in a
defunct state, and may have been so for days (or weeks) e.g. here is the
edited logs from a client and server:

client:

messages.4:Jan 20 13:00:04 client automount[505]: attempting to mount
entry /export/server1
messages.4:Jan 20 13:09:55 client automount[2416]: expired
/export/server1
messages.4:Jan 20 13:21:48 client automount[505]: attempting to mount
entry /export/server1


server:

messages.4:Jan 20 13:00:04 server rpc.mountd: authenticated mount
request from client:641 for /disk1 (/disk1) 
messages.4:Jan 20 13:09:55 server rpc.mountd: authenticated unmount
request from client:898 for /disk1 (/disk1) 
messages.4:Jan 20 13:21:48 server rpc.mountd: authenticated mount
request from client:709 for /disk1 (/disk1) 
messages.4:Jan 20 14:09:40 server rpc.mountd: authenticated unmount
request from client:912 for /disk1 (/disk1) 


As you can see, rpc.mountd on the server has recorded an unmount request
at 14:09:40, but there is no corresponding automount 'expired' message
on the client for this file system ... the file system is still mounted
on the client (and usable) - however, if the server were to reboot, then
the client would no longer be able to access the file system.

If I kill the parent process of the defunct process, autofs will not
umount the mount, but I can manually umount the file system and then
access it again as normal.

I'm using a 2.4.18 based kernels on the client and server. The server is
using nfs-utils 0.3.3 and the client autofs 4.0.0pre10

Could there be a case where automount tells the server it's umounting a
mount, but then finds it can't actually do the umount?

James Pearson


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
