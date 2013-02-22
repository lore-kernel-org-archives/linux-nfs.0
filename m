Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50077 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755834Ab3BVPB6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 10:01:58 -0500
Date: Fri, 22 Feb 2013 10:01:58 -0500
To: Iordan Iordanov <iordan@cdf.toronto.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS v3 hangs with kernel version v3.2.0, 32-bit
Message-ID: <20130222150158.GB20588@fieldses.org>
References: <511BFB74.3060803@cdf.toronto.edu>
 <51253F36.40501@cdf.toronto.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51253F36.40501@cdf.toronto.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 20, 2013 at 04:25:10PM -0500, Iordan Iordanov wrote:
> I've put the broken server back into production (we need the
> capacity), however, we are open to enabling whatever RPC/NFS
> debugging would help to get to the source of this problem. Can
> anybody suggest which kernel parameters would be most beneficial to
> determining the cause of the problem? I am talking about one of
> these, or something else which I'm not aware of:
> 
> sunrpc.rpc_debug
> sunrpc.nfs_debug
> sunrpc.nfsd_debug
> sunrpc.nlm_debug
> 
> If somebody suggests any options to be enabled, can you also comment
> on whether there would be any performance hit related to enabling
> the option?

Some of that debugging is extremely verbose, yes.

Since this list is for upstream (not ubuntu) development, most useful
would probably be if you could work out whether the problem is
reproduceable on the latest upstream kernel.

--b.

> 
> Thanks!
> Iordan Iordanov
> 
> 
> On 02/13/13 15:45, Iordan Iordanov wrote:
> >Hello!
> >
> >We've been suffering from NFS mounts and data transfers hanging on our
> >Ubuntu Precise 12.04 32-bit shared servers since last summer. The
> >problem has reoccurred over TCP and UDP.
> >
> >Every month or so, some of our more heavily used shared servers would
> >see its NFS mounts hang, and a bunch of flush-(major:minor) processes
> >would sit at 100% in top. If the hang occurred while NFS over TCP was
> >being used, mounting over UDP would still work, but mounting over TCP
> >would hang (indefinitely). The reverse is also true. When we experienced
> >the hang while using UDP, mounts over TCP would work on the affected
> >system.
> >
> >I've located a very similar discussion/bug-report for v3.1-rc4 which
> >ended seemingly without a resolution here:
> >http://lkml.indiana.edu/hypermail/linux/kernel/1109.1/00728.html
> >
> >We're also seeing the:
> >
> >[3121466.072728] RPC: 43506 failed to lock transport e030a000
> >
> >errors when RPC debugging is enabled. In addition, we're also seeing the
> >socket in CLOSE_WAIT state symptom in netstat's output:
> >
> >tcp 0 0 x.x.x.x:967 y.y.y.y:2049     CLOSE_WAIT
> >
> >Running tcpdump on our file-server and specifying the hung host in
> >question results in NO NFS-related traffic unless a mount request is
> >executed on the nfs client. I've attached two tcpdumps representing a
> >successful mount over UDP and an unsuccessful mount over TCP in case
> >they are useful. The tcpdumps were captured on the fileserver.
> >
> >The machine in question is currently in this hung state, and we would be
> >happy to provide any additional information you may need!
> >
> >Here is the result of uname -a on the hung machine:
> >
> >Linux gambo 3.2.0-35-generic-pae #55-Ubuntu SMP Wed Dec 5 18:04:39 UTC
> >2012 i686 athlon i386 GNU/Linux
> >
> >Our NFS server is an up-to-date Debian Squeeze 6.0 box, and we would be
> >happy to provide information on that machine if you think it is relevant.
> >
> >Any help in resolving this would be greatly appreciated, as we are
> >constantly suffering from this issue.
> >
> >Many thanks in advance!
> >Iordan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
