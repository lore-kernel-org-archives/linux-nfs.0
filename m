From: Juha <juhis@trinity.is-a-geek.com>
Subject: NFS volumes don't mount at client boot-up
Date: Sat, 23 Aug 2003 13:13:35 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1061633615.986.21.camel@client.veehoo.net>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cs128098.pp.htv.fi
	([213.243.128.98] helo=trinity.is-a-geek.com ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qVOd-0005Ha-00
	for <nfs@lists.sourceforge.net>; Sat, 23 Aug 2003 03:13:23 -0700
Received: from server.veehoo.net (client.veehoo.net [192.168.0.10])
	by trinity.is-a-geek.com (Postfix) with ESMTP id E94EC3F216
	for <nfs@lists.sourceforge.net>; Sat, 23 Aug 2003 13:35:43 +0300 (EEST)
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

Hi list,

A new problem with nfs has just emerged on my setup between two linux
machines (nfs sever is a debian testing, client a redhat 9). I have two
volumes on the server that I wan't to share, lets call them /mnt/foo and
/mnt/bar. When I boot the client machine, the nfs shares won't get
mounted, instead I get an error like this:

Aug 23 12:21:53 client mount: mount: RPC: Unable to receive; errno =
Connection refused
Aug 23 12:21:53 client mount: mount: RPC: Unable to receive; errno =
Connection refused
Aug 23 12:21:53 client netfs: Mounting NFS filesystems:  failed

But then if I restart the nfs server on the 'server' machine and then do
a mount on the 'client' machine, I get *one* of the shares to mount. And
if I repeat this procedure, I get the other share to mount. In other
words, if I do

server:# /etc/init.d/nfs-kernel-server restart
client:# mount -a
mount: RPC: Unable to receive; errno = Connection refused

server# /etc/init.d/nfs-kernel-server restart
client# mount -a

I get both of the shares to mount. I haven't changed my config files but
the setup used to work, I don't know what happened. If I reboot the
'server' machine while the client is running, the shares get mounted
without problems. This is my configuration:

'server': /etc/exports
/mnt/foo            client(rw,nohide,async)
/mnt/bar            client(rw,nohide,async)

'client': /ets/fstab
server:/mnt/foo  /mnt/foo  nfs  rw,hard,intr,rsize=8192,wsize=8192
server:/mnt/bar  /mnt/bar  nfs  rw,hard,intr,rsize=8192,wsize=8192

Does anybody have ideas what could be happening? What would be the
correct way to start debugging where the problem lies? I'm totally
clueless here, any help appreciated.

Thanks in advance,

Juhis




-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
