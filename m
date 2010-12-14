Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cirse-out.extra.cea.fr ([132.167.195.14]:22580 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755011Ab0LNHfR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 02:35:17 -0500
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id oBE7ZF0d027734
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 08:35:15 +0100
Received: from muguet2.intra.cea.fr (muguet2.intra.cea.fr [132.166.192.7])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id oBE7ZFTu017738
	for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 08:35:15 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet2.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id oBE7ZFHr000401
	for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 08:35:15 +0100
Message-ID: <4D071E32.905@cea.fr>
Date: Tue, 14 Dec 2010 08:35:14 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Thomas Haynes <thomas@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Side effects of having NFSv4 mounted over udp
References: <4D05CF50.1010305@cea.fr> <A9F12BB4-8571-4C58-AC6A-8094FA912B27@netapp.com> <20101213191634.GB2230@fieldses.org>
In-Reply-To: <20101213191634.GB2230@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi
> The Linux server allows it, but I've been considering that a
> (low-priority) bug, so it wouldn't be safe to assume it will continue
> working.
>   
I am mostly thinking at the client side using as well udp and tcp. Would 
the "NFSv4 client over UDP" behaves differently then the same client 
over TCP ?

> That aside, if you have a perfect network, 
I can trust my network. It's not a WAN, it's located into a very massive 
cluster (it's kind of "internal LAN"). It's a very high throughput 
network (IB based) so I believe there are less "hardware based reason" 
to loose packets.

> NFSv4.0 at least will
> probably work.  
OK.
> (Not 4.1 since backchannel setup will fail?)
>   
What is erroneous in using UDP for NFSv4.1 backchannels ?

> Are you really sure that you can't make tcp scale to thousands of
> clients?
>   
I am a bit afraid of a "No more file descriptors" effect. If I have one 
TCP socket per client and thousands of clients, I have less remaining 
fds for other purposes. Another point : UDP is a "cheap" protocol. I can 
have bunches of clients without overloading the server (a new client 
will almost cost nothing to the server, just the cost of a new clientid 
negotiation) . I was wondering if it could be reliable to use it for 
NFSv4 inside a large cluster.

    Philippe
