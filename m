Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.bcm.edu ([128.249.224.14]:15596 "EHLO
	iron2.corp.bcm.tmc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755943Ab0IJQ5T convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 12:57:19 -0400
From: "Rao, Mitchell" <mitchelr@bcm.edu>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 10 Sep 2010 11:47:14 -0500
Subject: NFS4 on Ubuntu nobody/nogroup user mapping
Message-ID: <955A7DE8C348B04B8A5F07320E171819F1D8D5756E@EXCMSMBX01.ad.bcm.edu>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I am a junior DBA, who got put in charge of some sysadmin stuff, so forgive me if I have missed anything obvious

So I have a few Ubuntu (Hardy till we can find a replacement for Xen) boxes that I am trying move from nfs3 to nfs4.

I set it up according to this guide: https://help.ubuntu.com/community/SettingUpNFSHowTo

However I ran into trouble when the client see's all users/groups as nobody/nogroup.

The current set up is that all the boxes have synced uids/gids and all users with root access can be trusted. I read some reports that said the only way this could be fixed was by using Kerberos. However I would really prefer not having to move to Kerberos as I have heard that it is very intensive to set up. So what I am looking for here is a solution other than sticking with nfs3 or putting everything on Kerberos. However if you think that Kerberos is easier to set up than I am giving it credit for then that could be useful to hear as well.

Here is all the configuration I could of including at this time:

/etc/default/nfs-kernel-server

# Number of servers to start up
RPCNFSDCOUNT=8

# Runtime priority of server (see nice(1))
RPCNFSDPRIORITY=0

# Options for rpc.mountd.
# If you have a port-based firewall, you might want to set up
# a fixed port here using the --port option. For more information,
# see rpc.mountd(8) or http://wiki.debian.org/?SecuringNFS
RPCMOUNTDOPTS=

# Do you want to start the svcgssd daemon? It is only required for Kerberos
# exports. Valid alternatives are "yes" and "no"; the default is "no".
NEED_SVCGSSD= no

# Options for rpc.svcgssd.
RPCSVCGSSDOPTS=



/etc/default/nfs-common
# If you do not set values for the NEED_ options, they will be attempted
# autodetected; this should be sufficient for most people. Valid alternatives
# for the NEED_ options are "yes" and "no".

# Do you want to start the statd daemon? It is not needed for NFSv4.
NEED_STATD=

# Options for rpc.statd.
# Should rpc.statd listen on a specific port? This is especially useful
# when you have a port-based firewall. To use a fixed port, set this
# this variable to a statd argument like: "--port 4000 --outgoing-port 4001".
# For more information, see rpc.statd(8) or http://wiki.debian.org/?SecuringNF
S
STATDOPTS=

# Do you want to start the idmapd daemon? It is only needed for NFSv4.
NEED_IDMAPD=yes

# Do you want to start the gssd daemon? It is required for Kerberos mounts.
NEED_GSSD=no


/etc/exports


/export 10.16.xx.xx(rw,fsid=0,insecure,no_subtree_check,async)
/export/home 10.16.xx.xx(rw,insecure,no_subtree_check,async)



Oh and rpc.idmapd is running on the client.

I would be happy provide any information that I may have missed, although I may be out of contact on the weekend. Also this is my first time using a public listserv so if I have made an faux pas, I apologize and please let me know so that I wont repeat it.

Thanks,
Mitchell