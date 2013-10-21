Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:36719 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab3JUVc0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 17:32:26 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r9LLWPL7024239
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 14:32:25 -0700
Message-ID: <52659D69.1020609@candelatech.com>
Date: Mon, 21 Oct 2013 14:32:25 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So, the problem I reported earlier with failing to unmount was fixed
by the back-ported patch.

Now, another problem is reported by my user.  In this case, they are
trying to mount an IPv6 NFS server using NFSv3.  Kernel is 3.9.11+,
with patches to support binding mount points to local IP (v4/v6) addresses.

Some NFS over IPv6 mounts work fine, but some do not.  A reboot of the
NFS client machine did not fix the problem.

I have tried to reproduce the problem locally, but so far everything works fine
for us.

>From my own app's logs:

# mount -t nfs [4001:1::1:1]:/vol/vol1 /mnt/lf/RDnfse11c0 -o srcaddr=4001:1::1:201,vers=3
# requested NFS version or transport protocol is not supported

When this problem happens, I do not see any network traffic when trying to mount.


I am curious if anyone else has seen errors similar to this?


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

