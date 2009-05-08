From: Roger Marcus <roger.marcus@gmail.com>
Subject: Problem with NFS and XEN
Date: Fri, 8 May 2009 08:10:50 +0200
Message-ID: <c4838b6b0905072310g5658ed91i486797b76c8d95d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:43430 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbZEHGKv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2009 02:10:51 -0400
Received: by fxm2 with SMTP id 2so1191512fxm.37
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2009 23:10:50 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am having a problem with NFS and I thought that you could help me or
you could steer me to
someone who might be able to.

The problem is this:

An NFS Server mounts an image on a local directory, containing a XEN
virtual machine configuration file and a XEN image.

An NFS Client computer sees the directory that was mounted remotely
and starts the XEN Virtual machine on the mounted directory.
The NFS Client computer then stops the XEN Virtual machine. So far, so
good. The machine ran. It stopped. The NFS Client
leaves the directory. No process is accessing that directory from the
client side.

Problem: The NFS Server cannot umount the local directory.
fuser returns no usage of the directory.
lsof returns no usage of the directory.
umount -f won't force umount the directory.

What does work is exportfs -ua.

This is not a good way to go, since it is planned that many clients
will be using the server; indeed many
clients will be using multiple subdirectories on the server.

1. Is this a XEN bug or an NFS bug?
2. Is there some other command like exportfs in which you can just
disable the one local directory but maintain an
active mount on the parent directory?

exports:
/adir =A0=A0=A0 192.168.11.129(rw,sync,no_subtree_check,crossmnt,no_roo=
t_squash)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
/adir/image.iso (contains xen vm stuff)
server executes: mount -o loop /adir/image.iso /adir/virtualstuff

client mounts adir with mount -t nfs 192.168.11.22:/adir /adir
xm create /adir/virtualstuff/config.cfg
xm destroy virtual

on the nfs-server:
umount /adir/virtualstuff (won't)

only exportfs -ua works, but this defeats my purpose.

Can you suggest anything?

thanks in advance,

Roger Marcus
