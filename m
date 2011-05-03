Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:36087 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299Ab1ECOir convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 10:38:47 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id p43EcihZ000878
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 3 May 2011 14:38:45 GMT
Subject: Re: messages on restarting NFS
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <348580.13472.qm@web111713.mail.gq1.yahoo.com>
Date: Tue, 3 May 2011 10:38:39 -0400
Cc: nfs <linux-nfs@vger.kernel.org>
Message-Id: <C0899C69-1BB1-45A4-BD90-418A50980F62@oracle.com>
References: <348580.13472.qm@web111713.mail.gq1.yahoo.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 3, 2011, at 5:30 AM, Mahmood Naderan wrote:

> Hi,
> When I restart NFS with 
> 
> 
> /etc/init.d/nfs-kernel-server restart
> 
> 
> I see these messages in syslog:
> 
> May  3 13:57:15 server mountd[928]: Caught signal 15, un-registering and exiting.
> May  3 13:57:15 serverkernel: [82562.372930] nfsd: last server has exited, flushing export cache
> May  3 13:57:16 serverkernel: [82563.499249] svc: failed to register lockdv1 RPC service (errno 97).
> May  3 13:57:16 serverkernel: [82563.501211] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> May  3 13:57:16 serverkernel: [82563.501246] NFSD: starting 90-second grace period
> 
>  
> How can I fix that failure?

IIRC, that usually means the kernel has attempted to register an IPv6 listener with the local portmapper, which doesn't support IPv6.  The message was removed in a later kernel.

To be sure it's harmless, after NFSD is running, verify that lockd is registered by running "rpcinfo -p" on your server.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




