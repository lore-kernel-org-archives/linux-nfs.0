From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: exporting subdirectory of shared filesystem to different hosts
Date: Mon, 15 Jun 2009 18:49:21 -0400
Message-ID: <20090615224921.GA17917@fieldses.org>
References: <20090614175325.GA10466@TechFak.Uni-Bielefeld.DE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Sascha Frey <sfrey-15KJMqYlBKyzX87ganJRvOIeGoz/g4FR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35080 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758795AbZFOWtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 18:49:20 -0400
In-Reply-To: <20090614175325.GA10466-15KJMqYlBKyzX87ganJRvOIeGoz/g4FR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 14, 2009 at 07:53:25PM +0200, Sascha Frey wrote:
> Hi,
> 
> we have some Linux NFS servers distributing our users' homes to our
> clients.
> 
> We are using NIS netgroups to restrict access to certain NFS shares.
> Our /etc/exports file looks like this:
> /var/lib/nfs/v4root \
>         *(ro,fsid=0,insecure,no_subtree_check)
> /export/homes \
>         -rw,async,insecure,no_subtree_check @netgroupA
> /var/lib/nfs/v4root/export/homes \
>         -rw,async,insecure,nohide,no_subtree_check @netgroupA
> 
> (/export/homes is bind-mounted to /var/lib/nfs/v4root/export/homes to
> have the same path for NFSv3 and v4 exports.)
> 
> Now we need to export some of the home directories to an additional
> group of hosts. So we added two lines for each one of these 'special
> cases' to the exports file:
> 
> /export/homes/usera \
>         -rw,async,insecure,no_subtree_check @netgroupA @netgroupB
> /var/lib/nfs/v4root/export/homes/usera \
>         -rw,async,insecure,nohide,no_subtree_check @netgroupA @netgroupB
> 
> Our Problem:
> Hosts, which are member of netgroupB, are unable to mount
> server:/export/homes/usera, if using NFSv4:
> client:~# mount -t nfs4 server:/export/homes/usera /mnt
> mount.nfs4: mounting server:/export/homes/usera failed, reason given by
> server:
>   No such file or directory
> 
> NFSv3 mount works (-t nfs)...
> 
> We can't export the whole homes-tree to netgroupB. Adding entries in
> /etc/exports isn't a good idea either (we have more than 2000 home
> directories).
> 
> 
> Is there any chance to get this working without setting up export
> entries for each single home directory?

Exports really only work well on a whole-filesystem basis.  The server
is not good at distinguishing between different subtrees of the same
filesystem.

Note also: in the above situation, a malicious user in netgroupB can
probably access anything in /export/homes.  You can fix that by changing
no_subtree_check to subtree_check, but that may cause unexpected stale
filehandle errors on renaming files (because it causes the filehandle of
a file to change depending on which directory it is contained in).

--b.
