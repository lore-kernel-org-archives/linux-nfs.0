Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:52400 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab3JVPy6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 11:54:58 -0400
Message-ID: <52669FBF.9040808@candelatech.com>
Date: Tue, 22 Oct 2013 08:54:39 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Michael Richardson <mcr@sandelman.ca>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
References: <52659D69.1020609@candelatech.com> <357.1382451554@obiwan.sandelman.ca>
In-Reply-To: <357.1382451554@obiwan.sandelman.ca>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/22/2013 07:19 AM, Michael Richardson wrote:
> Ben Greear <greearb@candelatech.com> wrote:
>     > From my own app's logs:
> 
>     > # mount -t nfs [4001:1::1:1]:/vol/vol1 /mnt/lf/RDnfse11c0 -o
>     > srcaddr=4001:1::1:201,vers=3 # requested NFS version or transport
>     > protocol is not supported
> 
>     > When this problem happens, I do not see any network traffic when trying
>     > to mount.
> 
> That sounds like the error that one would get when *mount* was compiled with
> the v6-incompatible sunrpc library rather than tirpc.

It works sometimes on the problem system, and it always (so far) works in our lab.
We tried NFSv3 over IPv4, NFSv4 over IPv4, NFSv3 over IPv6 and NFSv4 over IPv6.
We are using the standard 'mount' that comes with the OS (Fedora 14, in this case),
but we are re-compiling the mount.nfs binary, so perhaps there is still some
problem in how we compile it...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

