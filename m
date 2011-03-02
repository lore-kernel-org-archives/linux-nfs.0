Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52961 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859Ab1CBRem (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 12:34:42 -0500
Date: Wed, 2 Mar 2011 12:34:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michal Simek <monstr@monstr.eu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: NFS problem on Microblaze LE
Message-ID: <20110302173438.GC29136@fieldses.org>
References: <4D6E4052.7050201@monstr.eu>
 <20110302154900.GA29136@fieldses.org>
 <4D6E6C49.90309@monstr.eu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D6E6C49.90309@monstr.eu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 02, 2011 at 05:11:53PM +0100, Michal Simek wrote:
> J. Bruce Fields wrote:
> >On Wed, Mar 02, 2011 at 02:04:18PM +0100, Michal Simek wrote:
> >>Hi,
> >>
> >>I am getting some troubles to get nfs work on new Microblaze
> >>little-endian platform and I would like to ask you for some
> >>recommendations how to debug it.
> >>
> >>First of all I need to write that Microblaze big-endian platforms have no problem.
> >>The problem only happen if I use mount without -o nolock option
> >>(mount -t nfs 192.168.0.101:/tftpboot/nfs /mnt)
> >>If I use -o nolock option I have no problem to use nfs.
> >>
> >>I use xilinx emaclite and axi emac(it is not in the mainline now)
> >>driver and I have no problem to use dhcp, ftp, http, telnet and
> >>other internet protocols.
> >>
> >>I compared debug logs on big and little endian platform(rootfs has
> >>the same setting) I found that little-endian got packet which is
> >>shorter than on big endian which I have added to the log below.
> >>The second thing, which I think is connected to the previous point,
> >>is that I am getting BADCRED in rpc_verify_headers.
> >>
> >>Is there any option/macro/recommended debug technique how to see
> >>packets? I need to get some clue how to see packet and then how they
> >>are passed to rpc_verify_header function.
> >
> >A good first step would be to look at the network traffic with
> >wireshark.
> 
> Yes, I am looking at it all the time but I can't see anything weird.
> Look at attachment. 192.168.0.101 - host, 192.168.0.103 target.
> 
> There are two NULL calls and two reply calls.

Yes, looks normal.  I wonder why everything exept portmap is using udp,
but your debugging traces refer to tcp?

Oh, wait, it's talking about portmap map/unmap calls: could try try
running wireshark on the loopback interface?  (run with -ilo).

--b.

> There should different packet sent from
> target to host.
