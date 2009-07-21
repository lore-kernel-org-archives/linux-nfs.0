From: Ben Greear <greearb@candelatech.com>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 09:49:08 -0700
Message-ID: <4A65F184.5060802@candelatech.com>
References: <4A64EB1F.4000602@candelatech.com> <1248178527.5222.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37899 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbZGUQtM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2009 12:49:12 -0400
In-Reply-To: <1248178527.5222.0.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/21/2009 05:15 AM, Trond Myklebust wrote:

>
> What does /var/lib/nfs/v4recovery look like on the server?

The server was misconfigured, but I still think the client should
behave better in this case.  If you cannot reproduce it, let me know
and I can try to be more specific.  If you still want the v4recovery
information, let me know and I'll send it.


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

