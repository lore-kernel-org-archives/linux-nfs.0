From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Sun, 22 Feb 2009 15:41:34 -0800
Message-ID: <1235346094.7331.111.camel@heimdal.trondhjem.org>
References: <4977C580.4040805@candelatech.com>
	 <633CA802-DD5A-4082-B771-C524D367241F@oracle.com>
	 <497805A7.4070205@candelatech.com>
	 <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com>
	 <4978AD75.9090900@candelatech.com>
	 <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com>
	 <499FB08B.1070200@candelatech.com>
	 <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>
	 <49A0E802.9000209@candelatech.com>
	 <1235329791.7331.75.camel@heimdal.trondhjem.org>
	 <49A1DD24.9060801@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48397 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754069AbZBVXll (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2009 18:41:41 -0500
In-Reply-To: <49A1DD24.9060801@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-02-22 at 15:17 -0800, Ben Greear wrote:
> My specific application is a testing tool that emulates 1000+ unique NFS 
> clients,
> primarily for testing  & loading NFS servers.
> I put each client on a mac-vlan and put them all on the same subnet so 
> that I don't
> need any routers between my box and the nfs server.  (We can also put
> them on different subnets and use different routers, and the specific 
> source-ip
> also helps there...)
> 
> I use routing tricks to enforce that a particular source-IP uses a 
> specific routing
> table, and that ties pkts to a specific mac-vlan interface.  The mount 
> bindaddr
> option then binds a mount to a specific local IP and thus to a specific 
> mac-vlan.
> 
> This shows 1000+ mounts on my test box, and the nfs server sees 1000
> unique clients (all with different MACs, IPS, etc).

Any reason why you couldn't multi-home the server too, and use the
destination IP address to control the route on the clients?

  Trond

