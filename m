From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS problem on Microblaze LE
Date: Wed, 2 Mar 2011 10:49:00 -0500
Message-ID: <20110302154900.GA29136@fieldses.org>
References: <4D6E4052.7050201@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959Ab1CBPtH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 10:49:07 -0500
In-Reply-To: <4D6E4052.7050201-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 02, 2011 at 02:04:18PM +0100, Michal Simek wrote:
> Hi,
> 
> I am getting some troubles to get nfs work on new Microblaze
> little-endian platform and I would like to ask you for some
> recommendations how to debug it.
> 
> First of all I need to write that Microblaze big-endian platforms have no problem.
> The problem only happen if I use mount without -o nolock option
> (mount -t nfs 192.168.0.101:/tftpboot/nfs /mnt)
> If I use -o nolock option I have no problem to use nfs.
> 
> I use xilinx emaclite and axi emac(it is not in the mainline now)
> driver and I have no problem to use dhcp, ftp, http, telnet and
> other internet protocols.
> 
> I compared debug logs on big and little endian platform(rootfs has
> the same setting) I found that little-endian got packet which is
> shorter than on big endian which I have added to the log below.
> The second thing, which I think is connected to the previous point,
> is that I am getting BADCRED in rpc_verify_headers.
> 
> Is there any option/macro/recommended debug technique how to see
> packets? I need to get some clue how to see packet and then how they
> are passed to rpc_verify_header function.

A good first step would be to look at the network traffic with
wireshark.

--b.
