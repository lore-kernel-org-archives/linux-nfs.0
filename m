Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53950 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757362Ab3LWRkC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Dec 2013 12:40:02 -0500
Date: Mon, 23 Dec 2013 12:39:56 -0500
To: Gareth Williams <gareth@garethwilliams.me.uk>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Question ref Running NFS at V4 Only
Message-ID: <20131223173956.GA9221@fieldses.org>
References: <52B47A12.2070202@garethwilliams.me.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52B47A12.2070202@garethwilliams.me.uk>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 20, 2013 at 05:10:42PM +0000, Gareth Williams wrote:
> Hi,
> 
> I'm trying to run NFS with protocol version 4 only (that is, with v2
> & v3 disabled) on a CentOS 6.5 install running as a KVM guest.
> 
> The RedHat documentation (amongst others) states that rpcbind isn't
> needed with v4, but if I start nfs without rpcbind I get errors.

I suspect the kernel code needs to be fixed to not attempt to register
with rpcbind n the v4-only case.  (Or to attempt to register but ignore
any error, I'm not sure which is best.)

And this may not be the only issue in the v4-only case.  This isn't
really a priority for me right now, but I'd happily look at patches.

--b.

> 
> I've spent a couple of days (on and off) on Google trying to get an
> answer and have posted on the CentOS forum, but the nearest I can
> find  is an archive on this mailing list from over two years ago
> (and it's not identical):-
> 
> http://www.spinics.net/lists/linux-nfs/msg16907.html
> 
> In /etc/sysconfig/nfs I have:-
> 
> MOUNTD_NFS_V2="no"
> MOUNTD_NFS_V3="no"
> 
> RPCNFSDARGS="-N 2 -N 3"
> 
> When I attempt to start NFS either using the init scripts  or
> manually with:-
> 
> rpc.nfsd -N 2 -N 3
> 
> I get:-
> 
> rpc.nfsd: writing fd to kernel failed: errno 111 (Connection refused)
> rpc.nfsd: unable to set any sockets for nfsd
> 
> The mailing list archive's answer was that the kernel was too old,
> so I installed 3.10.24 from elrepo but the symptom doesn't change.
> 
> If I start rpcbind, then everything works, but as far as I can see,
> I shouldn't have to do that unless I'm supporting v2 & v3.
> 
> Finally, please accept my apologies for wasting your time if I've
> missed something obvious.
> 
> Kind regards,
> 
> Gareth
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
