From: Ben Greear <greearb@candelatech.com>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Mon, 20 Jul 2009 16:02:23 -0700
Message-ID: <4A64F77F.6090803@candelatech.com>
References: <4A64E4FD.9080902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49494 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbZGTXCX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2009 19:02:23 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n6KN2NQd019008
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2009 16:02:23 -0700
In-Reply-To: <4A64E4FD.9080902@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/20/2009 02:43 PM, Ben Greear wrote:
> I tried mounting an NFS server running FC8 (2.6.26.8-57.fc8 kernel)
> using a Fedora 11 system running an un-patched 2.6.31-rc3 64-bit kernel.

Ok, seems you have to have things mis-configured to reproduce this:

I had my /etc/exports looking like this on the file-server:

/export/tmp 192.168.100.0/24(rw)


When I changed it to be:
/export/tmp 192.168.100.0/24(rw,fsid=0)


And mounted 192.168.100.6:/ instead of 192.168.100.6:/export/tmp
then it mounts properly and appears to work just fine.

If I leave file-server configured properly with fsid=0, but try
to mount 192.168.100.6:/export/tmp then I get an error about
no such file or directory, which also appears to be correct
behaviour.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

