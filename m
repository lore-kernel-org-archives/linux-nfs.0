From: Dennis Cahillane <dennis@wittmanhydro.com>
Subject: NFS share will not mount
Date: Wed, 20 Aug 2003 15:42:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F43DD33.4040705@wittmanhydro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.wittmanhydro.com ([216.9.129.211] helo=old.wittmanhydro.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19pZtl-0001I9-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Aug 2003 13:49:41 -0700
To: nfs@lists.sourceforge.net
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

hello-

I have two machines that need to talk to each other via NFS.  The 
server, wabash, is configured:

# cat /etc/exports
/ev/in/statewide-data/drg 192.168.23.0/24(ro)

The client, wms, is configured as follows

# cat /etc/fstab
...
192.168.23.17:/ev/in/statewide-data/drg /var/www/html/in_maps/data/drg 
nfs    defaults         0 0

When I try to mount, the following happens.

# mount -a
mount: wrong fs type, bad option, bad superblock on 
192.168.23.17:/ev/in/statewide-data/drg,
        or too many mounted file systems

 From either machine.  The /var/log/messages on the client gains:

Sep  9 16:28:25 wms kernel: nfs_get_root: getattr error = 116
Sep  9 16:28:25 wms kernel: nfs_read_super: get root inode failed
Sep  9 16:28:25 wms kernel: nfs warning: mount version older than kernel
Sep  9 16:28:25 wms kernel: nfs_get_root: getattr error = 116
Sep  9 16:28:25 wms kernel: nfs_read_super: get root inode failed

on the server:

Aug 20 15:35:01 wabash rpc.mountd: authenticated mount request from 
192.168.23.27:864 for /ev/in/statewide-data/drg (/ev/in/statewide-data/drg)
Aug 20 15:35:01 wabash rpc.mountd: authenticated mount request from 
192.168.23.27:868 for /ev/in/statewide-data/drg (/ev/in/statewide-data/drg)

I have been slaving away on this forever now.  Any help would be greatly 
appreciated.

         Dennis Cahillane






-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
