Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:37248 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379Ab3JVRJs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 13:09:48 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r9MH9lpP027989
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 22 Oct 2013 10:09:48 -0700
Message-ID: <5266B15B.4020804@candelatech.com>
Date: Tue, 22 Oct 2013 10:09:47 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Failure to mount nfsv4 on 3.12.0-rc5-wl+
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is on an un-hacked upstream kernel (ath tree).  Mounting an older
Fedora 13 system with nfsv3 works fine, but mounting a F17 box with
NFSv4 hangs.  Ctrl-c of the process yields this error:

NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO

3.9 kernels on this same system mount the F17 box fine.

If I add 'vers=3' to /etc/fstab, then it mounts the F17 box fine.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

