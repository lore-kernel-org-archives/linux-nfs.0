From: Sascha Frey <sfrey-15KJMqYlBKyzX87ganJRvOIeGoz/g4FR@public.gmane.org>
Subject: exporting subdirectory of shared filesystem to different hosts
Date: Sun, 14 Jun 2009 19:53:25 +0200
Message-ID: <20090614175325.GA10466@TechFak.Uni-Bielefeld.DE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smarthost.piip.TechFak.Uni-Bielefeld.DE ([129.70.137.17]:54694
	"EHLO smarthost.TechFak.Uni-Bielefeld.DE" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751764AbZFNSBc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Jun 2009 14:01:32 -0400
Received: from vesuv.localdomain (vesuv.TechFak.Uni-Bielefeld.DE [129.70.137.28])
	by smarthost.TechFak.Uni-Bielefeld.DE (Postfix) with ESMTP id 904FE4829A
	for <linux-nfs@vger.kernel.org>; Sun, 14 Jun 2009 19:53:25 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we have some Linux NFS servers distributing our users' homes to our
clients.

We are using NIS netgroups to restrict access to certain NFS shares.
Our /etc/exports file looks like this:
/var/lib/nfs/v4root \
        *(ro,fsid=0,insecure,no_subtree_check)
/export/homes \
        -rw,async,insecure,no_subtree_check @netgroupA
/var/lib/nfs/v4root/export/homes \
        -rw,async,insecure,nohide,no_subtree_check @netgroupA

(/export/homes is bind-mounted to /var/lib/nfs/v4root/export/homes to
have the same path for NFSv3 and v4 exports.)

Now we need to export some of the home directories to an additional
group of hosts. So we added two lines for each one of these 'special
cases' to the exports file:

/export/homes/usera \
        -rw,async,insecure,no_subtree_check @netgroupA @netgroupB
/var/lib/nfs/v4root/export/homes/usera \
        -rw,async,insecure,nohide,no_subtree_check @netgroupA @netgroupB

Our Problem:
Hosts, which are member of netgroupB, are unable to mount
server:/export/homes/usera, if using NFSv4:
client:~# mount -t nfs4 server:/export/homes/usera /mnt
mount.nfs4: mounting server:/export/homes/usera failed, reason given by
server:
  No such file or directory

NFSv3 mount works (-t nfs)...

We can't export the whole homes-tree to netgroupB. Adding entries in
/etc/exports isn't a good idea either (we have more than 2000 home
directories).


Is there any chance to get this working without setting up export
entries for each single home directory?




Thanks,
Sascha

