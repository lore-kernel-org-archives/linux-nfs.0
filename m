Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43847 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756705Ab2JZRPv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 13:15:51 -0400
Date: Fri, 26 Oct 2012 13:15:49 -0400
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121026171549.GA11806@fieldses.org>
References: <k6ebva$1kf$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <k6ebva$1kf$1@ultimate100.geggus.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 26, 2012 at 03:58:34PM +0000, Sven Geggus wrote:
> Hello,
> 
> after updating the kernel of my NFS4-Server (because of 3.5.x EOL) I ended
> up with NFS4 stopped working.
> 
> Kernel config is more or less the same as with 3.5.7, as I used "make
> oldconfig". The only new stuff in the NFS area seems to be swap over NFS
> which is disabled.
> 
> So starting from a working setup with 3.5.7 on the server (client uses
> kernel 3.6.3) NFS4 stops working after upgrading the server to 3.6.3.
> 
> What happens is that mounting seems to hang infinitely when trying to mount
> the server using the following command:
> mount -v -t nfs4 -o sec=krb5 <server>:/<dir> /mnt/

Could I see a network trace?

	tcpdump -s0 -wtmp.pcap 'host <myclient> && host <myserver>'

then try the mount, then kill tcpdump and send me a copy of tmp.pcap.

--b.

> 
> However everything works fine again when the server has been rebooted into kernel
> 3.5.7.
> 
> Here is the relevant part of .config:
> CONFIG_NETWORK_FILESYSTEMS=y
> CONFIG_NFS_FS=m
> CONFIG_NFS_V2=m
> CONFIG_NFS_V3=m
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=m
> # CONFIG_NFS_SWAP is not set
> # CONFIG_NFS_V4_1 is not set
> # CONFIG_NFS_USE_LEGACY_DNS is not set
> CONFIG_NFS_USE_KERNEL_DNS=y
> CONFIG_NFS_DEBUG=y
> CONFIG_NFSD=y
> CONFIG_NFSD_V2_ACL=y
> CONFIG_NFSD_V3=y
> CONFIG_NFSD_V3_ACL=y
> CONFIG_NFSD_V4=y
> # CONFIG_NFSD_FAULT_INJECTION is not set
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_ACL_SUPPORT=y
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=y
> CONFIG_SUNRPC_GSS=y
> CONFIG_RPCSEC_GSS_KRB5=y
> CONFIG_SUNRPC_DEBUG=y
> 
> 
> Sven
> 
> P.S.: The system is using nfs-utils 1.2.6 on debian wheezy if this should be
> relevant.
> 
> -- 
> "Those who do not understand Unix are condemned to reinvent it, poorly"
> (Henry Spencer)
> 
> /me is giggls@ircnet, http://sven.gegg.us/ on the Web
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
