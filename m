Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:52108 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935661Ab3DPPhM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2013 11:37:12 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS loop on 3.4.39
Date: Tue, 16 Apr 2013 15:36:55 +0000
Message-ID: <1366126613.12556.18.camel@leira.trondhjem.org>
References: <OF6F031A84.8897519B-ONC1257B4E.002D1BA3-C1257B4E.002DBED0@LocalDomain>
	 <OF83CD52DB.8DBE497B-ONC1257B4E.002F8695-C1257B4E.002FBBD0@LocalDomain>
	 <OF64305930.0F7881A0-ONC1257B4E.0030250F-C1257B4E.00306CEC@LocalDomain>
	 <OFA06D4153.317BAF9A-ONC1257B4F.002F597B-C1257B4F.003AC46C@transmode.se>
In-Reply-To: <OFA06D4153.317BAF9A-ONC1257B4F.002F597B-C1257B4F.003AC46C@transmode.se>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-16 at 12:41 +0200, Joakim Tjernlund wrote:
> Here we go again, this time i happened while browsing the Boston news on 
> www.dn.se
> Now gvfsd-metadata is turned off(not running at all) and I get:
> 10:28:44.616146 IP 192.168.201.44.nfs > 172.20.4.10.3671768838: reply ok 
> 52 getattr ERROR: unk 10024

Part of the reason why you are getting no response to these posts is
that you are posting tcpdump-decoded data. Tcpdump still has no support
for NFSv4, and therefore completely garbles the output by trying to
interpret it as NFSv2/v3.
In general, if you are posting network traffic, please record it as
binary raw packet data (using the '-w' option on tcdump) so that we can
look at the full contents. Either include it as an attachment, or
provide us with details on how to download it from an http server.

Other information that is needed in order to make sense of NFS bug
reports includes:

- client OS (non-linux) or kernel version (linux)
- mount options on the client
- server OS (non-linux) or kernel version (linux)
- type of exported filesystem on the server
- contents of /etc/exports on the server

Please ensure that you always include those in your emails.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
