Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.cdf.toronto.edu ([128.100.31.106]:43949 "HELO
	smtp.cdf.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759327Ab3BTVZL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2013 16:25:11 -0500
Message-ID: <51253F36.40501@cdf.toronto.edu>
Date: Wed, 20 Feb 2013 16:25:10 -0500
From: Iordan Iordanov <iordan@cdf.toronto.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: NFS v3 hangs with kernel version v3.2.0, 32-bit
References: <511BFB74.3060803@cdf.toronto.edu>
In-Reply-To: <511BFB74.3060803@cdf.toronto.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I've put the broken server back into production (we need the capacity), 
however, we are open to enabling whatever RPC/NFS debugging would help 
to get to the source of this problem. Can anybody suggest which kernel 
parameters would be most beneficial to determining the cause of the 
problem? I am talking about one of these, or something else which I'm 
not aware of:

sunrpc.rpc_debug
sunrpc.nfs_debug
sunrpc.nfsd_debug
sunrpc.nlm_debug

If somebody suggests any options to be enabled, can you also comment on 
whether there would be any performance hit related to enabling the option?

Thanks!
Iordan Iordanov


On 02/13/13 15:45, Iordan Iordanov wrote:
> Hello!
>
> We've been suffering from NFS mounts and data transfers hanging on our
> Ubuntu Precise 12.04 32-bit shared servers since last summer. The
> problem has reoccurred over TCP and UDP.
>
> Every month or so, some of our more heavily used shared servers would
> see its NFS mounts hang, and a bunch of flush-(major:minor) processes
> would sit at 100% in top. If the hang occurred while NFS over TCP was
> being used, mounting over UDP would still work, but mounting over TCP
> would hang (indefinitely). The reverse is also true. When we experienced
> the hang while using UDP, mounts over TCP would work on the affected
> system.
>
> I've located a very similar discussion/bug-report for v3.1-rc4 which
> ended seemingly without a resolution here:
> http://lkml.indiana.edu/hypermail/linux/kernel/1109.1/00728.html
>
> We're also seeing the:
>
> [3121466.072728] RPC: 43506 failed to lock transport e030a000
>
> errors when RPC debugging is enabled. In addition, we're also seeing the
> socket in CLOSE_WAIT state symptom in netstat's output:
>
> tcp 0 0 x.x.x.x:967 y.y.y.y:2049     CLOSE_WAIT
>
> Running tcpdump on our file-server and specifying the hung host in
> question results in NO NFS-related traffic unless a mount request is
> executed on the nfs client. I've attached two tcpdumps representing a
> successful mount over UDP and an unsuccessful mount over TCP in case
> they are useful. The tcpdumps were captured on the fileserver.
>
> The machine in question is currently in this hung state, and we would be
> happy to provide any additional information you may need!
>
> Here is the result of uname -a on the hung machine:
>
> Linux gambo 3.2.0-35-generic-pae #55-Ubuntu SMP Wed Dec 5 18:04:39 UTC
> 2012 i686 athlon i386 GNU/Linux
>
> Our NFS server is an up-to-date Debian Squeeze 6.0 box, and we would be
> happy to provide information on that machine if you think it is relevant.
>
> Any help in resolving this would be greatly appreciated, as we are
> constantly suffering from this issue.
>
> Many thanks in advance!
> Iordan
