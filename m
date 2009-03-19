From: Steve Dickson <SteveD@redhat.com>
Subject: The next step: nfsvers=4
Date: Thu, 19 Mar 2009 12:18:23 -0400
Message-ID: <49C2704F.5050303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35871 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbZCSQVI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2009 12:21:08 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n2JGL7We026720
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2009 12:21:07 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n2JGL4Fi013920
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2009 12:21:05 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-58.bos.redhat.com [10.16.10.58])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n2JGL5Sl013250
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2009 12:21:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As I see it, the next step to seamlessly move to V4 as 
the default is to make 'mount -o nfsvers=4' actually 
do a v4 mount... 

There are two obvious place we can make this change.
In the kernel and/or in the mount command... 

Looking at the kernel, since v3 and v4 truly two different
file systems its seems a bit late for the nfs_get_sb()
to all of sudden have to change file system type. Meaning
when nfs_get_sb() sees the "nfsvers=4" somehow it would
have to back out and call nfs4_get_sb(), which obviously 
is a bit hacky.... 

Now I guess we could have one nfs_get_sb() for both v3 and v4.
Where the nfs_get_sb() could peek into the options data to
see which version is needed. This would also mean the mount 
command would always have to set a version so when the "nfsvers=" 
options is not set, the kernel would know which version to use.
Again, this feels a bit hacky as well but doable... 

At least to me, what seems like the best option is to have 
the mount.nfs binary early on intercept "nfsvers=4" option
and then change the fs_type to "nfs4", which would allow
everything to "trickle down" as it does today... Again to
me, that seem like the least intrusive way to do it...

Comments? Is there other ways?

steved.

 
