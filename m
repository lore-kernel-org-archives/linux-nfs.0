Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:33945 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975Ab1KDXPK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 19:15:10 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RMSyY-0001Am-2Y
	for linux-nfs@vger.kernel.org; Sat, 05 Nov 2011 00:15:06 +0100
Received: from 184-227-87-136.pools.spcsdns.net ([184.227.87.136])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 05 Nov 2011 00:15:06 +0100
Received: from sumana by 184-227-87-136.pools.spcsdns.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 05 Nov 2011 00:15:06 +0100
To: linux-nfs@vger.kernel.org
From: Sumana Annam <sumana@vigyaan.com>
Subject: NFSV4 and Kerberos ( Failed to create machine krb5 context with any credentials cache for server )
Date: Fri, 4 Nov 2011 23:11:58 +0000 (UTC)
Message-ID: <loom.20111104T233047-797@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Problem description:

Have both NFS Server and NFS Client working on the same RedHat 6.0 ( rhel60sec02
) with kernel version 2.3.32 running on the same box. The redhat server has the
following installed:

Installed:

  nfs-utils.x86_64 1:1.2.2-7.el6       nfs4-acl-tools.x86_64 0:0.3.3-5.el6
  rpcbind.x86_64 0:0.2.0-8.el6

Dependency Installed:

  libevent.x86_64 0:1.4.13-1.el6       libgssglue.x86_64 0:0.1-8.1.el6
  libtirpc.x86_64 0:0.2.1-1.el6        nfs-utils-lib.x86_64 0:1.1.5-1.el6

Machine is joined to the domain and it is defined in DNS as
rhel60sec02.ngdclab.local

Shared directory: /var/share

Mount point: /mnt

Windows is 2008 R2 server with 2008 Domain level.

Followed the instructions from Tom's blog in addition with KB article and set up
exports, fstab on the same box. The upn is set on rhel60sec02 server in AD to
'nfs/rhel60sec02.ngdclab.local@NGDCLAB.LOCAL'. As root, running kinit -k
rhel60sec02$ gets the ticket with RC4 enc type. So NFS Client is working but
when we run the command :

mount -t nfs4 -o sec=krb5 rhel60sec02:/ /var/mnt results in Access denied
generic error message.

Turned on verbose level logging on both rpc.gssd and rpc.svcgssd which brings up
the following error messages:

Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: WARNING: Failed to create krb5
context for user with uid 0 for server rhel60sec02.ngdclab.local
Nov  4 13:01:27 rhel60sec02 rpc.svcgssd[10943]: finished handling null request
Nov  4 13:01:27 rhel60sec02 rpc.svcgssd[10943]: entering poll
Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: WARNING: Failed to create machine
krb5 context with credentials cache FILE:/tmp/krb5cc_machine_NGDCLAB.LOCAL for
server rhel60sec02.ngdclab.local
Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: WARNING: Failed to create machine
krb5 context with any credentials cache for server rhel60sec02.ngdclab.local
Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: doing error downcall
Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: destroying client
/var/lib/nfs/rpc_pipefs/nfs/clnt55
Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: destroying client
/var/lib/nfs/rpc_pipefs/nfs/clnt54

No matter what we do, we are unable to get past the above error. 

Appreciate any help.
Sumana

