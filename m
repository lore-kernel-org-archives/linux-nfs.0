From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problem with NFS and XEN
Date: Fri, 08 May 2009 08:24:01 -0400
Message-ID: <1241785441.19651.28.camel@heimdal.trondhjem.org>
References: <c4838b6b0905072310g5658ed91i486797b76c8d95d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Roger Marcus <roger.marcus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37569 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbZEHMYG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2009 08:24:06 -0400
In-Reply-To: <c4838b6b0905072310g5658ed91i486797b76c8d95d3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-08 at 08:10 +0200, Roger Marcus wrote:
> Hi,
> 
> I am having a problem with NFS and I thought that you could help me or
> you could steer me to
> someone who might be able to.
> 
> The problem is this:
> 
> An NFS Server mounts an image on a local directory, containing a XEN
> virtual machine configuration file and a XEN image.
> 
> An NFS Client computer sees the directory that was mounted remotely
> and starts the XEN Virtual machine on the mounted directory.
> The NFS Client computer then stops the XEN Virtual machine. So far, so
> good. The machine ran. It stopped. The NFS Client
> leaves the directory. No process is accessing that directory from the
> client side.

It is still exported, so the NFS server still has a reference to it.

> Problem: The NFS Server cannot umount the local directory.
> fuser returns no usage of the directory.
> lsof returns no usage of the directory.

correction: lsof and fuser don't show any _user processes_ that
reference the directory. NFSd runs in the kernel...

> umount -f won't force umount the directory.
> 
> What does work is exportfs -ua.

or 'exportfs -u client:/directory'. See 'man exportfs'

> This is not a good way to go, since it is planned that many clients
> will be using the server; indeed many
> clients will be using multiple subdirectories on the server.
> 
> 1. Is this a XEN bug or an NFS bug?
> 2. Is there some other command like exportfs in which you can just
> disable the one local directory but maintain an
> active mount on the parent directory?

See above.

Note that if you want to unexport all export entries for a particular
directory '/mydir', then something like this simple script will do it:

exportfs -u $(exportfs | awk '/^\/mydir/ { print $2 ":" $1; }')

Trond

