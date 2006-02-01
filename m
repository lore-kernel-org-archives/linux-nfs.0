From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [BUG] nfs version 2 broken
Date: Wed, 01 Feb 2006 01:15:19 -0500
Message-ID: <1138774519.7861.4.camel@lade.trondhjem.org>
References: <43E05031.2000107@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030389AbWBAGPc@vger.kernel.org>
To: Knut Petersen <Knut_Petersen@t-online.de>
In-Reply-To: <43E05031.2000107@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-02-01 at 07:07 +0100, Knut Petersen wrote:
> Hi everybody,
> 
> The good news is that I finally succeeded to boot over network
> using the PXE-bootrom / ip dhcp autoconfig / nfsroot method.
> But "ip=dhcp root=/dev/nfs nfsroot=%s" is not the way to go
> with recent kernels. This results in a kernel panic caused by
> the inability to find root. Things go wrong immediately after
> rpc port lookup:
> 
>  > NFS: Buggy server - nlink == 0!
>  > nfs_fhget failed

What kind of server is this that you are using? The above message
basically means that it is handing out inodes with a link count of 0.

Cheers,
  Trond
